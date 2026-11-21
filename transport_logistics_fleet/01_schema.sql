/* ================================================================
   FILE: 01_schema.sql
   CSC2209 Database Programming – Project-Based Exam, Advent 2026
   Transport, Logistics and Fleet Management domain
   Database: transport_fleet_db  |  MySQL 8.0 / 8.4
   Run this file FIRST.
   ================================================================ */

DROP DATABASE IF EXISTS transport_fleet_db;
CREATE DATABASE transport_fleet_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE transport_fleet_db;

/* ---------- SUPERTYPE: PERSON (Driver / Customer disjoint) ------ */
CREATE TABLE person (
    person_id     INT AUTO_INCREMENT PRIMARY KEY,
    person_type   ENUM('Driver','Customer','Staff') NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    phone         VARCHAR(12) NOT NULL,
    national_id   VARCHAR(20) UNIQUE,
    gender        ENUM('Male','Female') NOT NULL,
    date_of_birth DATE NOT NULL,
    district      VARCHAR(50) NOT NULL DEFAULT 'Mukono',
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_person_phone CHECK (phone REGEXP '^0[0-9]{9}$'),
    CONSTRAINT uq_person_phone UNIQUE (phone)
) ENGINE=InnoDB;

/* ---------- SUBCLASS: DRIVER ------------------------------------ */
CREATE TABLE driver (
    driver_id        INT AUTO_INCREMENT PRIMARY KEY,
    person_id        INT NOT NULL,
    licence_number   VARCHAR(30) NOT NULL,
    licence_class    ENUM('A','B','C','D','E') NOT NULL,
    date_hired       DATE NOT NULL,
    driver_status    ENUM('Active','Suspended','On Leave') NOT NULL DEFAULT 'Active',
    years_experience INT NOT NULL DEFAULT 0,
    CONSTRAINT uq_driver_person  UNIQUE (person_id),
    CONSTRAINT uq_driver_licence UNIQUE (licence_number),
    CONSTRAINT chk_driver_exp    CHECK (years_experience >= 0),
    CONSTRAINT fk_driver_person  FOREIGN KEY (person_id)
        REFERENCES person(person_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ---------- SUBCLASS: CUSTOMER ---------------------------------- */
CREATE TABLE customer (
    customer_id    INT AUTO_INCREMENT PRIMARY KEY,
    person_id      INT NOT NULL,
    customer_type  ENUM('Individual','Business','Government','NGO','Cooperative') NOT NULL,
    company_name   VARCHAR(100),
    account_number VARCHAR(30) NOT NULL,
    credit_rating  ENUM('A','B','C') NOT NULL DEFAULT 'B',
    CONSTRAINT uq_customer_person  UNIQUE (person_id),
    CONSTRAINT uq_customer_account UNIQUE (account_number),
    CONSTRAINT fk_customer_person  FOREIGN KEY (person_id)
        REFERENCES person(person_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ---------- VEHICLE --------------------------------------------- */
CREATE TABLE vehicle (
    vehicle_id         INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(20) NOT NULL,
    vehicle_type       ENUM('Truck','Pickup','Van','Bus','Tricycle','Motorcycle') NOT NULL,
    make               VARCHAR(50) NOT NULL,
    model              VARCHAR(50) NOT NULL,
    year_manufactured  INT NOT NULL,
    capacity_tonnes    DECIMAL(8,2) NOT NULL,
    fuel_type          ENUM('Diesel','Petrol','Electric') NOT NULL DEFAULT 'Diesel',
    purchase_date      DATE NOT NULL,
    purchase_cost_ugx  DECIMAL(14,2) NOT NULL,
    status             ENUM('Available','On Trip','In Garage','Retired') NOT NULL DEFAULT 'Available',
    odometer_km        DECIMAL(12,2) NOT NULL DEFAULT 0,
    target_distance_km DECIMAL(10,2) NOT NULL DEFAULT 3000.00,
    CONSTRAINT uq_vehicle_reg   UNIQUE (registration_number),
    CONSTRAINT chk_vehicle_year CHECK (year_manufactured BETWEEN 1990 AND 2030),
    CONSTRAINT chk_vehicle_cap  CHECK (capacity_tonnes > 0),
    CONSTRAINT chk_vehicle_cost CHECK (purchase_cost_ugx > 0),
    CONSTRAINT chk_vehicle_odo  CHECK (odometer_km >= 0),
    CONSTRAINT chk_vehicle_target CHECK (target_distance_km > 0)
) ENGINE=InnoDB;

/* ---------- ROUTE ----------------------------------------------- */
CREATE TABLE route (
    route_id        INT AUTO_INCREMENT PRIMARY KEY,
    route_name      VARCHAR(100) NOT NULL,
    origin          VARCHAR(80) NOT NULL,
    destination     VARCHAR(80) NOT NULL,
    distance_km     DECIMAL(10,2) NOT NULL,
    estimated_hours DECIMAL(6,2) NOT NULL,
    toll_cost_ugx   DECIMAL(10,2) NOT NULL DEFAULT 0,
    road_type       ENUM('Highway','Gravel','Urban') NOT NULL DEFAULT 'Highway',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_route_name  UNIQUE (route_name),
    CONSTRAINT chk_route_dist CHECK (distance_km > 0),
    CONSTRAINT chk_route_hrs  CHECK (estimated_hours > 0),
    CONSTRAINT chk_route_toll CHECK (toll_cost_ugx >= 0)
) ENGINE=InnoDB;

/* ---------- TRIP ------------------------------------------------- */
CREATE TABLE trip (
    trip_id             INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id          INT NOT NULL,
    driver_id           INT NOT NULL,
    route_id            INT NOT NULL,
    departure_datetime  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    arrival_datetime    DATETIME NULL,
    distance_travelled_km DECIMAL(10,2) NOT NULL,
    status              ENUM('Scheduled','In Transit','Delivered','Delayed','Cancelled') NOT NULL DEFAULT 'Scheduled',
    cargo_weight_tonnes DECIMAL(8,2) NULL,
    fuel_used_litres    DECIMAL(8,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_trip_distance CHECK (distance_travelled_km > 0),
    CONSTRAINT chk_trip_cargo    CHECK (cargo_weight_tonnes IS NULL OR cargo_weight_tonnes >= 0),
    CONSTRAINT chk_trip_fuel     CHECK (fuel_used_litres >= 0),
    CONSTRAINT chk_trip_dates    CHECK (arrival_datetime IS NULL OR arrival_datetime >= departure_datetime),
    CONSTRAINT fk_trip_vehicle FOREIGN KEY (vehicle_id)
        REFERENCES vehicle(vehicle_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trip_driver   FOREIGN KEY (driver_id)
        REFERENCES driver(driver_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_trip_route    FOREIGN KEY (route_id)
        REFERENCES route(route_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ---------- SHIPMENT (cargo booked on a trip) -------------------- */
CREATE TABLE shipment (
    shipment_id       INT AUTO_INCREMENT PRIMARY KEY,
    trip_id           INT NOT NULL,
    customer_id       INT NOT NULL,
    consignment_number VARCHAR(30) NOT NULL,
    description       VARCHAR(120) NOT NULL,
    weight_tonnes     DECIMAL(8,2) NOT NULL,
    pickup_location   VARCHAR(100) NOT NULL,
    dropoff_location  VARCHAR(100) NOT NULL,
    declared_value_ugx DECIMAL(14,2) NOT NULL,
    status            ENUM('Booked','Loaded','In Transit','Delivered','Cancelled') NOT NULL DEFAULT 'Booked',
    CONSTRAINT uq_consignment UNIQUE (consignment_number),
    CONSTRAINT chk_ship_weight CHECK (weight_tonnes >= 0),
    CONSTRAINT chk_ship_value  CHECK (declared_value_ugx > 0),
    CONSTRAINT fk_ship_trip    FOREIGN KEY (trip_id)
        REFERENCES trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ship_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ---------- MAINTENANCE ------------------------------------------ */
CREATE TABLE maintenance (
    maintenance_id  INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id      INT NOT NULL,
    service_date    DATE NOT NULL,
    service_type    ENUM('Routine','Repair','Inspection','Replacement') NOT NULL,
    odometer_km     DECIMAL(12,2) NOT NULL,
    cost_ugx        DECIMAL(12,2) NOT NULL,
    garage_name     VARCHAR(100) NOT NULL,
    next_service_date DATE NOT NULL,
    status          ENUM('Completed','Pending','Overdue') NOT NULL DEFAULT 'Completed',
    notes           VARCHAR(255),
    CONSTRAINT chk_maint_odo  CHECK (odometer_km >= 0),
    CONSTRAINT chk_maint_cost CHECK (cost_ugx > 0),
    CONSTRAINT chk_maint_next CHECK (next_service_date >= service_date),
    CONSTRAINT fk_maint_vehicle FOREIGN KEY (vehicle_id)
        REFERENCES vehicle(vehicle_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ---------- FUEL RECORD ------------------------------------------ */
CREATE TABLE fuel_record (
    fuel_id        INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id     INT NOT NULL,
    trip_id        INT NULL,
    fuel_date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    litres         DECIMAL(8,2) NOT NULL,
    cost_per_litre DECIMAL(10,2) NOT NULL,
    total_cost_ugx DECIMAL(12,2) AS (ROUND(litres * cost_per_litre, 2)) STORED,
    station_name   VARCHAR(100) NOT NULL,
    odometer_km    DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_fuel_litres CHECK (litres > 0),
    CONSTRAINT chk_fuel_price  CHECK (cost_per_litre > 0),
    CONSTRAINT chk_fuel_odo    CHECK (odometer_km >= 0),
    CONSTRAINT fk_fuel_vehicle FOREIGN KEY (vehicle_id)
        REFERENCES vehicle(vehicle_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_fuel_trip    FOREIGN KEY (trip_id)
        REFERENCES trip(trip_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ---------- EXPENSE (UNION / CATEGORY TYPE) ---------------------- */
CREATE TABLE expense (
    expense_id   INT AUTO_INCREMENT PRIMARY KEY,
    reference    VARCHAR(40) NOT NULL,
    amount_ugx   DECIMAL(14,2) NOT NULL,
    expense_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_type  ENUM('Fuel','Maintenance','Toll','Other') NOT NULL,
    fuel_id      INT NULL,
    maintenance_id INT NULL,
    source_id    INT NULL,
    status       ENUM('Completed','Pending','Failed') NOT NULL DEFAULT 'Completed',
    CONSTRAINT uq_expense_ref UNIQUE (reference),
    CONSTRAINT chk_expense_amount CHECK (amount_ugx > 0),
    CONSTRAINT chk_expense_source CHECK (
        (source_type = 'Fuel' AND fuel_id IS NOT NULL AND maintenance_id IS NULL)
        OR (source_type = 'Maintenance' AND maintenance_id IS NOT NULL AND fuel_id IS NULL)
        OR (source_type IN ('Toll','Other') AND fuel_id IS NULL AND maintenance_id IS NULL)
    ),
    CONSTRAINT fk_expense_fuel FOREIGN KEY (fuel_id)
        REFERENCES fuel_record(fuel_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_expense_maint FOREIGN KEY (maintenance_id)
        REFERENCES maintenance(maintenance_id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

/* ---------- AUDIT LOG -------------------------------------------- */
CREATE TABLE audit_log (
    audit_id           INT AUTO_INCREMENT PRIMARY KEY,
    table_name         VARCHAR(50) NOT NULL,
    operation          ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    record_id          INT NOT NULL,
    action_description VARCHAR(255) NOT NULL,
    changed_by         VARCHAR(100) NOT NULL DEFAULT 'unknown',
    changed_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

/* ---------- INDEXES ---------------------------------------------- */
CREATE INDEX idx_trip_vehicle  ON trip(vehicle_id);
CREATE INDEX idx_trip_driver   ON trip(driver_id);
CREATE INDEX idx_trip_route    ON trip(route_id);
CREATE INDEX idx_ship_trip     ON shipment(trip_id);
CREATE INDEX idx_fuel_vehicle  ON fuel_record(vehicle_id);
CREATE INDEX idx_maint_vehicle ON maintenance(vehicle_id);

/* End of 01_schema.sql */
