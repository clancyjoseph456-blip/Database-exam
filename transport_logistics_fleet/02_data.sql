/* ================================================================
   FILE: 02_data.sql
   10 realistic Ugandan rows per main table – Transport domain
   ================================================================ */
USE transport_fleet_db;

/* PERSON: 10 drivers (1-10) + 10 customers (11-20) */
INSERT INTO person (person_id, person_type, first_name, last_name, phone, national_id, gender, date_of_birth, district) VALUES
(1, 'Driver','Robert','Kato',     '0771000001','UG7701001001','Male',  '1982-04-12','Mukono'),
(2, 'Driver','Sarah','Nalongo',   '0771000002','UG7701001002','Female','1986-08-23','Mukono'),
(3, 'Driver','Grace','Achieng',   '0771000003','UG7701001003','Female','1979-11-05','Mukono'),
(4, 'Driver','James','Okello',    '0771000004','UG7701001004','Male',  '1975-02-17','Mukono'),
(5, 'Driver','Henry','Mukasa',    '0771000005','UG7701001005','Male',  '1988-06-30','Mukono'),
(6, 'Driver','Rebecca','Nambozo', '0771000006','UG7701001006','Female','1990-09-14','Mukono'),
(7, 'Driver','David','Ssempa',    '0771000007','UG7701001007','Male',  '1981-01-27','Mukono'),
(8, 'Driver','Peace','Nakato',    '0771000008','UG7701001008','Female','1987-12-03','Mukono'),
(9, 'Driver','Patrick','Bbosa',   '0771000009','UG7701001009','Male',  '1978-05-19','Mukono'),
(10,'Driver','Anthony','Kizito',  '0771000010','UG7701001010','Male',  '1984-03-08','Mukono'),
(11,'Customer','Emmanuel','Muwazi',  '0782000011','UG7802001011','Male',  '1980-07-21','Mukono'),
(12,'Customer','Juliet','Nankya',    '0782000012','UG7802001012','Female','1985-10-11','Mukono'),
(13,'Customer','Collins','Ouma',     '0782000013','UG7802001013','Male',  '1977-04-02','Kampala'),
(14,'Customer','Musa','Kibuule',     '0782000014','UG7802001014','Male',  '1983-08-16','Mukono'),
(15,'Customer','Esther','Nabirye',   '0782000015','UG7802001015','Female','1989-02-25','Jinja'),
(16,'Customer','Bernard','Waiswa',   '0782000016','UG7802001016','Male',  '1976-06-09','Mukono'),
(17,'Customer','Joyce','Namatovu',   '0782000017','UG7802001017','Female','1982-09-28','Mukono'),
(18,'Customer','Paul','Ssekabira',   '0782000018','UG7802001018','Male',  '1974-12-13','Kampala'),
(19,'Customer','Ritah','Atugonza',   '0782000019','UG7802001019','Female','1991-03-07','Kayunga'),
(20,'Customer','Samuel','Mugisha',   '0782000020','UG7802001020','Male',  '1986-11-20','Mukono');

/* DRIVER */
INSERT INTO driver (driver_id, person_id, licence_number, licence_class, date_hired, driver_status, years_experience) VALUES
(1, 1, 'DL/MUK/001','C','2018-03-05','Active',8),
(2, 2, 'DL/MUK/002','B','2019-06-12','Active',7),
(3, 3, 'DL/MUK/003','D','2016-01-20','Active',10),
(4, 4, 'DL/MUK/004','C','2015-09-09','Active',11),
(5, 5, 'DL/MUK/005','B','2020-02-17','Active',6),
(6, 6, 'DL/MUK/006','C','2021-04-26','Active',5),
(7, 7, 'DL/MUK/007','E','2017-07-14','Active',9),
(8, 8, 'DL/MUK/008','B','2022-01-10','Active',4),
(9, 9, 'DL/MUK/009','D','2014-11-03','Active',12),
(10,10, 'DL/MUK/010','C','2019-08-19','Suspended',7);

/* CUSTOMER */
INSERT INTO customer (customer_id, person_id, customer_type, company_name, account_number, credit_rating) VALUES
(1, 11,'Business',   'Tumusiime Traders',        'ACC-001','A'),
(2, 12,'Cooperative','Mukono Cooperative Union', 'ACC-002','A'),
(3, 13,'Business',   'Kampala Foods Ltd',        'ACC-003','A'),
(4, 14,'Individual', NULL,                        'ACC-004','B'),
(5, 15,'Business',   'Jinja Steelworks',         'ACC-005','B'),
(6, 16,'Government', 'NAADS Mukono',             'ACC-006','A'),
(7, 17,'Cooperative','Nakifuma Farmers Union',   'ACC-007','B'),
(8, 18,'Business',   'Uganda Coffee Processors', 'ACC-008','A'),
(9, 19,'Business',   'Kayunga Agro Trade',       'ACC-009','C'),
(10,20,'Individual', NULL,                        'ACC-010','B');

/* VEHICLE – 1..8 Available, 9 In Garage, 10 Retired */
INSERT INTO vehicle (vehicle_id, registration_number, vehicle_type, make, model, year_manufactured, capacity_tonnes, fuel_type, purchase_date, purchase_cost_ugx, status, odometer_km, target_distance_km) VALUES
(1, 'UBC 123A','Truck','Toyota','Hino 500',2018,10.00,'Diesel','2018-05-14',185000000.00,'Available',84500.00,60.00),
(2, 'UBC 456B','Pickup','Toyota','Hilux',2020,1.20,'Diesel','2020-02-10', 98000000.00,'Available',42300.00,180.00),
(3, 'UAX 789C','Van','Nissan','Caravan',2019,1.50,'Petrol','2019-08-22', 76000000.00,'Available',56700.00,90.00),
(4, 'UBC 321D','Truck','Isuzu','FTR 850',2017,12.00,'Diesel','2017-11-03',210000000.00,'Available',102400.00,70.00),
(5, 'UDF 654E','Bus','Toyota','Coaster',2016,3.00,'Diesel','2016-04-17',165000000.00,'Available',132800.00,45.00),
(6, 'UBC 987F','Tricycle','Bajaj','RE Compact',2022,0.40,'Petrol','2022-03-09', 18000000.00,'Available', 18900.00,20.00),
(7, 'UAX 147G','Truck','Mitsubishi','Fuso',2015,8.00,'Diesel','2015-06-25',170000000.00,'Available',118600.00,120.00),
(8, 'UBC 258H','Pickup','Ford','Ranger',2021,1.00,'Diesel','2021-09-30',105000000.00,'Available', 31200.00,280.00),
(9, 'UBC 369J','Van','Toyota','HiAce',2014,1.20,'Diesel','2014-01-15', 62000000.00,'In Garage',145700.00,2400.00),
(10,'UAX 741K','Truck','Isuzu','FSR',2012,9.00,'Diesel','2012-07-08',140000000.00,'Retired',198300.00,3000.00);

/* ROUTE */
INSERT INTO route (route_id, route_name, origin, destination, distance_km, estimated_hours, toll_cost_ugx, road_type, is_active) VALUES
(1, 'Kampala - Mukono',      'Kampala','Mukono',   25.00,0.80,  5000.00,'Highway',TRUE),
(2, 'Mukono - Nakifuma',     'Mukono','Nakifuma',  40.00,1.10,     0.00,'Gravel', TRUE),
(3, 'Kampala - Jinja',       'Kampala','Jinja',    85.00,2.00, 15000.00,'Highway',TRUE),
(4, 'Mukono - Kayunga',      'Mukono','Kayunga',   65.00,1.70,  8000.00,'Highway',TRUE),
(5, 'Kampala - Entebbe',     'Kampala','Entebbe',  40.00,1.00, 10000.00,'Highway',TRUE),
(6, 'Mukono - Ntenjeru',     'Mukono','Ntenjeru',  18.00,0.60,     0.00,'Urban',  TRUE),
(7, 'Jinja - Tororo',        'Jinja','Tororo',    115.00,2.60, 12000.00,'Highway',TRUE),
(8, 'Kampala - Mbarara',     'Kampala','Mbarara', 270.00,5.00, 30000.00,'Highway',TRUE),
(9, 'Mukono - Kiswe',        'Mukono','Kiswe',     30.00,0.90,     0.00,'Gravel', TRUE),
(10,'Kampala - Masaka',      'Kampala','Masaka',  135.00,3.00, 18000.00,'Highway',FALSE);

/* TRIP – vehicles 1-8 and drivers 1-9 only (trigger requires Available/Active) */
INSERT INTO trip (trip_id, vehicle_id, driver_id, route_id, departure_datetime, arrival_datetime, distance_travelled_km, status, cargo_weight_tonnes, fuel_used_litres) VALUES
(1, 1,1,1,'2026-10-02 07:00:00','2026-10-02 08:10:00', 26.50,'Delivered', 6.00, 8.50),
(2, 2,2,2,'2026-10-03 08:30:00','2026-10-03 09:50:00', 42.00,'Delivered', 0.80,12.00),
(3, 3,3,3,'2026-10-05 06:15:00','2026-10-05 08:40:00', 88.00,'Delivered', 1.20,28.00),
(4, 4,4,4,'2026-10-07 07:45:00','2026-10-07 09:35:00', 66.00,'Delayed',  9.50,20.00),
(5, 5,5,5,'2026-10-09 09:00:00','2026-10-09 10:15:00', 41.00,'Delivered', 2.00,14.00),
(6, 6,6,6,'2026-10-11 10:20:00','2026-10-11 11:05:00', 19.00,'Delivered', 0.30, 6.00),
(7, 7,7,7,'2026-10-13 05:30:00','2026-10-13 08:20:00',118.00,'Delivered', 7.00,35.00),
(8, 8,8,8,'2026-10-15 04:00:00','2026-10-15 09:30:00',275.00,'Delivered', 0.90,85.00),
(9, 1,1,9,'2026-10-18 07:10:00','2026-10-18 08:05:00', 31.00,'Cancelled',0.00, 9.50),
(10,2,9,10,'2026-10-20 06:40:00','2026-10-20 10:10:00',138.00,'Delayed',  1.00,42.00);

/* SHIPMENT */
INSERT INTO shipment (shipment_id, trip_id, customer_id, consignment_number, description, weight_tonnes, pickup_location, dropoff_location, declared_value_ugx, status) VALUES
(1, 1,1,'CONS-001','Maize bags',        6.00,'Kampala','Mukono',  18000000.00,'Delivered'),
(2, 2,2,'CONS-002','Cooperative produce',0.80,'Mukono','Nakifuma', 4500000.00,'Delivered'),
(3, 3,3,'CONS-003','Food supplies',     1.20,'Kampala','Jinja',    9000000.00,'Delivered'),
(4, 4,4,'CONS-004','Building materials',9.50,'Mukono','Kayunga', 22000000.00,'In Transit'),
(5, 5,5,'CONS-005','Steel bars',        2.00,'Kampala','Entebbe', 15000000.00,'Delivered'),
(6, 6,6,'CONS-006','Agricultural inputs',0.30,'Mukono','Ntenjeru', 2100000.00,'Delivered'),
(7, 7,7,'CONS-007','Fertilizer sacks',  7.00,'Jinja','Tororo',    28000000.00,'Delivered'),
(8, 8,8,'CONS-008','Coffee bags',       0.90,'Kampala','Mbarara', 35000000.00,'Delivered'),
(9, 9,9,'CONS-009','Agro chemicals',    0.00,'Mukono','Kiswe',     1200000.00,'Cancelled'),
(10,10,10,'CONS-010','Retail goods',    1.00,'Kampala','Masaka',   6800000.00,'In Transit');

/* MAINTENANCE */
INSERT INTO maintenance (maintenance_id, vehicle_id, service_date, service_type, odometer_km, cost_ugx, garage_name, next_service_date, status, notes) VALUES
(1, 1,'2026-09-05','Routine',82000.00, 850000.00,'Mukono Auto Garage','2026-12-05','Completed','Oil and filter change'),
(2, 2,'2026-09-12','Inspection',41000.00, 320000.00,'Kampala Motors','2026-12-12','Completed','Brakes checked'),
(3, 4,'2026-09-18','Repair',100500.00,2400000.00,'Jinja Truck Centre','2026-11-18','Completed','Gearbox repair'),
(4, 5,'2026-08-22','Routine',129000.00, 960000.00,'Mukono Auto Garage','2026-11-22','Overdue','Service due'),
(5, 7,'2026-10-01','Replacement',117000.00,1800000.00,'Kampala Motors','2027-01-01','Completed','Tyres replaced'),
(6, 9,'2026-09-28','Repair',144000.00,3100000.00,'Mukono Auto Garage','2026-10-28','Pending','Engine fault'),
(7, 3,'2026-09-30','Routine',55000.00, 540000.00,'Nakifuma Garage','2026-12-30','Completed','Minor service'),
(8, 8,'2026-10-05','Inspection',30000.00, 250000.00,'Kampala Motors','2027-01-05','Completed','Annual inspection'),
(9, 6,'2026-10-08','Repair',18000.00, 180000.00,'Mukono Auto Garage','2026-11-08','Completed','Battery replaced'),
(10,10,'2026-08-15','Routine',196000.00, 720000.00,'Jinja Truck Centre','2026-11-15','Overdue','Last service before retirement');

/* FUEL RECORD */
INSERT INTO fuel_record (fuel_id, vehicle_id, trip_id, fuel_date, litres, cost_per_litre, station_name, odometer_km) VALUES
(1,1,1,'2026-10-02 06:50:00', 8.50,1850.00,'Total Mukono', 84500.00),
(2,2,2,'2026-10-03 08:20:00',12.00,1850.00,'Shell Ntinda', 42300.00),
(3,3,3,'2026-10-05 06:00:00',28.00,1850.00,'Total Kampala',56700.00),
(4,4,4,'2026-10-07 07:30:00',20.00,1850.00,'Mobil Mukono',102400.00),
(5,5,5,'2026-10-09 08:45:00',14.00,1850.00,'Total Entebbe',132800.00),
(6,6,6,'2026-10-11 10:10:00', 6.00,1950.00,'Kiswe Petrol', 18900.00),
(7,7,7,'2026-10-13 05:15:00',35.00,1850.00,'Total Jinja',118600.00),
(8,8,8,'2026-10-15 03:45:00',85.00,1850.00,'Shell Kampala',31200.00),
(9,1,9,'2026-10-18 07:00:00', 9.50,1850.00,'Total Mukono', 84680.00),
(10,2,10,'2026-10-20 06:30:00',42.00,1850.00,'Total Kampala', 42400.00);

/* EXPENSE – union/category type: Fuel / Maintenance / Toll */
INSERT INTO expense (reference, amount_ugx, source_type, fuel_id, maintenance_id, source_id, status) VALUES
('EXP-2026-001', 15725.00,'Fuel',       1,NULL,NULL,'Completed'),
('EXP-2026-002', 22200.00,'Fuel',       2,NULL,NULL,'Completed'),
('EXP-2026-003', 51800.00,'Fuel',       3,NULL,NULL,'Completed'),
('EXP-2026-004', 37000.00,'Fuel',       4,NULL,NULL,'Completed'),
('EXP-2026-005', 25900.00,'Fuel',       5,NULL,NULL,'Completed'),
('EXP-2026-006', 11700.00,'Fuel',       6,NULL,NULL,'Completed'),
('EXP-2026-007',850000.00,'Maintenance',NULL,1,NULL,'Completed'),
('EXP-2026-008',320000.00,'Maintenance',NULL,2,NULL,'Completed'),
('EXP-2026-009',2400000.00,'Maintenance',NULL,3,NULL,'Completed'),
('EXP-2026-010', 5000.00,'Toll',        NULL,NULL,1,   'Completed');

/* End of 02_data.sql */
