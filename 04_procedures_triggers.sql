/* ================================================================
   FILE: 04_procedures_triggers.sql
   Stored procedures, triggers, views for security, users/grants,
   transaction example and backup command. MySQL 8.0
   Run AFTER 03_queries_views.sql
   ================================================================ */
USE mukono_farm_db;

DELIMITER $$

/* ---------------- PROCEDURE 1: get_farmer_sales ----------------- */
DROP PROCEDURE IF EXISTS get_farmer_sales$$
CREATE PROCEDURE get_farmer_sales(IN p_farmer_id INT)
BEGIN
    SELECT
        f.farmer_id,
        CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
        fa.farm_name,
        c.crop_name,
        h.season,
        s.sale_id,
        s.sale_date,
        s.quantity_kg,
        s.price_per_kg,
        s.total_amount,
        b.company_name AS buyer
    FROM farmer f
    JOIN person p  ON f.person_id = p.person_id
    JOIN farm fa   ON f.farmer_id = fa.farmer_id
    JOIN harvest h ON fa.farm_id = h.farm_id
    JOIN sale s    ON h.harvest_id = s.harvest_id
    JOIN buyer b   ON s.buyer_id = b.buyer_id
    JOIN person bp ON b.person_id = bp.person_id
    WHERE f.farmer_id = p_farmer_id
    ORDER BY s.sale_date;
END$$

/* --------- PROCEDURE 2: record_sale (transaction + errors) ------ */
DROP PROCEDURE IF EXISTS record_sale$$
CREATE PROCEDURE record_sale(
    IN  p_harvest_id INT,
    IN  p_buyer_id   INT,
    IN  p_qty        DECIMAL(10,2),
    OUT p_total      DECIMAL(14,2)
)
BEGIN
    DECLARE v_price DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_total = -1;
        RESIGNAL;
    END;

    SELECT unit_price_ugx INTO v_price
    FROM harvest
    WHERE harvest_id = p_harvest_id;

    IF v_price IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Harvest not found – sale aborted';
    END IF;

    START TRANSACTION;

        INSERT INTO sale
            (harvest_id, buyer_id, sale_date, quantity_kg, price_per_kg,
             payment_status, payment_method)
        VALUES
            (p_harvest_id, p_buyer_id, CURDATE(), p_qty, v_price,
             'Pending', 'Mobile Money');

        SET p_total = ROUND(p_qty * v_price, 2);

        INSERT INTO payment
            (payment_reference, amount_ugx, payment_method, source_type,
             sale_id, source_id, status)
        VALUES
            (CONCAT('PAY-', YEAR(CURDATE()), '-', LPAD(LAST_INSERT_ID(), 5, '0')),
             p_total, 'Mobile Money', 'Sale', LAST_INSERT_ID(), NULL, 'Pending');

    COMMIT;
END$$

/* ------------- PROCEDURE 3: get_sdg_report ---------------------- */
DROP PROCEDURE IF EXISTS get_sdg_report$$
CREATE PROCEDURE get_sdg_report()
BEGIN
    SELECT
        f.farmer_id,
        CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
        f.cooperative_name,
        SUM(h.harvest_kg)                                        AS total_harvest_kg,
        COALESCE(SUM(sd.sold_kg), 0)                             AS total_sold_kg,
        SUM(h.wasted_kg)                                         AS total_wasted_kg,
        ROUND((COALESCE(SUM(sd.sold_kg), 0) / SUM(h.harvest_kg)) * 100, 2) AS pct_sold,
        ROUND((SUM(h.wasted_kg) / SUM(h.harvest_kg)) * 100, 2)   AS pct_wasted
    FROM farmer f
    JOIN person p  ON f.person_id = p.person_id
    JOIN farm fa   ON f.farmer_id = fa.farmer_id
    JOIN harvest h ON fa.farm_id = h.farm_id
    LEFT JOIN (
        SELECT harvest_id, SUM(quantity_kg) AS sold_kg
        FROM sale
        GROUP BY harvest_id
    ) sd ON h.harvest_id = sd.harvest_id
    GROUP BY f.farmer_id, farmer_name, f.cooperative_name
    ORDER BY total_harvest_kg DESC;
END$$

/* ============ TRIGGER 1: BEFORE INSERT on Sale ================== */
/* Business rule: cannot sell more than the harvested amount that
   is still available (harvest_kg minus wasted_kg minus prior sales) */
DROP TRIGGER IF EXISTS trg_sale_before_insert$$
CREATE TRIGGER trg_sale_before_insert
BEFORE INSERT ON sale
FOR EACH ROW
BEGIN
    DECLARE v_available DECIMAL(10,2);
    DECLARE v_sold      DECIMAL(10,2);

    SELECT harvest_kg - wasted_kg INTO v_available
    FROM harvest
    WHERE harvest_id = NEW.harvest_id;

    IF v_available IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid harvest_id – sale blocked';
    END IF;

    SELECT COALESCE(SUM(quantity_kg), 0) INTO v_sold
    FROM sale
    WHERE harvest_id = NEW.harvest_id;

    IF NEW.quantity_kg > (v_available - v_sold) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Oversell blocked: quantity exceeds available harvest';
    END IF;
END$$

/* ============ TRIGGER 2: AFTER INSERT on Sale =================== */
/* Audit/history mechanism: record every sale in audit_log */
DROP TRIGGER IF EXISTS trg_sale_after_insert$$
CREATE TRIGGER trg_sale_after_insert
AFTER INSERT ON sale
FOR EACH ROW
BEGIN
    INSERT INTO audit_log
        (table_name, operation, record_id, action_description, changed_by)
    VALUES
        ('sale', 'INSERT', NEW.sale_id,
         CONCAT('Sale ', NEW.sale_id, ' recorded: harvest ', NEW.harvest_id,
                ', buyer ', NEW.buyer_id, ', qty ', NEW.quantity_kg,
                ' kg, total UGX ', NEW.total_amount),
         USER());
END$$

DELIMITER ;

/* ==================== SECURE VIEW =============================== */
/* Least privilege: farmer_user may see names and district only –
   phone and national_id are deliberately excluded. */
CREATE OR REPLACE VIEW vw_farmer_public AS
SELECT
    f.farmer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
    p.district,
    f.cooperative_name,
    f.years_farming,
    f.registration_date
FROM farmer f
JOIN person p ON f.person_id = p.person_id;

/* ==================== USERS AND GRANTS ========================= */
CREATE USER IF NOT EXISTS 'farmer_user'@'localhost'  IDENTIFIED BY 'Farmer@2026';
CREATE USER IF NOT EXISTS 'officer_user'@'localhost' IDENTIFIED BY 'Officer@2026';
CREATE USER IF NOT EXISTS 'admin_user'@'localhost'   IDENTIFIED BY 'Admin@2026';

-- Farmer: read own public details, record sales, view own summary
GRANT SELECT ON mukono_farm_db.vw_farmer_public          TO 'farmer_user'@'localhost';
GRANT SELECT ON mukono_farm_db.vw_farmer_harvest_summary TO 'farmer_user'@'localhost';
GRANT SELECT, INSERT ON mukono_farm_db.sale              TO 'farmer_user'@'localhost';

-- Officer: full read on operational data + maintain harvest/sale records
GRANT SELECT ON mukono_farm_db.vw_farmer_harvest_summary TO 'officer_user'@'localhost';
GRANT SELECT ON mukono_farm_db.vw_sales_by_crop          TO 'officer_user'@'localhost';
GRANT SELECT ON mukono_farm_db.vw_wastage_report         TO 'officer_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON mukono_farm_db.harvest   TO 'officer_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON mukono_farm_db.sale      TO 'officer_user'@'localhost';
GRANT SELECT ON mukono_farm_db.payment                   TO 'officer_user'@'localhost';

-- Admin: full control including user-managed objects and audit log
GRANT ALL PRIVILEGES ON mukono_farm_db.* TO 'admin_user'@'localhost';

FLUSH PRIVILEGES;

/* ============ TRANSACTION MANAGEMENT EXAMPLE =================== */
START TRANSACTION;
    UPDATE harvest
    SET wasted_kg = 130.00
    WHERE harvest_id = 1;

    INSERT INTO audit_log
        (table_name, operation, record_id, action_description, changed_by)
    VALUES
        ('harvest', 'UPDATE', 1, 'Corrected wastage to 130 kg after audit', USER());
COMMIT;
-- If an error occurs, use ROLLBACK; instead of COMMIT;

/* ============ BACKUP AND RECOVERY COMMANDS ====================== */
-- Backup (run in Windows Command Prompt / terminal, NOT in VS Code SQL editor):
-- mysqldump -u root -p --databases mukono_farm_db --routines --triggers --events > mukono_farm_db_backup.sql
-- Restore:
-- mysql -u root -p < mukono_farm_db_backup.sql

/* ================= TEST CALLS (uncomment to verify) ============ */
-- CALL get_farmer_sales(1);
-- CALL get_sdg_report();
-- CALL record_sale(1, 1, 100.00, @total); SELECT @total AS sale_total;
-- CALL record_sale(1, 1, 99999.00, @bad);  -- should be blocked by trigger
-- SELECT * FROM audit_log;

/* End of 04_procedures_triggers.sql */
