/* ================================================================
   FILE: 04_procedures_triggers.sql
   Procedures, triggers, security, transaction and backup
   ================================================================ */
USE transport_fleet_db;

DELIMITER $$

/* PROCEDURE 1: get_driver_trips */
DROP PROCEDURE IF EXISTS get_driver_trips$$
CREATE PROCEDURE get_driver_trips(IN p_driver_id INT)
BEGIN
    SELECT
        t.trip_id,
        CONCAT(p.first_name,' ',p.last_name) AS driver_name,
        v.registration_number,
        r.route_name,
        t.departure_datetime,
        t.arrival_datetime,
        t.distance_travelled_km,
        t.fuel_used_litres,
        t.status
    FROM trip t
    JOIN driver d ON t.driver_id = d.driver_id
    JOIN person p ON d.person_id = p.person_id
    JOIN vehicle v ON t.vehicle_id = v.vehicle_id
    JOIN route r ON t.route_id = r.route_id
    WHERE d.driver_id = p_driver_id
    ORDER BY t.departure_datetime;
END$$

/* PROCEDURE 2: record_trip – transaction + OUT parameter + error handling */
DROP PROCEDURE IF EXISTS record_trip$$
CREATE PROCEDURE record_trip(
    IN  p_vehicle_id INT,
    IN  p_driver_id  INT,
    IN  p_route_id   INT,
    IN  p_distance   DECIMAL(10,2),
    OUT p_trip_id    INT
)
BEGIN
    DECLARE v_status  VARCHAR(20);
    DECLARE v_active  VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_trip_id = -1;
        RESIGNAL;
    END;

    SELECT status INTO v_status FROM vehicle WHERE vehicle_id = p_vehicle_id;
    SELECT driver_status INTO v_active FROM driver WHERE driver_id = p_driver_id;

    IF v_status IS NULL OR v_active IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle or driver not found';
    END IF;

    START TRANSACTION;

        INSERT INTO trip (vehicle_id, driver_id, route_id, departure_datetime,
                          distance_travelled_km, status, fuel_used_litres)
        VALUES (p_vehicle_id, p_driver_id, p_route_id, NOW(), p_distance, 'Scheduled', 0);

        SET p_trip_id = LAST_INSERT_ID();

        UPDATE vehicle
        SET status = 'On Trip'
        WHERE vehicle_id = p_vehicle_id;

    COMMIT;
END$$

/* PROCEDURE 3: get_sdg_report – fleet SDG indicators */
DROP PROCEDURE IF EXISTS get_sdg_report$$
CREATE PROCEDURE get_sdg_report()
BEGIN
    SELECT
        'Fleet Utilization % (avg)' AS indicator,
        ROUND(AVG(utilization_pct),2) AS value_pct
    FROM vw_vehicle_utilization
    UNION ALL
    SELECT
        'Fuel Efficiency (km/L avg)',
        ROUND(AVG(km_per_litre),2)
    FROM vw_fuel_efficiency
    UNION ALL
    SELECT
        'On-time Delivery % (avg)',
        ROUND(AVG(on_time_pct),2)
    FROM vw_delivery_performance;
END$$

/* TRIGGER 1: BEFORE INSERT on trip – only available vehicles & active drivers */
DROP TRIGGER IF EXISTS trg_trip_before_insert$$
CREATE TRIGGER trg_trip_before_insert
BEFORE INSERT ON trip
FOR EACH ROW
BEGIN
    DECLARE v_vehicle_status VARCHAR(20);
    DECLARE v_driver_status  VARCHAR(20);

    SELECT status INTO v_vehicle_status FROM vehicle WHERE vehicle_id = NEW.vehicle_id;
    SELECT driver_status INTO v_driver_status FROM driver WHERE driver_id = NEW.driver_id;

    IF v_vehicle_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid vehicle_id – trip blocked';
    END IF;
    IF v_driver_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid driver_id – trip blocked';
    END IF;
    IF v_vehicle_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle not available (Retired/In Garage/On Trip)';
    END IF;
    IF v_driver_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver not active – trip blocked';
    END IF;
END$$

/* TRIGGER 2: AFTER INSERT on trip – write audit log */
DROP TRIGGER IF EXISTS trg_trip_after_insert$$
CREATE TRIGGER trg_trip_after_insert
AFTER INSERT ON trip
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, action_description, changed_by)
    VALUES ('trip','INSERT',NEW.trip_id,
        CONCAT('Trip ',NEW.trip_id,' recorded: vehicle ',NEW.vehicle_id,
               ', driver ',NEW.driver_id,', route ',NEW.route_id,
               ', distance ',NEW.distance_travelled_km,' km'), USER());
END$$

DELIMITER ;

/* SECURE VIEW – hides driver phone and national ID */
CREATE OR REPLACE VIEW vw_driver_public AS
SELECT
    d.driver_id,
    CONCAT(p.first_name,' ',p.last_name) AS driver_name,
    p.district,
    d.licence_class,
    d.date_hired,
    d.driver_status
FROM driver d
JOIN person p ON d.person_id = p.person_id;

/* USERS AND GRANTS */
CREATE USER IF NOT EXISTS 'driver_user'@'localhost'  IDENTIFIED BY 'Driver@2026';
CREATE USER IF NOT EXISTS 'officer_user'@'localhost' IDENTIFIED BY 'Officer@2026';
CREATE USER IF NOT EXISTS 'admin_user'@'localhost'   IDENTIFIED BY 'Admin@2026';

GRANT SELECT ON transport_fleet_db.vw_driver_public       TO 'driver_user'@'localhost';
GRANT SELECT ON transport_fleet_db.vw_vehicle_utilization TO 'driver_user'@'localhost';
GRANT SELECT, INSERT ON transport_fleet_db.trip           TO 'driver_user'@'localhost';

GRANT SELECT ON transport_fleet_db.vw_vehicle_utilization TO 'officer_user'@'localhost';
GRANT SELECT ON transport_fleet_db.vw_fuel_efficiency     TO 'officer_user'@'localhost';
GRANT SELECT ON transport_fleet_db.vw_delivery_performance TO 'officer_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON transport_fleet_db.trip        TO 'officer_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON transport_fleet_db.fuel_record TO 'officer_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON transport_fleet_db.maintenance TO 'officer_user'@'localhost';

GRANT ALL PRIVILEGES ON transport_fleet_db.* TO 'admin_user'@'localhost';
FLUSH PRIVILEGES;

/* TRANSACTION EXAMPLE */
START TRANSACTION;
    UPDATE vehicle SET odometer_km = odometer_km + 26.50 WHERE vehicle_id = 1;
    INSERT INTO audit_log (table_name, operation, record_id, action_description, changed_by)
    VALUES ('vehicle','UPDATE',1,'Odometer updated after trip',USER());
COMMIT;

/* BACKUP / RESTORE (run in CMD, not in the SQL editor) */
-- mysqldump -u root -p --databases transport_fleet_db --routines --triggers --events > transport_fleet_db_backup.sql
-- mysql -u root -p < transport_fleet_db_backup.sql

/* TEST CALLS */
-- CALL get_driver_trips(1);
-- CALL get_sdg_report();
-- CALL record_trip(1,1,1,25.00,@tid); SELECT @tid AS trip_id;
-- SELECT * FROM audit_log;

/* End of 04_procedures_triggers.sql */
