/* ================================================================
   FILE: 01_schema.sql
   CSC2209 Database Programming – Project-Based Exam, Advent 2026
   Mukono Farmer Produce Tracking and Market Linkage Database
   MySQL 8.0 – run this file FIRST in VS Code
   ================================================================ */

DROP DATABASE IF EXISTS mukono_farm_db;
CREATE DATABASE mukono_farm_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE mukono_farm_db;

/* ----------------------------------------------------------------
   SUPERTYPE: PERSON  (generalization of FARMER and BUYER)
   Disjoint constraint: person_type is 'Farmer' or 'Buyer' for the
   two subclasses; other types (Officer, Admin) are system users.
   ---------------------------------------------------------------- */
CREATE TABLE person (
    person_id     INT AUTO_INCREMENT PRIMARY KEY,
    person_type   ENUM('Farmer','Buyer','Officer','Admin') NOT NULL,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    phone         VARCHAR(12)  NOT NULL,
    national_id   VARCHAR(20)  UNIQUE,
    gender        ENUM('Male','Female') NOT NULL,
    date_of_birth DATE         NOT NULL,
    district      VARCHAR(50)  NOT NULL DEFAULT 'Mukono',
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_person_phone UNIQUE (phone),
    CONSTRAINT chk_person_phone CHECK (phone REGEXP '^0[0-9]{9}$')
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   SUBCLASS: FARMER  (total, disjoint specialization of PERSON)
   ---------------------------------------------------------------- */
CREATE TABLE farmer (
    farmer_id          INT AUTO_INCREMENT PRIMARY KEY,
    person_id          INT          NOT NULL,
    farmer_reg_number  VARCHAR(30)  NOT NULL,
    cooperative_name   VARCHAR(100) NOT NULL DEFAULT 'Mukono Farmers Cooperative',
    years_farming      INT          NOT NULL DEFAULT 0,
    registration_date  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_farmer_person UNIQUE (person_id),
    CONSTRAINT uq_farmer_reg    UNIQUE (farmer_reg_number),
    CONSTRAINT chk_farmer_years CHECK (years_farming >= 0),
    CONSTRAINT fk_farmer_person FOREIGN KEY (person_id)
        REFERENCES person(person_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   SUBCLASS: BUYER  (disjoint with FARMER)
   ---------------------------------------------------------------- */
CREATE TABLE buyer (
    buyer_id       INT AUTO_INCREMENT PRIMARY KEY,
    person_id      INT         NOT NULL,
    buyer_type     ENUM('Individual','Cooperative','Trader','Processor','Government') NOT NULL,
    company_name   VARCHAR(100),
    license_number VARCHAR(30) UNIQUE,
    credit_rating  ENUM('A','B','C') NOT NULL DEFAULT 'B',
    CONSTRAINT uq_buyer_person UNIQUE (person_id),
    CONSTRAINT fk_buyer_person FOREIGN KEY (person_id)
        REFERENCES person(person_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   FARM – owned/managed by exactly one FARMER (total participation)
   ---------------------------------------------------------------- */
CREATE TABLE farm (
    farm_id        INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id      INT           NOT NULL,
    farm_name      VARCHAR(100)  NOT NULL,
    location       VARCHAR(100)  NOT NULL,
    sub_county     VARCHAR(100)  NOT NULL,
    size_hectares  DECIMAL(8,2)  NOT NULL,
    soil_type      ENUM('Loamy','Clay','Sandy','Volcanic') NOT NULL DEFAULT 'Loamy',
    irrigation     BOOLEAN       NOT NULL DEFAULT FALSE,
    latitude       DECIMAL(9,6)  NULL,
    longitude      DECIMAL(9,6)  NULL,
    CONSTRAINT uq_farm_name UNIQUE (farmer_id, farm_name),
    CONSTRAINT chk_farm_size CHECK (size_hectares > 0),
    CONSTRAINT fk_farm_farmer FOREIGN KEY (farmer_id)
        REFERENCES farmer(farmer_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   CROP – lookup/master list of crops grown in Mukono
   ---------------------------------------------------------------- */
CREATE TABLE crop (
    crop_id               INT AUTO_INCREMENT PRIMARY KEY,
    crop_name             VARCHAR(50) NOT NULL,
    crop_type             ENUM('Cereal','Legume','Fruit','Cash Crop','Vegetable','Tuber') NOT NULL,
    growing_season        ENUM('Season A','Season B','Both') NOT NULL DEFAULT 'Both',
    expected_yield_kg_ha  DECIMAL(10,2) NOT NULL,
    is_perennial          BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_crop_name UNIQUE (crop_name),
    CONSTRAINT chk_crop_yield CHECK (expected_yield_kg_ha > 0)
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   INPUT – seeds, fertilisers, pesticides used in production
   ---------------------------------------------------------------- */
CREATE TABLE input (
    input_id     INT AUTO_INCREMENT PRIMARY KEY,
    input_name   VARCHAR(80)  NOT NULL,
    input_type   ENUM('Seed','Fertilizer','Pesticide','Herbicide','Other') NOT NULL,
    unit         VARCHAR(30)  NOT NULL DEFAULT 'kg',
    unit_cost_ugx DECIMAL(12,2) NOT NULL,
    supplier     VARCHAR(100) DEFAULT 'Mukono Agro Inputs Ltd',
    CONSTRAINT uq_input_name UNIQUE (input_name),
    CONSTRAINT chk_input_cost CHECK (unit_cost_ugx > 0)
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   HARVEST – output of a farm for a crop in a season
   ---------------------------------------------------------------- */
CREATE TABLE harvest (
    harvest_id        INT AUTO_INCREMENT PRIMARY KEY,
    farm_id           INT           NOT NULL,
    crop_id           INT           NOT NULL,
    input_id          INT           NULL,
    season            VARCHAR(20)   NOT NULL,
    harvest_date      DATE          NOT NULL,
    harvest_kg        DECIMAL(10,2) NOT NULL,
    wasted_kg         DECIMAL(10,2) NOT NULL DEFAULT 0,
    unit_price_ugx    DECIMAL(12,2) NOT NULL,
    quality_grade     ENUM('A','B','C') NOT NULL DEFAULT 'B',
    CONSTRAINT uq_harvest_unique UNIQUE (farm_id, crop_id, season),
    CONSTRAINT chk_harvest_kg   CHECK (harvest_kg > 0),
    CONSTRAINT chk_wasted_kg    CHECK (wasted_kg >= 0),
    CONSTRAINT chk_wasted_le_total CHECK (wasted_kg <= harvest_kg),
    CONSTRAINT chk_harvest_price CHECK (unit_price_ugx > 0),
    CONSTRAINT fk_harvest_farm  FOREIGN KEY (farm_id)
        REFERENCES farm(farm_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_harvest_crop  FOREIGN KEY (crop_id)
        REFERENCES crop(crop_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_harvest_input FOREIGN KEY (input_id)
        REFERENCES input(input_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   SALE – a buyer purchases part of a harvest.
   total_amount is a STORED generated column (data validation).
   ---------------------------------------------------------------- */
CREATE TABLE sale (
    sale_id         INT AUTO_INCREMENT PRIMARY KEY,
    harvest_id      INT           NOT NULL,
    buyer_id        INT           NOT NULL,
    sale_date       DATE          NOT NULL,
    quantity_kg     DECIMAL(10,2) NOT NULL,
    price_per_kg    DECIMAL(12,2) NOT NULL,
    total_amount    DECIMAL(14,2) AS (ROUND(quantity_kg * price_per_kg, 2)) STORED,
    payment_status  ENUM('Pending','Paid','Partial') NOT NULL DEFAULT 'Pending',
    payment_method  ENUM('Cash','Bank Transfer','Mobile Money') NOT NULL DEFAULT 'Mobile Money',
    CONSTRAINT chk_sale_qty   CHECK (quantity_kg > 0),
    CONSTRAINT chk_sale_price CHECK (price_per_kg > 0),
    CONSTRAINT fk_sale_harvest FOREIGN KEY (harvest_id)
        REFERENCES harvest(harvest_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_sale_buyer   FOREIGN KEY (buyer_id)
        REFERENCES buyer(buyer_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   PAYMENT – UNION / CATEGORY type.
   A payment may come from a Sale, an Input Purchase, or Other source.
   source_type is the discriminator; sale_id is populated only when
   source_type = 'Sale' (enforced by the CHECK constraint).
   ---------------------------------------------------------------- */
CREATE TABLE payment (
    payment_id       INT AUTO_INCREMENT PRIMARY KEY,
    payment_reference VARCHAR(40) NOT NULL,
    amount_ugx       DECIMAL(14,2) NOT NULL,
    payment_date     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method   ENUM('Cash','Bank Transfer','Mobile Money','Cheque') NOT NULL,
    source_type      ENUM('Sale','Input Purchase','Other') NOT NULL,
    sale_id          INT         NULL,
    source_id        INT         NULL,
    status           ENUM('Completed','Pending','Failed') NOT NULL DEFAULT 'Completed',
    CONSTRAINT uq_payment_ref UNIQUE (payment_reference),
    CONSTRAINT chk_payment_amount CHECK (amount_ugx > 0),
    CONSTRAINT chk_payment_source CHECK (
        (source_type = 'Sale' AND sale_id IS NOT NULL)
        OR (source_type <> 'Sale' AND sale_id IS NULL)
    ),
    CONSTRAINT fk_payment_sale FOREIGN KEY (sale_id)
        REFERENCES sale(sale_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   AUDIT_LOG – history mechanism populated by the AFTER INSERT trigger
   ---------------------------------------------------------------- */
CREATE TABLE audit_log (
    audit_id           INT AUTO_INCREMENT PRIMARY KEY,
    table_name         VARCHAR(50)  NOT NULL,
    operation          ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    record_id          INT          NOT NULL,
    action_description VARCHAR(255) NOT NULL,
    changed_by         VARCHAR(100) NOT NULL DEFAULT 'unknown',
    changed_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

/* ----------------------------------------------------------------
   HELPER INDEXES (performance / NFR2)
   ---------------------------------------------------------------- */
CREATE INDEX idx_harvest_farm  ON harvest(farm_id);
CREATE INDEX idx_harvest_crop  ON harvest(crop_id);
CREATE INDEX idx_sale_harvest  ON sale(harvest_id);
CREATE INDEX idx_sale_buyer    ON sale(buyer_id);
CREATE INDEX idx_farm_farmer   ON farm(farmer_id);

/* End of 01_schema.sql */
