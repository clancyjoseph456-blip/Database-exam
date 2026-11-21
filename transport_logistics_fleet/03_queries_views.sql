/* ================================================================
   FILE: 03_queries_views.sql
   DML examples, 5 SELECT queries and 3 SDG reporting views
   ================================================================ */
USE transport_fleet_db;

/* -------------------- DML EXAMPLES ------------------------------ */
-- 1) INSERT a new route
INSERT IGNORE INTO route (route_name, origin, destination, distance_km, estimated_hours, toll_cost_ugx, road_type)
VALUES ('Mukono - Kayunga Bypass','Mukono','Kayunga',58.00,1.50,4000.00,'Highway');

-- 2) UPDATE a vehicle's status after it returns from the garage
UPDATE vehicle SET status = 'Available' WHERE vehicle_id = 9;

-- 3) DELETE an old maintenance record that has no expense linked
DELETE FROM maintenance WHERE maintenance_id = 10;

/* ---------------- 5 SELECT QUERIES ------------------------------ */

-- Q1 JOIN: trip with vehicle, driver, route and customer
SELECT
    t.trip_id,
    v.registration_number,
    CONCAT(p.first_name,' ',p.last_name) AS driver_name,
    r.route_name,
    t.distance_travelled_km,
    t.status,
    c.company_name AS customer
FROM trip t
JOIN vehicle v ON t.vehicle_id = v.vehicle_id
JOIN driver d   ON t.driver_id = d.driver_id
JOIN person p   ON d.person_id = p.person_id
JOIN route r    ON t.route_id = r.route_id
JOIN shipment s ON t.trip_id = s.trip_id
JOIN customer c ON s.customer_id = c.customer_id
ORDER BY t.trip_id;

-- Q2 GROUP BY + SUM/AVG/COUNT: performance per vehicle
SELECT
    v.registration_number,
    COUNT(t.trip_id)                          AS trip_count,
    SUM(t.distance_travelled_km)              AS total_km,
    ROUND(AVG(t.fuel_used_litres),2)          AS avg_litres_per_trip,
    SUM(t.cargo_weight_tonnes)                AS total_tonnes
FROM vehicle v
JOIN trip t ON v.vehicle_id = t.vehicle_id
GROUP BY v.registration_number
HAVING SUM(t.distance_travelled_km) > 50
ORDER BY total_km DESC;

-- Q3 SUBQUERY: vehicles whose odometer is above fleet average
SELECT registration_number, vehicle_type, odometer_km
FROM vehicle
WHERE odometer_km > (SELECT AVG(odometer_km) FROM vehicle)
ORDER BY odometer_km DESC;

-- Q4 CASE: classify trip distance and delivery outcome
SELECT
    t.trip_id,
    t.distance_travelled_km,
    CASE
        WHEN t.distance_travelled_km >= 100 THEN 'Long Haul'
        WHEN t.distance_travelled_km >= 40  THEN 'Medium Haul'
        ELSE 'Short Haul'
    END AS haul_category,
    CASE t.status
        WHEN 'Delivered' THEN 'SUCCESS'
        WHEN 'Delayed'   THEN 'FOLLOW UP'
        ELSE 'EXCEPTION'
    END AS outcome
FROM trip t
ORDER BY t.distance_travelled_km DESC;

-- Q5 BUILT-IN FUNCTIONS: CONCAT, UPPER, ROUND, DATE_FORMAT, COALESCE
SELECT
    UPPER(CONCAT(p.first_name,' ',p.last_name))       AS driver_name,
    DATE_FORMAT(t.departure_datetime,'%d-%b-%Y %H:%i') AS departure,
    ROUND(t.distance_travelled_km,0)                   AS distance_rounded,
    COALESCE(c.company_name,'Walk-in Customer')       AS customer_display,
    DATEDIFF(t.arrival_datetime, t.departure_datetime) AS trip_days
FROM trip t
JOIN driver d   ON t.driver_id = d.driver_id
JOIN person p   ON d.person_id = p.person_id
JOIN shipment s ON t.trip_id = s.trip_id
LEFT JOIN customer c ON s.customer_id = c.customer_id;

/* ---------------- 3 REPORTING VIEWS ----------------------------- */

-- VIEW 1: SDG Indicator 1 – fleet utilisation per vehicle
CREATE OR REPLACE VIEW vw_vehicle_utilization AS
SELECT
    v.vehicle_id,
    v.registration_number,
    v.vehicle_type,
    v.target_distance_km,
    COALESCE(SUM(t.distance_travelled_km),0) AS total_distance_km,
    ROUND((COALESCE(SUM(t.distance_travelled_km),0) / v.target_distance_km) * 100, 2) AS utilization_pct
FROM vehicle v
LEFT JOIN trip t ON v.vehicle_id = t.vehicle_id
GROUP BY v.vehicle_id, v.registration_number, v.vehicle_type, v.target_distance_km;

-- VIEW 2: SDG Indicator 2a – fuel efficiency (km per litre)
CREATE OR REPLACE VIEW vw_fuel_efficiency AS
SELECT
    v.vehicle_id,
    v.registration_number,
    v.fuel_type,
    SUM(t.distance_travelled_km) AS total_km,
    SUM(t.fuel_used_litres)      AS total_litres,
    ROUND(SUM(t.distance_travelled_km) / NULLIF(SUM(t.fuel_used_litres),0), 2) AS km_per_litre,
    SUM(f.total_cost_ugx)        AS total_fuel_cost_ugx
FROM vehicle v
JOIN trip t ON v.vehicle_id = t.vehicle_id
LEFT JOIN fuel_record f ON t.trip_id = f.trip_id
GROUP BY v.vehicle_id, v.registration_number, v.fuel_type;

-- VIEW 3: SDG Indicator 2b – delivery reliability
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    d.driver_id,
    CONCAT(p.first_name,' ',p.last_name) AS driver_name,
    COUNT(t.trip_id) AS total_trips,
    SUM(CASE WHEN t.status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_trips,
    SUM(CASE WHEN t.status = 'Delayed'   THEN 1 ELSE 0 END) AS delayed_trips,
    ROUND((SUM(CASE WHEN t.status = 'Delivered' THEN 1 ELSE 0 END) / COUNT(t.trip_id)) * 100, 2) AS on_time_pct
FROM driver d
JOIN person p ON d.person_id = p.person_id
JOIN trip t   ON d.driver_id = t.driver_id
GROUP BY d.driver_id, driver_name;

SELECT * FROM vw_vehicle_utilization;
SELECT * FROM vw_fuel_efficiency;
SELECT * FROM vw_delivery_performance;

/* End of 03_queries_views.sql */
