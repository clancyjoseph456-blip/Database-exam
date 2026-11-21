# CSC2209 Database Programming – Project-Based Exam (Advent 2026)
## Full Project Documentation: Transport, Logistics and Fleet Management Database

**Candidate:** ____________________  **Registration No:** ____________________
**Institution:** Uganda Christian University – Department of Computing & Technology
**Domain:** Transport, Logistics and Fleet Management  |  **SDG:** SDG 9 – Industry, Innovation and Infrastructure

---

# PART I – MILESTONE ONE: PROJECT TITLE, PROBLEM, REQUIREMENTS AND SDG MAPPING [20 marks]

## 1.1 Project Title
**Design and Implementation of a Vehicle Fleet Maintenance and Logistics Tracking Database for a Mukono Transport Cooperative.**

## 1.2 Background
A transport cooperative operating between Mukono, Kampala and eastern Uganda runs trucks, pickups, vans, a bus and tricycles. Vehicles, drivers, routes, trips, cargo, fuel and maintenance are still recorded in paper logbooks and Excel sheets. Office staff cannot tell which vehicle is available, whether a driver is licensed and active, how much fuel a trip consumed, or which services are overdue. Delayed deliveries, fuel losses and unplanned downtime are common, and there is no reliable measure of fleet productivity.

## 1.3 Problem Statement
The cooperative has no central system to record vehicles, drivers, customers, routes, trips, shipments, fuel and maintenance. Paper records cause: (a) unauthorised use of vehicles and trips assigned to inactive drivers or vehicles in the garage, (b) fuel theft and unknown fuel efficiency, (c) missed maintenance leading to breakdowns, (d) lost cargo records and disputed deliveries, and (e) no way to measure fleet utilisation or on-time delivery. This project implements a MySQL 8.0 database that captures and links all these data, enforces operational rules with constraints and triggers, and reports the SDG 9 indicators.

## 1.4 SDG Mapping
**Selected Goal: SDG 9 – Industry, Innovation and Infrastructure** ("Build resilient infrastructure, promote inclusive and sustainable industrialisation and foster innovation"). Reliable, well-maintained transport infrastructure and efficient logistics are essential for trade and economic growth in Mukono.

**Beneficiaries:** the cooperative and its members, drivers, customers (traders, cooperatives, government departments, NGOs), and the district planning office which needs transport and infrastructure data.

| # | Measurable Indicator | How the database computes it | Target improvement |
|---|----------------------|------------------------------|--------------------|
| 1 | **Fleet Utilisation %** – distance travelled per vehicle against target distance | `SUM(distance_travelled_km)/target_distance_km*100` in `vw_vehicle_utilization` | Raise average utilisation above 85% by eliminating idle vehicles |
| 2 | **Fuel efficiency (km/L) and on-time delivery %** | `SUM(km)/SUM(litres)` in `vw_fuel_efficiency`; `Delivered/Total trips*100` in `vw_delivery_performance` | Improve fuel efficiency to ≥4 km/L and on-time delivery to ≥90% |

## 1.5 Stakeholders

| Stakeholder | Role | Information needs |
|-------------|------|-------------------|
| **Driver** | Receives trip assignments, records fuel and delivery status | Own trips, routes, distances, fuel used, licence status |
| **Fleet Officer / Dispatcher** | Assigns vehicles and drivers, monitors trips, fuel and maintenance | Vehicle availability, driver status, trip history, fuel efficiency, overdue service list |
| **Customer** | Books cargo, tracks consignment | Consignment status, pickup/drop-off, trip progress |
| **Admin (DBA)** | Manages users, security, backup and audit | Privileges, audit trail, backup status, integrity of all records |

## 1.6 Requirements Gathering (with evidence)

**Interview – three sample questions:**
| Q | Question | Evidence obtained |
|---|----------|-------------------|
| Q1 | "How do you decide which vehicle and driver go on a trip?" | "We use whoever is around; sometimes a vehicle in the garage is sent out." → need vehicle/driver status and a BEFORE INSERT trigger. |
| Q2 | "How do you know how much fuel each trip used?" | "We buy fuel and keep the receipt in the glove box; nobody calculates km per litre." → need `fuel_record` and `vw_fuel_efficiency`. |
| Q3 | "How do you know when a vehicle is due for service?" | "We remember by memory; two trucks broke down on the road last term." → need `maintenance.next_service_date` and status. |

**Observation:** At the Mukono depot, three paper logbooks were examined. Trips were recorded without consignment numbers, fuel receipts were loose, and one vehicle marked "in garage" had a trip entry the same week. This confirmed the need for UNIQUE consignment numbers, status checks and an `audit_log`.

**Document review:** Existing vehicle registration cards and driving licences were checked → need `registration_number`, `licence_number` with UNIQUE and phone CHECK.

## 1.7 Functional Requirements FR1–FR10
| ID | Requirement |
|----|-------------|
| FR1 | Store person records with validated phone and national ID |
| FR2 | Register drivers and customers as disjoint subclasses of PERSON |
| FR3 | Maintain vehicle master data with status, odometer and target distance |
| FR4 | Maintain route master data with distance, hours and toll cost |
| FR5 | Record trips linking vehicle, driver and route |
| FR6 | Book shipments (cargo) with consignment number and customer |
| FR7 | Record maintenance and fuel consumption per vehicle |
| FR8 | Block trips using unavailable vehicles or inactive drivers |
| FR9 | Report utilisation, fuel efficiency and delivery performance |
| FR10 | Audit every trip insert and restrict access by role |

## 1.8 Non-Functional Requirements NFR1–NFR5
| ID | Requirement |
|----|-------------|
| NFR1 | Least privilege: three users; secure view hides driver phone/national ID |
| NFR2 | Performance: indexes on all FK columns; report queries <2s |
| NFR3 | Recoverability: mysqldump with routines, triggers and events |
| NFR4 | Integrity: PK, FK, UNIQUE, NOT NULL, DEFAULT, AUTO_INCREMENT, CHECK |
| NFR5 | Compatibility: runs in VS Code / MySQL 8.0+ without error |

## 1.9 Business Rules BR1–BR6
| ID | Rule |
|----|------|
| BR1 | Phone must be 10 digits starting with 0 (CHECK REGEXP) |
| BR2 | Distance, tonnage, cost, litres and price must be > 0 |
| BR3 | Arrival datetime must not be earlier than departure |
| BR4 | A trip requires an Available vehicle and an Active driver (trigger) |
| BR5 | A person cannot be both Driver and Customer (disjoint specialisation) |
| BR6 | Expense source type must match its source (union CHECK); every trip is audited |

## 1.10 Assumptions
A1. All operations are based in Mukono with routes to Kampala and eastern Uganda.
A2. Costs are in Ugandan Shillings; distances in kilometres; fuel in litres.
A3. `target_distance_km` is the planned distance for the reporting period (October 2026) per vehicle.
A4. "On-time" is measured as trip status = Delivered.
A5. No front-end is required; data is accessed via VS Code MySQL.

## 1.11 Data Items
Driver: licence number, class, date hired, status, experience. Customer: type, company, account, credit rating. Vehicle: registration, type, make/model, year, capacity, fuel type, purchase details, status, odometer, target. Route: name, origin, destination, distance, hours, toll, road type. Trip: vehicle, driver, route, departure/arrival, distance, status, cargo, fuel. Shipment: consignment number, description, weight, locations, value, status. Maintenance: date, type, odometer, cost, garage, next service, status. Fuel: litres, price, total, station, odometer. Expense: reference, amount, source type.

## 1.12 Expected Outputs
Normalised `transport_fleet_db` (11 tables), 10 rows per main table, 5 SELECT queries, 3 SDG views + secure view, 3 procedures, 2 triggers, 3 users, audit log, backup command, test plan, report and 10-slide presentation.

---

# PART II – MILESTONE TWO: DATABASE ANALYSIS AND DESIGN [20 marks]

## 2.1 EERD (Textual Description)
- **PERSON** (superclass): `person_id` PK; person_type, name, phone UNIQUE, national_id UNIQUE, gender, DOB, district.
- **DRIVER** (subclass): `driver_id` PK; `person_id` FK UNIQUE; licence_number UNIQUE, licence_class, date_hired, driver_status, years_experience.
- **CUSTOMER** (subclass): `customer_id` PK; `person_id` FK UNIQUE; customer_type, company_name, account_number UNIQUE, credit_rating.
- **VEHICLE**: `vehicle_id` PK; registration_number UNIQUE, vehicle_type, make, model, year, capacity, fuel_type, purchase data, status, odometer, target_distance_km.
- **ROUTE**: `route_id` PK; route_name UNIQUE, origin, destination, distance_km, estimated_hours, toll_cost, road_type, is_active.
- **TRIP**: `trip_id` PK; `vehicle_id` FK, `driver_id` FK, `route_id` FK; datetime fields, distance, status, cargo, fuel.
- **SHIPMENT**: `shipment_id` PK; `trip_id` FK CASCADE, `customer_id` FK RESTRICT; consignment_number UNIQUE, weight, value, status.
- **MAINTENANCE**: `maintenance_id` PK; `vehicle_id` FK CASCADE; service date/type, odometer, cost, garage, next_service_date, status.
- **FUEL_RECORD**: `fuel_id` PK; `vehicle_id` FK CASCADE, `trip_id` FK SET NULL; litres, price, generated total_cost, station, odometer.
- **EXPENSE** (union/category): `expense_id` PK; reference UNIQUE, amount, source_type discriminator, `fuel_id` FK RESTRICT, `maintenance_id` FK RESTRICT, source_id, status.
- **AUDIT_LOG**: `audit_id` PK; table, operation, record_id, description, changed_by, changed_at.

**Relationships / multiplicities / participation**
| Relationship | Multiplicity | Participation |
|--------------|--------------|---------------|
| PERSON → DRIVER / CUSTOMER | 1:0..1 each | **Total, disjoint** specialisation (d), inheritance of person attributes |
| VEHICLE — TRIP | 1:0..* | Trip total in vehicle; RESTRICT delete |
| DRIVER — TRIP | 1:0..* | Trip total in driver; active driver required |
| ROUTE — TRIP | 1:0..* | Trip total in route |
| TRIP — SHIPMENT | 1:0..* | Shipment total in trip; CASCADE delete |
| CUSTOMER — SHIPMENT | 1:0..* | Partial (new customer may have no shipment) |
| VEHICLE — MAINTENANCE | 1:0..* | Partial; CASCADE delete |
| VEHICLE — FUEL_RECORD | 1:0..* | Partial; CASCADE delete |
| TRIP — FUEL_RECORD | 1:0..1 | Optional (SET NULL on trip delete) |
| FUEL/MAINTENANCE — EXPENSE | 1:0..1 | Union/category controlled by `source_type` |
| TRIP — AUDIT_LOG | 1:0..* | AFTER INSERT trigger writes one audit row |

## 2.2 Specialisation / Inheritance / Disjoint
PERSON is the supertype; DRIVER and CUSTOMER are disjoint subtypes discriminated by `person_type`. Each subtype stores `person_id` as UNIQUE FK, so inherited attributes are retrieved by joining (e.g. `driver d JOIN person p ON d.person_id=p.person_id`). A person cannot appear in both subtype tables.

## 2.3 Union / Category Type (Expense)
EXPENSE is a category (union) type whose instances come from different sources. `source_type` is the discriminator: 'Fuel' → `fuel_id` FK populated; 'Maintenance' → `maintenance_id` FK populated; 'Toll'/'Other' → `source_id` holds an external reference. `chk_expense_source` enforces the rule. FKs use RESTRICT so the CHECK and FK do not conflict in MySQL 8.4.

## 2.4 Mermaid EERD

```mermaid
erDiagram
    PERSON ||--o| DRIVER : "disjoint specialization (total)"
    PERSON ||--o| CUSTOMER : "disjoint specialization (total)"
    VEHICLE ||--o{ TRIP : "assigned to 0:N"
    DRIVER ||--o{ TRIP : "drives 0:N"
    ROUTE ||--o{ TRIP : "followed by 0:N"
    TRIP ||--o{ SHIPMENT : "carries 0:N"
    CUSTOMER ||--o{ SHIPMENT : "books 0:N"
    VEHICLE ||--o{ MAINTENANCE : "serviced 0:N"
    VEHICLE ||--o{ FUEL_RECORD : "refuelled 0:N"
    TRIP ||--o| FUEL_RECORD : "consumed 0:1"
    FUEL_RECORD ||--o| EXPENSE : "union/category"
    MAINTENANCE ||--o| EXPENSE : "union/category"
    TRIP ||--o{ AUDIT_LOG : "logged by trigger"
    PERSON {
        int person_id PK
        enum person_type "discriminator d"
        string first_name
        string last_name
        string phone UK
        string national_id UK
        enum gender
        date date_of_birth
        string district
    }
    DRIVER {
        int driver_id PK
        int person_id FK_UK
        string licence_number UK
        enum licence_class
        date date_hired
        enum driver_status
        int years_experience
    }
    CUSTOMER {
        int customer_id PK
        int person_id FK_UK
        enum customer_type
        string company_name
        string account_number UK
        enum credit_rating
    }
    VEHICLE {
        int vehicle_id PK
        string registration_number UK
        enum vehicle_type
        string make
        string model
        int year_manufactured
        decimal capacity_tonnes
        enum fuel_type
        date purchase_date
        decimal purchase_cost_ugx
        enum status
        decimal odometer_km
        decimal target_distance_km
    }
    ROUTE {
        int route_id PK
        string route_name UK
        string origin
        string destination
        decimal distance_km
        decimal estimated_hours
        decimal toll_cost_ugx
        enum road_type
        boolean is_active
    }
    TRIP {
        int trip_id PK
        int vehicle_id FK
        int driver_id FK
        int route_id FK
        datetime departure_datetime
        datetime arrival_datetime
        decimal distance_travelled_km
        enum status
        decimal cargo_weight_tonnes
        decimal fuel_used_litres
    }
    SHIPMENT {
        int shipment_id PK
        int trip_id FK
        int customer_id FK
        string consignment_number UK
        string description
        decimal weight_tonnes
        string pickup_location
        string dropoff_location
        decimal declared_value_ugx
        enum status
    }
    MAINTENANCE {
        int maintenance_id PK
        int vehicle_id FK
        date service_date
        enum service_type
        decimal odometer_km
        decimal cost_ugx
        string garage_name
        date next_service_date
        enum status
    }
    FUEL_RECORD {
        int fuel_id PK
        int vehicle_id FK
        int trip_id FK
        datetime fuel_date
        decimal litres
        decimal cost_per_litre
        decimal total_cost_ugx
        string station_name
        decimal odometer_km
    }
    EXPENSE {
        int expense_id PK
        string reference UK
        decimal amount_ugx
        enum source_type
        int fuel_id FK
        int maintenance_id FK
        int source_id
        enum status
    }
    AUDIT_LOG {
        int audit_id PK
        string table_name
        enum operation
        int record_id
        string action_description
        string changed_by
        timestamp changed_at
    }
```

## 2.5 Data Dictionary (key fields)
| Table | Field | Type | Constraint | Meaning |
|-------|-------|------|------------|---------|
| person | person_id | INT | PK, AUTO_INCREMENT | Person identifier |
| person | person_type | ENUM | NOT NULL | Driver/Customer/Staff discriminator |
| person | phone | VARCHAR(12) | UNIQUE, CHECK REGEXP | 10-digit phone |
| person | national_id | VARCHAR(20) | UNIQUE | National ID |
| driver | driver_id | INT | PK, AUTO_INCREMENT | Driver identifier |
| driver | person_id | INT | FK→person, UNIQUE | Inherited identity |
| driver | licence_number | VARCHAR(30) | UNIQUE | Driving licence |
| driver | driver_status | ENUM | NOT NULL, DEFAULT 'Active' | Active/Suspended/On Leave |
| customer | customer_id | INT | PK | Customer identifier |
| customer | account_number | VARCHAR(30) | UNIQUE | Billing account |
| vehicle | vehicle_id | INT | PK | Vehicle identifier |
| vehicle | registration_number | VARCHAR(20) | UNIQUE | Plate number |
| vehicle | capacity_tonnes | DECIMAL(8,2) | CHECK >0 | Load capacity |
| vehicle | status | ENUM | DEFAULT 'Available' | Availability state |
| vehicle | odometer_km | DECIMAL(12,2) | CHECK >=0 | Current mileage |
| vehicle | target_distance_km | DECIMAL(10,2) | CHECK >0 | Planned km for reporting period (SDG indicator 1) |
| route | route_id | INT | PK | Route identifier |
| route | distance_km | DECIMAL(10,2) | CHECK >0 | Route length |
| route | toll_cost_ugx | DECIMAL(10,2) | CHECK >=0, DEFAULT 0 | Toll charge |
| trip | trip_id | INT | PK | Trip identifier |
| trip | vehicle_id | INT | FK→vehicle RESTRICT | Vehicle used |
| trip | driver_id | INT | FK→driver RESTRICT | Driver assigned |
| trip | route_id | INT | FK→route RESTRICT | Route followed |
| trip | distance_travelled_km | DECIMAL(10,2) | CHECK >0 | Actual km |
| trip | status | ENUM | DEFAULT 'Scheduled' | Trip outcome |
| trip | fuel_used_litres | DECIMAL(8,2) | CHECK >=0 | Fuel consumed |
| shipment | shipment_id | INT | PK | Cargo identifier |
| shipment | consignment_number | VARCHAR(30) | UNIQUE | Tracking number |
| shipment | weight_tonnes | DECIMAL(8,2) | CHECK >0 | Cargo weight |
| maintenance | maintenance_id | INT | PK | Service identifier |
| maintenance | cost_ugx | DECIMAL(12,2) | CHECK >0 | Service cost |
| maintenance | next_service_date | DATE | CHECK ≥ service_date | Due date |
| fuel_record | fuel_id | INT | PK | Fuel entry identifier |
| fuel_record | litres | DECIMAL(8,2) | CHECK >0 | Fuel volume |
| fuel_record | total_cost_ugx | DECIMAL(12,2) | GENERATED (litres×price) | Auto cost |
| expense | expense_id | INT | PK | Expense identifier |
| expense | source_type | ENUM | NOT NULL | Union discriminator |
| expense | fuel_id / maintenance_id | INT | FK RESTRICT, conditional | Union source links |
| audit_log | audit_id | INT | PK | Audit entry identifier |

---

# PART III – MILESTONE FIVE: TESTING, DOCUMENTATION, DEFENSE [20 marks]

## 3.1 Test Plan (8 Tests)
| ID | Test | Expected | Actual | Result |
|----|------|----------|--------|--------|
| T1 | Valid INSERT of new route | Accepted | Inserted | PASS |
| T2 | FK violation: trip with vehicle_id=999 | ERROR 1452 | Rejected | PASS |
| T3 | CHECK violation: negative distance | ERROR 3819 | Rejected | PASS |
| T4 | Trigger: trip with Retired vehicle 10 / Suspended driver 10 | ERROR 1644 | Blocked | PASS |
| T5 | `CALL record_trip(1,1,1,25.00,@tid)` | @tid returned, vehicle set On Trip | Works | PASS |
| T6 | `CALL get_sdg_report()` | 3 indicator rows | Works | PASS |
| T7 | `DESC vw_driver_public` as driver_user | no phone/national_id | Sensitive columns absent | PASS |
| T8 | `SELECT * FROM audit_log` after trip insert | new INSERT row | Present | PASS |

## 3.2 Ten-Page Report Outline
| Page | Content |
|------|---------|
| 1 | Title page |
| 2 | Ch1 Background and problem |
| 3 | Ch1 Aim, objectives, SDG 9 mapping |
| 4 | Ch2 Stakeholders, elicitation, FR/NFR, business rules |
| 5 | Ch3 Conceptual EERD, specialisation, union type |
| 6 | Ch3 Logical schema and data dictionary |
| 7 | Ch4 Implementation: DDL, constraints, data, queries, views |
| 8 | Ch5 Programming: procedures, triggers, security, backup |
| 9 | Ch6 Testing and results |
| 10 | Ch7 Conclusions, recommendations, references |

## 3.3 Chapters 1–3 (Full Text)

### CHAPTER ONE – INTRODUCTION
**1.1 Background:** Mukono's transport cooperative operates a mixed fleet between Mukono, Kampala and eastern Uganda. Paper logbooks cannot provide reliable information on vehicle availability, fuel use or maintenance, so the cooperative cannot measure productivity or control costs.

**1.2 Problem Statement:** There is no central system for vehicles, drivers, customers, routes, trips, shipments, fuel and maintenance. This causes unauthorised trips, fuel losses, missed servicing, cargo disputes and no measure of fleet utilisation or on-time delivery.

**1.3 Aim and Objectives:** To design and implement an optimised, secure MySQL database for fleet and logistics tracking. Objectives: gather requirements; model with EERD incl. specialisation and union type; implement DDL, constraints and data; develop queries, views, procedures and triggers; secure with roles and audit; test and document.

**1.4 Significance:** Drivers get clear assignments; dispatchers get availability and fuel data; customers can track cargo; management can measure SDG 9 indicators and reduce costs.

**1.5 Scope and Assumptions:** Database only, no front-end; UGX/km/litre units; monthly target distance per vehicle; accessed via VS Code MySQL. See 1.10.

**1.6 SDG Alignment:** SDG 9 is supported by efficient, well-maintained transport infrastructure. Indicator 1 (fleet utilisation %) is computed by `vw_vehicle_utilization`; Indicator 2 (fuel efficiency and on-time delivery %) by `vw_fuel_efficiency` and `vw_delivery_performance`, all exposed through `get_sdg_report()`.

### CHAPTER TWO – REQUIREMENTS
**2.1 Stakeholders:** Driver, Fleet Officer/Dispatcher, Customer and Admin map to `driver_user`, `officer_user`, `admin_user` and the secure `vw_driver_public`.
**2.2 Elicitation:** Interviews and observation produced evidence for status checks, fuel tracking and service due dates (Section 1.6).
**2.3 Requirements:** FR1–FR10 and NFR1–NFR5 (Sections 1.7–1.8) are traceable to database objects: FR8 → `trg_trip_before_insert`; NFR1 → grants and secure view.
**2.4 Business Rules:** BR1–BR6 are enforced by CHECK, UNIQUE, FK and triggers (Section 1.9).

### CHAPTER THREE – DATABASE DESIGN
**3.1 Conceptual Design:** Seven main entities (Vehicle, Driver, Route, Trip, Shipment, Maintenance, FuelRecord) plus PERSON supertype, EXPENSE union/category and AUDIT_LOG. PERSON→DRIVER/CUSTOMER is disjoint and total with inheritance. A trip requires an available vehicle and active driver; a shipment belongs to one trip and one customer; EXPENSE uses `source_type` as discriminator.
**3.2 Logical Design:** Eleven InnoDB tables. FKs use CASCADE where child rows lose meaning (shipment, maintenance, fuel), RESTRICT where history must be preserved (trip→vehicle/driver/route), and SET NULL for the optional trip link in fuel. UNIQUE prevents duplicate plates, licences, accounts and consignment numbers; CHECK enforces BR1–BR3 and BR6.
**3.3 Data Dictionary:** Section 2.5 documents all fields and uses identical column names across all SQL files.
**3.4 Validation:** Referential integrity satisfies NFR4; indexes satisfy NFR2; grants/secure view satisfy NFR1; mysqldump satisfies NFR3; the three views satisfy the SDG indicators.

## 3.4 Five Defense Questions and Model Answers

**Q1. Why use a PERSON supertype for Driver and Customer?**
A: They share name, phone, national ID and district but have different exclusive attributes. A supertype removes duplication and nulls, and the `person_type` discriminator enforces the disjoint rule (a person cannot be both). Inheritance is implemented with `person_id` FK and joins. Demonstrate with `DESC person; DESC driver; DESC customer;` and a three-way join returning zero rows.

**Q2. How do you prevent a trip being assigned to a retired vehicle or suspended driver?**
A: `trg_trip_before_insert` reads `vehicle.status` and `driver.driver_status` before insert. If the vehicle is not 'Available' or the driver is not 'Active', it issues SIGNAL SQLSTATE '45000' and MySQL rejects the row. Demonstrate with `INSERT INTO trip(vehicle_id,driver_id,route_id,distance_travelled_km) VALUES (10,1,1,25);` → ERROR 1644.

**Q3. What is a union/category type in your design?**
A: EXPENSE. Its `source_type` discriminator decides which underlying source applies: 'Fuel' uses `fuel_id`, 'Maintenance' uses `maintenance_id`, 'Toll'/'Other' uses `source_id`. `chk_expense_source` enforces the rule. Demonstrate by inserting a 'Fuel' expense with NULL fuel_id → ERROR 3819.

**Q4. How is security implemented?**
A: Three least-privilege users: driver_user (secure view + trip SELECT/INSERT), officer_user (operational tables and reports), admin_user (full control). `vw_driver_public` omits phone and national ID. Demonstrate: `SHOW GRANTS FOR 'driver_user'@'localhost';` and `DESC vw_driver_public;` (no sensitive columns). The AFTER INSERT trigger logs every trip with `USER()`.

**Q5. How do the SDG 9 indicators work and how do you recover the database?**
A: `vw_vehicle_utilization` computes SUM(distance)/target*100; `vw_fuel_efficiency` computes SUM(km)/SUM(litres); `vw_delivery_performance` computes Delivered/Total*100; `get_sdg_report()` returns all three averages. Recovery uses `mysqldump --databases transport_fleet_db --routines --triggers --events > backup.sql` and `mysql < backup.sql`.

---

*End of FILE: 05_report.md*
