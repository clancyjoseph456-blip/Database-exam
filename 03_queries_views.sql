/* ================================================================
   FILE: 03_queries_views.sql
   DML examples, 5 SELECT queries and 3 reporting views
   Run AFTER 02_data.sql
   ================================================================ */
USE mukono_farm_db;

/* ====================== DML EXAMPLES =========================== */

-- 1) INSERT a new crop (IGNORE makes the example safely re-runnable)
INSERT IGNORE INTO crop (crop_name, crop_type, growing_season, expected_yield_kg_ha, is_perennial)
VALUES ('Avocado', 'Fruit', 'Both', 9000.00, TRUE);

-- 2) UPDATE post-harvest loss figure after re-weighing
UPDATE harvest
SET wasted_kg = 120.00
WHERE harvest_id = 1;

-- 3) DELETE an input that is no longer used (input_id 10 is unreferenced)
DELETE FROM input
WHERE input_id = 10;

/* ====================== 5 SELECT QUERIES ====================== */

-- QUERY 1: INNER JOIN across 5 tables – who bought what from which farmer
SELECT
    f.farmer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
    fa.farm_name,
    c.crop_name,
    h.season,
    b.company_name AS buyer,
    s.quantity_kg,
    s.total_amount
FROM sale s
JOIN harvest h ON s.harvest_id = h.harvest_id
JOIN farm fa   ON h.farm_id = fa.farm_id
JOIN farmer f  ON fa.farmer_id = f.farmer_id
JOIN person p  ON f.person_id = p.person_id
JOIN crop c    ON h.crop_id = c.crop_id
JOIN buyer b   ON s.buyer_id = b.buyer_id
ORDER BY s.sale_date;

-- QUERY 2: GROUP BY with SUM / AVG / COUNT – performance per crop
SELECT
    c.crop_name,
    COUNT(s.sale_id)                       AS number_of_sales,
    SUM(s.quantity_kg)                     AS total_kg_sold,
    ROUND(AVG(s.price_per_kg), 2)          AS avg_price_per_kg,
    SUM(s.total_amount)                    AS total_revenue_ugx
FROM sale s
JOIN harvest h ON s.harvest_id = h.harvest_id
JOIN crop c    ON h.crop_id = c.crop_id
GROUP BY c.crop_name
HAVING SUM(s.quantity_kg) > 500
ORDER BY total_revenue_ugx DESC;

-- QUERY 3: SUBQUERY – farmers whose harvest exceeds the overall average harvest
SELECT
    f.farmer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
    SUM(h.harvest_kg) AS total_harvest_kg
FROM farmer f
JOIN person p ON f.person_id = p.person_id
JOIN farm fa  ON f.farmer_id = fa.farmer_id
JOIN harvest h ON fa.farm_id = h.farm_id
GROUP BY f.farmer_id, farmer_name
HAVING SUM(h.harvest_kg) > (SELECT AVG(harvest_kg) FROM harvest)
ORDER BY total_harvest_kg DESC;

-- QUERY 4: CASE – conditional logic to grade harvest sizes
SELECT
    h.harvest_id,
    c.crop_name,
    h.harvest_kg,
    CASE
        WHEN h.harvest_kg >= 2000 THEN 'Large Harvest'
        WHEN h.harvest_kg >= 1000 THEN 'Medium Harvest'
        ELSE 'Small Harvest'
    END AS harvest_size_category,
    CASE
        WHEN h.wasted_kg / h.harvest_kg > 0.15 THEN 'HIGH LOSS - ACTION NEEDED'
        ELSE 'Acceptable Loss'
    END AS loss_alert
FROM harvest h
JOIN crop c ON h.crop_id = c.crop_id
ORDER BY h.harvest_kg DESC;

-- QUERY 5: BUILT-IN FUNCTIONS – CONCAT, UPPER, ROUND, DATE_FORMAT, COALESCE
SELECT
    UPPER(CONCAT(p.first_name, ' ', p.last_name))            AS farmer_full_name,
    CONCAT('0', RIGHT(p.phone, 9))                           AS formatted_phone,
    DATE_FORMAT(s.sale_date, '%d-%b-%Y')                     AS sale_date_nice,
    ROUND(s.total_amount, 0)                                 AS amount_rounded,
    COALESCE(b.company_name, 'Walk-in Individual Buyer')     AS buyer_display,
    DATEDIFF(CURDATE(), h.harvest_date)                      AS days_since_harvest
FROM sale s
JOIN harvest h ON s.harvest_id = h.harvest_id
JOIN farm fa   ON h.farm_id = fa.farm_id
JOIN farmer f  ON fa.farmer_id = f.farmer_id
JOIN person p  ON f.person_id = p.person_id
LEFT JOIN buyer b ON s.buyer_id = b.buyer_id;

/* ====================== 3 REPORTING VIEWS ===================== */

-- VIEW 1: SDG Indicator 1 – total harvest (kg) per farmer per season
CREATE OR REPLACE VIEW vw_farmer_harvest_summary AS
SELECT
    f.farmer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
    fa.farm_name,
    c.crop_name,
    h.season,
    h.harvest_kg,
    h.wasted_kg,
    COALESCE(sd.sold_kg, 0) AS sold_kg,
    h.harvest_kg - h.wasted_kg - COALESCE(sd.sold_kg, 0) AS available_kg,
    ROUND((COALESCE(sd.sold_kg, 0) / h.harvest_kg) * 100, 2) AS pct_sold
FROM harvest h
JOIN farm fa   ON h.farm_id = fa.farm_id
JOIN farmer f  ON fa.farmer_id = f.farmer_id
JOIN person p  ON f.person_id = p.person_id
JOIN crop c    ON h.crop_id = c.crop_id
LEFT JOIN (
    SELECT harvest_id, SUM(quantity_kg) AS sold_kg
    FROM sale
    GROUP BY harvest_id
) sd ON h.harvest_id = sd.harvest_id;

-- VIEW 2: Market linkage – sales performance by crop
CREATE OR REPLACE VIEW vw_sales_by_crop AS
SELECT
    c.crop_id,
    c.crop_name,
    COUNT(s.sale_id)                       AS number_of_sales,
    SUM(s.quantity_kg)                     AS total_qty_sold,
    ROUND(AVG(s.price_per_kg), 2)          AS avg_price_per_kg,
    SUM(s.total_amount)                    AS total_revenue_ugx
FROM crop c
JOIN harvest h ON c.crop_id = h.crop_id
JOIN sale s    ON h.harvest_id = s.harvest_id
GROUP BY c.crop_id, c.crop_name;

-- VIEW 3: SDG Indicator 2 – % of harvest sold vs wasted
CREATE OR REPLACE VIEW vw_wastage_report AS
SELECT
    f.farmer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
    c.crop_name,
    SUM(h.harvest_kg)                                       AS total_harvest_kg,
    SUM(h.wasted_kg)                                        AS total_wasted_kg,
    COALESCE(SUM(sd.sold_kg), 0)                            AS total_sold_kg,
    ROUND((SUM(h.wasted_kg) / SUM(h.harvest_kg)) * 100, 2)  AS pct_wasted,
    ROUND((COALESCE(SUM(sd.sold_kg), 0) / SUM(h.harvest_kg)) * 100, 2) AS pct_sold
FROM harvest h
JOIN farm fa   ON h.farm_id = fa.farm_id
JOIN farmer f  ON fa.farmer_id = f.farmer_id
JOIN person p  ON f.person_id = p.person_id
JOIN crop c    ON h.crop_id = c.crop_id
LEFT JOIN (
    SELECT harvest_id, SUM(quantity_kg) AS sold_kg
    FROM sale
    GROUP BY harvest_id
) sd ON h.harvest_id = sd.harvest_id
GROUP BY f.farmer_id, farmer_name, c.crop_name;

-- Quick verification of the views
SELECT * FROM vw_farmer_harvest_summary;
SELECT * FROM vw_sales_by_crop;
SELECT * FROM vw_wastage_report;

/* End of 03_queries_views.sql */
