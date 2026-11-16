/* ================================================================
   FILE: 02_data.sql
   Realistic sample data – 10 rows per main table (Mukono District)
   Run AFTER 01_schema.sql
   ================================================================ */
USE mukono_farm_db;

/* ---- PERSON: 10 farmers (person_id 1-10) + 10 buyers (11-20) ---- */
INSERT INTO person (person_id, person_type, first_name, last_name, phone, national_id, gender, date_of_birth, district) VALUES
(1,  'Farmer', 'Robert',   'Kato',     '0771000001', 'UG7701001001', 'Male',   '1982-04-12', 'Mukono'),
(2,  'Farmer', 'Sarah',    'Nalongo',  '0771000002', 'UG7701001002', 'Female', '1986-08-23', 'Mukono'),
(3,  'Farmer', 'Grace',    'Achieng',  '0771000003', 'UG7701001003', 'Female', '1979-11-05', 'Mukono'),
(4,  'Farmer', 'James',    'Okello',   '0771000004', 'UG7701001004', 'Male',   '1975-02-17', 'Mukono'),
(5,  'Farmer', 'Henry',    'Mukasa',   '0771000005', 'UG7701001005', 'Male',   '1988-06-30', 'Mukono'),
(6,  'Farmer', 'Rebecca',  'Nambozo',  '0771000006', 'UG7701001006', 'Female', '1990-09-14', 'Mukono'),
(7,  'Farmer', 'David',    'Ssempa',   '0771000007', 'UG7701001007', 'Male',   '1981-01-27', 'Mukono'),
(8,  'Farmer', 'Peace',    'Nakato',   '0771000008', 'UG7701001008', 'Female', '1987-12-03', 'Mukono'),
(9,  'Farmer', 'Patrick',  'Bbosa',    '0771000009', 'UG7701001009', 'Male',   '1978-05-19', 'Mukono'),
(10, 'Farmer', 'Anthony',  'Kizito',   '0771000010', 'UG7701001010', 'Male',   '1984-03-08', 'Mukono'),
(11, 'Buyer',  'Emmanuel', 'Muwazi',   '0782000011', 'UG7802001011', 'Male',   '1980-07-21', 'Mukono'),
(12, 'Buyer',  'Juliet',   'Nankya',   '0782000012', 'UG7802001012', 'Female', '1985-10-11', 'Mukono'),
(13, 'Buyer',  'Collins',  'Ouma',     '0782000013', 'UG7802001013', 'Male',   '1977-04-02', 'Kampala'),
(14, 'Buyer',  'Musa',     'Kibuule',  '0782000014', 'UG7802001014', 'Male',   '1983-08-16', 'Mukono'),
(15, 'Buyer',  'Esther',   'Nabirye',  '0782000015', 'UG7802001015', 'Female', '1989-02-25', 'Jinja'),
(16, 'Buyer',  'Bernard',  'Waiswa',   '0782000016', 'UG7802001016', 'Male',   '1976-06-09', 'Mukono'),
(17, 'Buyer',  'Joyce',    'Namatovu', '0782000017', 'UG7802001017', 'Female', '1982-09-28', 'Mukono'),
(18, 'Buyer',  'Paul',     'Ssekabira','0782000018', 'UG7802001018', 'Male',   '1974-12-13', 'Kampala'),
(19, 'Buyer',  'Ritah',    'Atugonza', '0782000019', 'UG7802001019', 'Female', '1991-03-07', 'Kayunga'),
(20, 'Buyer',  'Samuel',   'Mugisha',  '0782000020', 'UG7802001020', 'Male',   '1986-11-20', 'Mukono');

/* ---- FARMER (subclass) – 10 rows ---- */
INSERT INTO farmer (farmer_id, person_id, farmer_reg_number, cooperative_name, years_farming, registration_date) VALUES
(1,  1,  'FRM/MUK/001', 'Mukono Farmers Cooperative', 12, '2023-01-15 08:30:00'),
(2,  2,  'FRM/MUK/002', 'Mukono Farmers Cooperative', 9,  '2023-01-16 09:10:00'),
(3,  3,  'FRM/MUK/003', 'Nakifuma Women Farmers Group', 15, '2023-01-18 10:05:00'),
(4,  4,  'FRM/MUK/004', 'Mukono Farmers Cooperative', 20, '2023-02-02 11:20:00'),
(5,  5,  'FRM/MUK/005', 'Kyetume Produce Association', 7,  '2023-02-05 14:45:00'),
(6,  6,  'FRM/MUK/006', 'Nakifuma Women Farmers Group', 6,  '2023-02-11 09:00:00'),
(7,  7,  'FRM/MUK/007', 'Mukono Farmers Cooperative', 14, '2023-03-01 08:15:00'),
(8,  8,  'FRM/MUK/008', 'Nakifuma Women Farmers Group', 10, '2023-03-04 12:30:00'),
(9,  9,  'FRM/MUK/009', 'Kyetume Produce Association', 18, '2023-03-09 15:10:00'),
(10, 10, 'FRM/MUK/010', 'Mukono Farmers Cooperative', 8,  '2023-03-14 10:40:00');

/* ---- BUYER (subclass) – 10 rows ---- */
INSERT INTO buyer (buyer_id, person_id, buyer_type, company_name, license_number, credit_rating) VALUES
(1,  11, 'Trader',      'Tumusiime Traders',          'BL/MUK/101', 'A'),
(2,  12, 'Cooperative', 'Mukono Cooperative Union',   'BL/MUK/102', 'A'),
(3,  13, 'Processor',   'Kampala Foods Ltd',          'BL/KLA/103', 'A'),
(4,  14, 'Individual',  NULL,                         'BL/MUK/104', 'B'),
(5,  15, 'Trader',      'Jinja Produce Traders',      'BL/JIN/105', 'B'),
(6,  16, 'Government',  'NAADS Mukono',               'GOV/256/106','A'),
(7,  17, 'Cooperative', 'Nakifuma Farmers Union',     'BL/MUK/107', 'B'),
(8,  18, 'Processor',   'Uganda Coffee Processors',   'BL/KLA/108', 'A'),
(9,  19, 'Trader',      'Kayunga Agro Trade',         'BL/KAY/109', 'C'),
(10, 20, 'Individual',  NULL,                         'BL/MUK/110', 'B');

/* ---- FARM – 10 rows (one or more per farmer) ---- */
INSERT INTO farm (farm_id, farmer_id, farm_name, location, sub_county, size_hectares, soil_type, irrigation, latitude, longitude) VALUES
(1,  1,  'Kato Homestead Farm',   'Nakifuma',  'Nakifuma',  3.50, 'Loamy',    TRUE,  0.356100, 32.876500),
(2,  2,  'Nalongo Gardens',       'Ntenjeru',  'Ntenjeru',  2.20, 'Clay',     FALSE, 0.341200, 32.911300),
(3,  3,  'Achieng Matooke Farm',  'Kira',      'Kira',      4.10, 'Loamy',    TRUE,  0.360400, 32.945700),
(4,  4,  'Okello Coffee Plot',    'Nsangi',    'Nsangi',    1.80, 'Volcanic', FALSE, 0.298700, 32.812400),
(5,  5,  'Mukasa Cassava Farm',   'Mbalawa',   'Mbalawa',   5.60, 'Sandy',    FALSE, 0.372900, 32.864100),
(6,  6,  'Nambozo Sweet Farm',    'Kyetume',   'Kyetume',   2.75, 'Loamy',    FALSE, 0.326500, 32.889200),
(7,  7,  'Ssempa Groundnut Farm', 'Kiswe',     'Kiswe',     2.00, 'Sandy',    TRUE,  0.310800, 32.923600),
(8,  8,  'Nakato Sorghum Field',  'Namugga',   'Namugga',   3.30, 'Clay',     FALSE, 0.333100, 32.857800),
(9,  9,  'Bbosa Sunflower Farm',  'Goma',      'Goma',      4.00, 'Loamy',    FALSE, 0.368700, 32.901500),
(10, 10, 'Kizito Tomato Gardens', 'Seeta',     'Seeta',     1.50, 'Loamy',    TRUE,  0.345600, 32.937800);

/* ---- CROP – 10 rows ---- */
INSERT INTO crop (crop_id, crop_name, crop_type, growing_season, expected_yield_kg_ha, is_perennial) VALUES
(1,  'Maize',          'Cereal',    'Season A', 4500.00, FALSE),
(2,  'Beans',          'Legume',    'Both',     1800.00, FALSE),
(3,  'Matooke',        'Fruit',     'Both',     12000.00, TRUE),
(4,  'Coffee',         'Cash Crop', 'Both',     2000.00, TRUE),
(5,  'Cassava',        'Tuber',     'Both',     9000.00, FALSE),
(6,  'Sweet Potatoes', 'Tuber',     'Season B', 8000.00, FALSE),
(7,  'Groundnuts',     'Legume',    'Season A', 1500.00, FALSE),
(8,  'Sorghum',        'Cereal',    'Season A', 2500.00, FALSE),
(9,  'Sunflower',      'Cash Crop', 'Season B', 1800.00, FALSE),
(10, 'Tomatoes',       'Vegetable', 'Both',     15000.00, FALSE);

/* ---- INPUT – 10 rows ---- */
INSERT INTO input (input_id, input_name, input_type, unit, unit_cost_ugx, supplier) VALUES
(1,  'Hybrid Maize Seeds',    'Seed',       'kg',  12000.00, 'Mukono Agro Inputs Ltd'),
(2,  'Bean Seeds NABE 15',    'Seed',       'kg',   9000.00, 'Mukono Agro Inputs Ltd'),
(3,  'Matooke Suckers',       'Seed',       'plants', 2000.00, 'Nakifuma Nursery'),
(4,  'Coffee Seedlings',      'Seed',       'plants', 3500.00, 'Kyetume Coffee Nursery'),
(5,  'Urea Fertilizer',       'Fertilizer', 'kg',  150000.00, 'Uganda Fertilizers Ltd'),
(6,  'NPK Fertilizer',        'Fertilizer', 'kg',  140000.00, 'Uganda Fertilizers Ltd'),
(7,  'DAP Fertilizer',        'Fertilizer', 'kg',  165000.00, 'Mukono Agro Inputs Ltd'),
(8,  'Cypermethrin',          'Pesticide',  'ml',   45000.00, 'Kampala Agro Chemicals'),
(9,  'Mancozeb Fungicide',    'Pesticide',  'g',    38000.00, 'Kampala Agro Chemicals'),
(10, 'Glyphosate Herbicide',  'Herbicide',  'ml',   52000.00, 'Kampala Agro Chemicals');

/* ---- HARVEST – 10 rows (10 farmers x 10 crops) ---- */
INSERT INTO harvest (harvest_id, farm_id, crop_id, input_id, season, harvest_date, harvest_kg, wasted_kg, unit_price_ugx, quality_grade) VALUES
(1,  1,  1, 1, '2026 Season A', '2026-07-12', 2000.00, 100.00, 1200.00, 'A'),
(2,  2,  2, 2, '2026 Season A', '2026-07-18', 1200.00,  50.00, 1800.00, 'A'),
(3,  3,  3, 3, '2026 Season A', '2026-07-22', 3000.00, 300.00, 1500.00, 'B'),
(4,  4,  4, 4, '2026 Season A', '2026-07-25',  800.00,  20.00, 6500.00, 'A'),
(5,  5,  5, 5, '2026 Season B', '2026-08-02', 2500.00, 400.00,  900.00, 'B'),
(6,  6,  6, 6, '2026 Season B', '2026-08-06', 1800.00, 200.00, 1100.00, 'B'),
(7,  7,  7, 7, '2026 Season A', '2026-08-11',  950.00,  60.00, 3200.00, 'A'),
(8,  8,  8, 8, '2026 Season A', '2026-08-15', 1400.00, 150.00, 1400.00, 'B'),
(9,  9,  9, 9, '2026 Season B', '2026-08-20', 1100.00,  80.00, 2000.00, 'C'),
(10, 10, 10, 9, '2026 Season B', '2026-08-24', 2200.00, 350.00, 2500.00, 'B');

/* ---- SALE – 10 rows (AFTER INSERT trigger writes to audit_log) ---- */
INSERT INTO sale (sale_id, harvest_id, buyer_id, sale_date, quantity_kg, price_per_kg, payment_status, payment_method) VALUES
(1,  1,  1,  '2026-07-20', 1500.00, 1350.00, 'Paid',    'Mobile Money'),
(2,  2,  2,  '2026-07-26',  900.00, 1950.00, 'Paid',    'Bank Transfer'),
(3,  3,  3,  '2026-07-30', 2000.00, 1600.00, 'Partial', 'Bank Transfer'),
(4,  4,  8,  '2026-08-01',  600.00, 7000.00, 'Paid',    'Bank Transfer'),
(5,  5,  5,  '2026-08-09', 1500.00,  950.00, 'Pending', 'Cash'),
(6,  6,  7,  '2026-08-14', 1000.00, 1200.00, 'Paid',    'Mobile Money'),
(7,  7,  4,  '2026-08-18',  700.00, 3400.00, 'Paid',    'Cash'),
(8,  8,  6,  '2026-08-22', 1000.00, 1500.00, 'Paid',    'Bank Transfer'),
(9,  9,  9,  '2026-08-26',  800.00, 2100.00, 'Partial', 'Mobile Money'),
(10, 10, 10, '2026-08-29', 1400.00, 2700.00, 'Paid',    'Mobile Money');

/* ---- PAYMENT – 10 rows (union/category: Sale + Input Purchase) ---- */
INSERT INTO payment (payment_reference, amount_ugx, payment_method, source_type, sale_id, source_id, status) VALUES
('PAY-2026-001', 2025000.00, 'Mobile Money', 'Sale',           1,    NULL, 'Completed'),
('PAY-2026-002', 1755000.00, 'Bank Transfer','Sale',           2,    NULL, 'Completed'),
('PAY-2026-003', 1600000.00, 'Bank Transfer','Sale',           3,    NULL, 'Pending'),
('PAY-2026-004', 4200000.00, 'Bank Transfer','Sale',           4,    NULL, 'Completed'),
('PAY-2026-005', 1425000.00, 'Cash',         'Sale',           5,    NULL, 'Pending'),
('PAY-2026-006', 1200000.00, 'Mobile Money', 'Sale',           6,    NULL, 'Completed'),
('PAY-2026-007', 2380000.00, 'Cash',         'Sale',           7,    NULL, 'Completed'),
('PAY-2026-008', 1500000.00, 'Bank Transfer','Sale',           8,    NULL, 'Completed'),
('PAY-2026-009',  840000.00, 'Mobile Money', 'Input Purchase', NULL, 1,    'Completed'),
('PAY-2026-010',  450000.00, 'Cheque',       'Input Purchase', NULL, 2,    'Completed');

/* End of 02_data.sql */
