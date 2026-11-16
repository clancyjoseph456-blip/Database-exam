# CSC2209 Database Programming – Project-Based Exam (Advent 2026)
## Full Project Documentation: Mukono Farmer Produce Tracking and Market Linkage Database

**Candidate:** ____________________  **Registration No:** ____________________
**Institution:** Uganda Christian University – Department of Computing & Technology
**Domain:** Agriculture and Food Systems  |  **SDG:** SDG 2 – Zero Hunger

---

# PART I – MILESTONE ONE: PROJECT TITLE, PROBLEM DEFINITION, REQUIREMENTS SPECIFICATION AND SDG MAPPING [20 marks]

## 1.1 Project Title
**Design and Implementation of a Farmer Produce Tracking and Market Linkage Database for Mukono District.**

## 1.2 Background
Agriculture is the backbone of Mukono District's rural economy. Most smallholder farmers cultivate maize, beans, matooke, coffee, cassava and horticultural crops on plots of 1–6 hectares. Production and marketing information is still kept on paper notebooks, in farmers' memories, or on loose slips issued by produce collectors. Cooperative officers compile monthly returns manually, buyers negotiate prices without reliable historical yield data, and district agricultural officers have no up-to-date picture of what was produced, what was sold and what was lost after harvest.

A relational database can replace these fragmented paper records with a single, validated, queryable source of truth. By recording farmer, farm, crop, input, harvest, buyer and sale data in one system, the database supports data capture, retrieval, processing, reporting and decision-making as required by the examination brief.

## 1.3 Problem Statement
Smallholder farmers in Mukono have no central system to record farmers, farms, crops, inputs, harvests, buyers and sales. Records are kept on paper, leading to: (a) lost or inaccurate harvest data, (b) weak bargaining power and poor pricing because farmers cannot prove historical yields or quality, (c) high post-harvest food waste because unsold produce is not identified early, and (d) inability of cooperative officers to monitor members or of the district to report on food availability. The project will design and implement a MySQL 8.0 database that captures and links all of these data, enforces business rules, automates sales recording and auditing, and produces reports that monitor SDG 2 indicators.

## 1.4 SDG Mapping
**Selected Goal: SDG 2 – Zero Hunger** ("End hunger, achieve food security and improved nutrition and promote sustainable agriculture").

**Relationship between problem and SDG:** Better harvesting records and market linkage mean more produce reaches buyers instead of rotting in the field. When farmers know what they harvested and can show it to buyers, they sell more at fair prices, income rises, and more food enters the local market – directly contributing to food security and sustainable agriculture.

**Beneficiaries:** smallholder farmers and their households, women farmer groups, cooperatives, local buyers/traders, processors, and the Mukono District Agriculture Office which uses the reports for planning.

| # | Measurable Indicator (as required) | How the database computes it | Target improvement |
|---|------------------------------------|------------------------------|--------------------|
| 1 | **Total harvest (kg) per farmer per season** | `SUM(harvest_kg)` grouped by `farmer_id` and `season` (view `vw_farmer_harvest_summary`, procedure `get_sdg_report()`) | Establish a reliable baseline for every farmer; enable yield-per-hectare comparisons and planning |
| 2 | **% of harvest sold vs wasted** | `SUM(sold_kg)/SUM(harvest_kg)*100` and `SUM(wasted_kg)/SUM(harvest_kg)*100` (view `vw_wastage_report`) | Reduce post-harvest loss to below 10% and raise the proportion marketed above 80% |

## 1.5 Stakeholders and Information Needs

| Stakeholder | Role in the system | Information needs |
|-------------|--------------------|-------------------|
| **Farmer** | Registers farm and crop details, records harvest, records sales, views own summary | Own farm sizes, harvested kg per crop/season, quantity sold, price obtained, remaining stock, wastage percentage |
| **Cooperative Officer** | Maintains farmer and farm records, validates harvest figures, monitors members, produces SDG reports | Member list, harvest totals by farmer/crop/season, sales and wastage reports, top-performing crops |
| **Buyer** | Places/purchases produce, views available harvest and prices | Crop availability, quality grade, quantity available, fair price history, purchase totals |
| **Admin (Database Administrator)** | Creates users, grants privileges, maintains schema, backs up and restores database, reviews audit log | User privileges, object integrity, backup status, audit trail of all sales (who changed what and when) |

## 1.6 Requirements Gathering Techniques and Evidence

Two techniques were used, following the examiner's guidance that evidence of the approach must be shown.

**Technique A – Semi-structured Interview.** The interviewer visited the Nakifuma farmers' market and interviewed the cooperative secretary, two farmers and one produce buyer. Each interview lasted about 20 minutes and notes were recorded in a notebook.

| # | Sample question asked | Summary of answer / evidence obtained |
|---|-----------------------|----------------------------------------|
| Q1 | "How do you currently record the kilograms harvested from each garden?" | "We write it in an exercise book after selling; sometimes the page is lost or rained on." → Need for a permanent, validated `harvest_kg` field. |
| Q2 | "How do you decide the price to pay a farmer for maize?" | "I ask what others paid last week; there is no written price history." → Need for `price_per_kg` history and `vw_sales_by_crop`. |
| Q3 | "What happens to produce that is not sold on market day?" | "It stays in the store and often rots; nobody calculates the loss." → Need for `wasted_kg` and the wastage report. |

**Technique B – Observation.** The researcher spent a market day observing record-keeping at the collection point. Evidence observed: (i) quantities were written on paper slips with no farmer ID, (ii) two slips had figures overwritten with no explanation, (iii) unsold tomatoes were left in crates at the end of the day. This confirmed the need for `NOT NULL`, `CHECK`, `UNIQUE`, foreign keys and an `audit_log` table.

**Technique C (supporting) – Document Review.** Existing cooperative monthly returns and market price lists were examined; they contained farmer names but no unique identifiers, confirming the need for `farmer_reg_number`, `national_id` and `phone` as validated data items.

## 1.7 Functional Requirements (FR1–FR10)

| ID | Functional requirement | Linked deliverable |
|----|------------------------|--------------------|
| FR1 | The system shall store person records with validated phone and national ID | `person` table, `chk_person_phone` |
| FR2 | The system shall register farmers and buyers as disjoint specializations of a person | `farmer`, `buyer` tables |
| FR3 | The system shall record one or more farms per farmer with size and location | `farm` table |
| FR4 | The system shall maintain a crop catalogue with crop type and expected yield | `crop` table |
| FR5 | The system shall record inputs (seeds, fertilisers, pesticides) and their unit costs | `input` table |
| FR6 | The system shall capture harvests with kg harvested, kg wasted, season and unit price | `harvest` table, CHECK constraints |
| FR7 | The system shall record buyers and all sales, with automatic total calculation | `sale` table, generated `total_amount` |
| FR8 | The system shall prevent a sale quantity exceeding the available harvested amount | `trg_sale_before_insert` trigger |
| FR9 | The system shall produce harvest, sales-by-crop and wastage reports for the two SDG indicators | 3 views + `get_sdg_report()` |
| FR10 | The system shall log every sale to an audit table and restrict data by user role | `trg_sale_after_insert`, users/grants, secure view |

## 1.8 Non-Functional Requirements (NFR1–NFR5)

| ID | Non-functional requirement | Measure |
|----|----------------------------|---------|
| NFR1 | **Security / least privilege** – users see only what their role requires | 3 MySQL users with different GRANTs; `vw_farmer_public` hides phone and national ID |
| NFR2 | **Performance** – report queries return within 2 seconds for 10,000+ rows | Indexes on all foreign-key columns; views pre-compute aggregates |
| NFR3 | **Reliability / recoverability** – database can be restored after failure | `mysqldump` with routines and triggers; documented restore command |
| NFR4 | **Data integrity / validity** – invalid data rejected at entry | PK, FK, UNIQUE, NOT NULL, DEFAULT, AUTO_INCREMENT and CHECK constraints |
| NFR5 | **Usability / compatibility** – runs in VS Code with MySQL 8.0 without error | Plain SQL scripts ordered 01→04; documented run instructions |

## 1.9 Business Rules

| ID | Business rule | Implemented by |
|----|---------------|----------------|
| BR1 | A phone number must be a 10-digit Ugandan number starting with 0 | `chk_person_phone` CHECK with REGEXP |
| BR2 | Harvest quantity and sale quantity and price must all be greater than zero | CHECK constraints on `harvest` and `sale` |
| BR3 | Wasted kg must not exceed harvested kg | `chk_wasted_le_total` CHECK |
| BR4 | A sale must never exceed the harvest remaining after wastage and previous sales | `trg_sale_before_insert` trigger |
| BR5 | A person cannot be both a Farmer and a Buyer (disjoint specialization) | `person_type` ENUM + UNIQUE `person_id` in both subclass tables |
| BR6 | Every sale is recorded in the audit log, and payment source type must match source | AFTER INSERT trigger + `chk_payment_source` CHECK |

## 1.10 Assumptions
A1. All farmers and buyers operate within Mukono District or its neighbouring markets.
A2. Prices are recorded in Ugandan Shillings (UGX) per kilogram at the time of sale.
A3. A season is identified by a text label such as "2026 Season A" or "2026 Season B".
A4. Each harvest row belongs to exactly one farm and one crop; the input recorded is the main input used.
A5. End users access the database through a VS Code MySQL connection; a front-end application is outside the scope of this exam.

## 1.11 Data Items to be Captured
Farmer: `farmer_id`, registration number, cooperative, years farming, person details (first name, last name, phone, national ID, gender, date of birth, district).
Farm: `farm_id`, farm name, location, sub-county, size in hectares, soil type, irrigation flag, latitude, longitude.
Crop: `crop_id`, crop name, crop type, growing season, expected yield per hectare, perennial flag.
Input: `input_id`, input name, type, unit, unit cost, supplier.
Harvest: `harvest_id`, season, harvest date, kg harvested, kg wasted, unit price, quality grade.
Buyer: `buyer_id`, buyer type, company, licence number, credit rating, person details.
Sale: `sale_id`, sale date, quantity kg, price per kg, computed total, payment status and method.
Payment/Audit: payment reference, amount, source type, audit operation, timestamp and user.

## 1.12 Expected Outputs
1. Normalised MySQL database `mukono_farm_db` with 10 tables and referential integrity.
2. Populated sample data: 10 farmers, 10 buyers, 10 farms, 10 crops, 10 inputs, 10 harvests, 10 sales and 10 payments.
3. Five SELECT queries demonstrating joins, grouping/aggregates, subquery, CASE and built-in functions.
4. Three reporting views, including two that answer the SDG indicators directly.
5. Three stored procedures, two triggers, three role-based users, a secure view and a backup command.
6. Test plan, this report, and a 10-slide presentation.

---

# PART II – MILESTONE TWO: DATABASE ANALYSIS AND DESIGN [20 marks]

## 2.1 Enhanced Entity-Relationship Diagram (Textual Description)

**Entities, identifiers and key attributes**
- **PERSON** (superclass): `person_id` PK; `person_type`, first_name, last_name, phone (UNIQUE), national_id (UNIQUE), gender, date_of_birth, district.
- **FARMER** (subclass of PERSON): `farmer_id` PK; `person_id` FK→PERSON (UNIQUE); farmer_reg_number (UNIQUE), cooperative_name, years_farming, registration_date.
- **BUYER** (subclass of PERSON): `buyer_id` PK; `person_id` FK→PERSON (UNIQUE); buyer_type, company_name, license_number, credit_rating.
- **FARM**: `farm_id` PK; `farmer_id` FK→FARMER; farm_name, location, sub_county, size_hectares, soil_type, irrigation, latitude, longitude. UNIQUE(farmer_id, farm_name).
- **CROP**: `crop_id` PK; crop_name (UNIQUE), crop_type, growing_season, expected_yield_kg_ha, is_perennial.
- **INPUT**: `input_id` PK; input_name (UNIQUE), input_type, unit, unit_cost_ugx, supplier.
- **HARVEST**: `harvest_id` PK; `farm_id` FK→FARM, `crop_id` FK→CROP, `input_id` FK→INPUT (optional); season, harvest_date, harvest_kg, wasted_kg, unit_price_ugx, quality_grade. UNIQUE(farm_id, crop_id, season).
- **SALE**: `sale_id` PK; `harvest_id` FK→HARVEST, `buyer_id` FK→BUYER; sale_date, quantity_kg, price_per_kg, total_amount (derived), payment_status, payment_method.
- **PAYMENT** (union/category): `payment_id` PK; payment_reference, amount_ugx, payment_date, payment_method, source_type (discriminator), `sale_id` FK→SALE (conditional), source_id, status.
- **AUDIT_LOG**: `audit_id` PK; table_name, operation, record_id, action_description, changed_by, changed_at.

**Relationships, multiplicities and participation**
| Relationship | Multiplicity | Participation / meaning |
|--------------|--------------|--------------------------|
| PERSON → FARMER / BUYER | 1 person : 0..1 farmer OR 0..1 buyer | **Total, disjoint specialization (d)**: every farmer/buyer must be a person; a person cannot be both. Subclasses inherit person_id, name, phone, national_id, district. |
| FARMER — FARM | 1 farmer : 1..* farms | Total participation of FARM (every farm must belong to a farmer); farmer may have several farms. |
| FARM — HARVEST | 1 farm : 0..* harvests | Partial on farm side (new farm may have no harvest); harvest total participation in farm. |
| CROP — HARVEST | 1 crop : 0..* harvests | Harvest total participation in crop; crop RESTRICT delete. |
| INPUT — HARVEST | 1 input : 0..* harvests | Optional input: `input_id` nullable, ON DELETE SET NULL (partial participation). |
| HARVEST — SALE | 1 harvest : 0..* sales | Partial participation; a harvest may be unsold. |
| BUYER — SALE | 1 buyer : 0..* sales | Partial participation; a newly registered buyer may not have purchased yet. |
| SALE — PAYMENT | 1 sale : 0..1 payment | Union/category: payment belongs to a Sale **or** to another source identified by `source_type`. |
| SALE — AUDIT_LOG | 1 sale : 0..* audit entries | Every sale insert creates one audit row (trigger). |

## 2.2 Specialization, Inheritance and Disjoint Constraint
PERSON is the supertype. FARMER and BUYER are its subtypes. The `person_type` attribute acts as the disjoint discriminator: 'Farmer' or 'Buyer'. Both subtype tables carry `person_id` as a UNIQUE foreign key so inheritance of person attributes is achieved by joining on `person_id` (e.g. `SELECT ... FROM farmer f JOIN person p ON f.person_id = p.person_id`). Because a `person_id` may appear in at most one of `farmer` and `buyer`, the constraints are **disjoint (d)** and **total** for the two subclasses (Officer and Admin are non-subclass person types used by the system).

## 2.3 Union / Category Type (Payment)
PAYMENT models a **category (union) type**: its supertype instances are drawn from different underlying types. The discriminator `source_type` is 'Sale', 'Input Purchase' or 'Other'. When `source_type = 'Sale'`, `sale_id` is a foreign key to SALE; otherwise `sale_id` is NULL and `source_id` holds the identifier of the other source. The CHECK constraint `chk_payment_source` enforces this rule, demonstrating union-type integrity.

## 2.4 Mermaid EERD Code

```mermaid
erDiagram
    PERSON ||--o| FARMER : "disjoint specialization (total)"
    PERSON ||--o| BUYER  : "disjoint specialization (total)"
    FARMER ||--|{ FARM   : "owns 1:N (total on FARM)"
    FARM   ||--o{ HARVEST : "produces 1:N"
    CROP   ||--o{ HARVEST : "grown as 1:N"
    INPUT  ||--o{ HARVEST : "applied to 0:N (optional)"
    HARVEST ||--o{ SALE   : "sold through 0:N"
    BUYER  ||--o{ SALE   : "purchases 0:N"
    SALE   ||--o| PAYMENT : "union/category: source_type"
    SALE   ||--o{ AUDIT_LOG : "logged by trigger"

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
        timestamp created_at
    }
    FARMER {
        int farmer_id PK
        int person_id FK_UK
        string farmer_reg_number UK
        string cooperative_name
        int years_farming
        timestamp registration_date
    }
    BUYER {
        int buyer_id PK
        int person_id FK_UK
        enum buyer_type
        string company_name
        string license_number UK
        enum credit_rating
    }
    FARM {
        int farm_id PK
        int farmer_id FK
        string farm_name
        string location
        string sub_county
        decimal size_hectares
        enum soil_type
        boolean irrigation
        decimal latitude
        decimal longitude
    }
    CROP {
        int crop_id PK
        string crop_name UK
        enum crop_type
        enum growing_season
        decimal expected_yield_kg_ha
        boolean is_perennial
    }
    INPUT {
        int input_id PK
        string input_name UK
        enum input_type
        string unit
        decimal unit_cost_ugx
        string supplier
    }
    HARVEST {
        int harvest_id PK
        int farm_id FK
        int crop_id FK
        int input_id FK
        string season
        date harvest_date
        decimal harvest_kg
        decimal wasted_kg
        decimal unit_price_ugx
        enum quality_grade
    }
    SALE {
        int sale_id PK
        int harvest_id FK
        int buyer_id FK
        date sale_date
        decimal quantity_kg
        decimal price_per_kg
        decimal total_amount
        enum payment_status
        enum payment_method
    }
    PAYMENT {
        int payment_id PK
        string payment_reference UK
        decimal amount_ugx
        timestamp payment_date
        enum payment_method
        enum source_type
        int sale_id FK
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

## 2.5 Data Dictionary

| Table | Field | Type | Constraint | Meaning |
|-------|-------|------|------------|---------|
| person | person_id | INT | PK, AUTO_INCREMENT | Unique identifier for every person |
| person | person_type | ENUM('Farmer','Buyer','Officer','Admin') | NOT NULL | Discriminator for specialization |
| person | first_name | VARCHAR(50) | NOT NULL | Given name |
| person | last_name | VARCHAR(50) | NOT NULL | Family name |
| person | phone | VARCHAR(12) | NOT NULL, UNIQUE, CHECK REGEXP '^0[0-9]{9}$' | Ugandan mobile number |
| person | national_id | VARCHAR(20) | UNIQUE | National identity number |
| person | gender | ENUM('Male','Female') | NOT NULL | Gender |
| person | date_of_birth | DATE | NOT NULL, CHECK < CURDATE() | Date of birth |
| person | district | VARCHAR(50) | NOT NULL, DEFAULT 'Mukono' | District of residence |
| person | created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation time |
| farmer | farmer_id | INT | PK, AUTO_INCREMENT | Unique farmer identifier (used across all files) |
| farmer | person_id | INT | FK→person, UNIQUE, NOT NULL | Inherited person identity |
| farmer | farmer_reg_number | VARCHAR(30) | NOT NULL, UNIQUE | Cooperative registration number |
| farmer | cooperative_name | VARCHAR(100) | NOT NULL, DEFAULT | Farmer's cooperative |
| farmer | years_farming | INT | NOT NULL, DEFAULT 0, CHECK >=0 | Farming experience |
| farmer | registration_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Date joined system |
| buyer | buyer_id | INT | PK, AUTO_INCREMENT | Unique buyer identifier |
| buyer | person_id | INT | FK→person, UNIQUE, NOT NULL | Inherited person identity |
| buyer | buyer_type | ENUM | NOT NULL | Individual/Cooperative/Trader/Processor/Government |
| buyer | company_name | VARCHAR(100) | NULL | Organisation represented |
| buyer | license_number | VARCHAR(30) | UNIQUE | Trading licence |
| buyer | credit_rating | ENUM('A','B','C') | NOT NULL, DEFAULT 'B' | Buyer credit grade |
| farm | farm_id | INT | PK, AUTO_INCREMENT | Unique farm identifier |
| farm | farmer_id | INT | FK→farmer, NOT NULL, ON DELETE CASCADE | Owner of the farm |
| farm | farm_name | VARCHAR(100) | NOT NULL, UNIQUE(farmer_id,farm_name) | Name of farm |
| farm | location | VARCHAR(100) | NOT NULL | Village/town |
| farm | sub_county | VARCHAR(100) | NOT NULL | Sub-county in Mukono |
| farm | size_hectares | DECIMAL(8,2) | NOT NULL, CHECK >0 | Farm size |
| farm | soil_type | ENUM | NOT NULL, DEFAULT 'Loamy' | Soil classification |
| farm | irrigation | BOOLEAN | NOT NULL, DEFAULT FALSE | Irrigation availability |
| farm | latitude | DECIMAL(9,6) | NULL | GPS latitude |
| farm | longitude | DECIMAL(9,6) | NULL | GPS longitude |
| crop | crop_id | INT | PK, AUTO_INCREMENT | Unique crop identifier |
| crop | crop_name | VARCHAR(50) | NOT NULL, UNIQUE | Crop name e.g. Maize |
| crop | crop_type | ENUM | NOT NULL | Cereal/Legume/Fruit/Cash Crop/Vegetable/Tuber |
| crop | growing_season | ENUM | NOT NULL, DEFAULT 'Both' | Season A / B / Both |
| crop | expected_yield_kg_ha | DECIMAL(10,2) | NOT NULL, CHECK >0 | Benchmark yield per hectare |
| crop | is_perennial | BOOLEAN | NOT NULL, DEFAULT FALSE | Perennial flag |
| input | input_id | INT | PK, AUTO_INCREMENT | Unique input identifier |
| input | input_name | VARCHAR(80) | NOT NULL, UNIQUE | Input product name |
| input | input_type | ENUM | NOT NULL | Seed/Fertilizer/Pesticide/Herbicide/Other |
| input | unit | VARCHAR(30) | NOT NULL, DEFAULT 'kg' | Unit of measure |
| input | unit_cost_ugx | DECIMAL(12,2) | NOT NULL, CHECK >0 | Cost per unit (UGX) |
| input | supplier | VARCHAR(100) | NULL | Supplier name |
| harvest | harvest_id | INT | PK, AUTO_INCREMENT | Unique harvest identifier |
| harvest | farm_id | INT | FK→farm, NOT NULL, CASCADE | Source farm |
| harvest | crop_id | INT | FK→crop, NOT NULL, RESTRICT | Crop harvested |
| harvest | input_id | INT | FK→input, NULL, SET NULL | Main input applied |
| harvest | season | VARCHAR(20) | NOT NULL | e.g. '2026 Season A' |
| harvest | harvest_date | DATE | NOT NULL | Date of harvesting |
| harvest | harvest_kg | DECIMAL(10,2) | NOT NULL, CHECK >0 | Total kg harvested (SDG indicator 1) |
| harvest | wasted_kg | DECIMAL(10,2) | NOT NULL, DEFAULT 0, CHECK >=0, <=harvest_kg | Post-harvest loss (SDG indicator 2) |
| harvest | unit_price_ugx | DECIMAL(12,2) | NOT NULL, CHECK >0 | Expected price per kg |
| harvest | quality_grade | ENUM('A','B','C') | NOT NULL, DEFAULT 'B' | Quality grade |
| sale | sale_id | INT | PK, AUTO_INCREMENT | Unique sale identifier |
| sale | harvest_id | INT | FK→harvest, NOT NULL, RESTRICT | Harvest being sold |
| sale | buyer_id | INT | FK→buyer, NOT NULL, RESTRICT | Purchasing buyer |
| sale | sale_date | DATE | NOT NULL | Date of sale |
| sale | quantity_kg | DECIMAL(10,2) | NOT NULL, CHECK >0 | Kg sold |
| sale | price_per_kg | DECIMAL(12,2) | NOT NULL, CHECK >0 | Agreed price per kg |
| sale | total_amount | DECIMAL(14,2) | GENERATED AS (qty*price) STORED | Auto-computed sale value |
| sale | payment_status | ENUM | NOT NULL, DEFAULT 'Pending' | Paid/Partial/Pending |
| sale | payment_method | ENUM | NOT NULL, DEFAULT 'Mobile Money' | Cash/Bank/Mobile Money |
| payment | payment_id | INT | PK, AUTO_INCREMENT | Unique payment identifier |
| payment | payment_reference | VARCHAR(40) | NOT NULL, UNIQUE | Human-readable receipt number |
| payment | amount_ugx | DECIMAL(14,2) | NOT NULL, CHECK >0 | Amount paid |
| payment | payment_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Payment timestamp |
| payment | payment_method | ENUM | NOT NULL | Payment channel |
| payment | source_type | ENUM | NOT NULL | Union discriminator |
| payment | sale_id | INT | FK→sale, NULL (conditional) | Sale being settled when source_type='Sale' |
| payment | source_id | INT | NULL | Identifier for non-sale source |
| payment | status | ENUM | NOT NULL, DEFAULT 'Completed' | Payment status |
| audit_log | audit_id | INT | PK, AUTO_INCREMENT | Unique audit entry |
| audit_log | table_name | VARCHAR(50) | NOT NULL | Table affected |
| audit_log | operation | ENUM | NOT NULL | INSERT/UPDATE/DELETE |
| audit_log | record_id | INT | NOT NULL | PK value of affected row |
| audit_log | action_description | VARCHAR(255) | NOT NULL | Description of change |
| audit_log | changed_by | VARCHAR(100) | NOT NULL, DEFAULT 'unknown' | MySQL user from USER() |
| audit_log | changed_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Time of change |

---

# PART III – MILESTONE FIVE: TESTING, DOCUMENTATION, PRESENTATION AND DEMONSTRATION [20 marks]

## 3.1 Test Plan (8 Tests)

| Test ID | Test case / action | Expected result | Actual result | Pass/Fail |
|---------|--------------------|-----------------|---------------|-----------|
| T1 | Valid INSERT of a new crop (`INSERT IGNORE INTO crop('Avocado',...)`) | Row accepted; `crop_id` auto-increments | Row inserted as expected | **PASS** |
| T2 | FK violation: `INSERT INTO harvest(farm_id=999,...)` | Error 1452 – foreign key constraint fails | Rejected with FK error | **PASS** |
| T3 | CHECK violation: `INSERT INTO harvest(harvest_kg=-5,...)` | Error 3819 – `chk_harvest_kg` violated | Rejected with CHECK error | **PASS** |
| T4 | Trigger blocking oversell: `INSERT INTO sale(harvest_id=1, quantity_kg=99999,...)` | Error 1644 – 'Oversell blocked...' from `trg_sale_before_insert` | Sale blocked; no row inserted | **PASS** |
| T5 | Procedure test: `CALL record_sale(1,1,100.00,@total);` | Sale inserted, `@total = 135000.00`, payment row created, audit row added | `@total` returned 135000.00; audit_log +1 row | **PASS** |
| T6 | `CALL get_sdg_report();` | 10 farmer rows with total_harvest_kg, pct_sold, pct_wasted | Report returned correctly | **PASS** |
| T7 | Secure view: `SELECT * FROM vw_farmer_public;` as farmer_user | Returns farmer names/district only; phone and national_id absent | Sensitive columns not present | **PASS** |
| T8 | Audit trigger: after any sale insert, `SELECT * FROM audit_log` | New row with operation='INSERT', changed_by = current MySQL user | Audit row present with correct details | **PASS** |

## 3.2 Ten-Page Report Outline (as required, not more than 10 pages)

| Page | Content |
|------|---------|
| 1 | Title page: project title, candidate name, registration number, institution, SDG |
| 2 | Chapter 1 – Introduction: background, problem statement, aim and objectives |
| 3 | Chapter 1 (cont.) – SDG 2 mapping, indicators, beneficiaries, scope and assumptions |
| 4 | Chapter 2 – Requirements: stakeholders, interview/observation evidence, FR1–FR10, NFR1–NFR5, business rules |
| 5 | Chapter 3 – Conceptual design: EERD, specialization, union type, multiplicities |
| 6 | Chapter 3 (cont.) – Logical design: relational schema and data dictionary |
| 7 | Chapter 4 – Implementation: DDL, constraints, sample data, queries and views |
| 8 | Chapter 5 – Database programming: procedures, triggers, security and backup |
| 9 | Chapter 6 – Testing and results: test plan table and discussion |
| 10 | Chapter 7 – Conclusions, recommendations, references and appendices |

## 3.3 Full Text – Chapters 1 to 3

### CHAPTER ONE: INTRODUCTION

**1.1 Background of the Study**
Mukono District's smallholder farmers produce a wide range of food and cash crops but manage their records manually. The absence of a central database means that yield, sale and loss data are either lost or never analysed. This project applies database programming concepts to build a reliable information system for produce tracking and market linkage, aligned to SDG 2 – Zero Hunger.

**1.2 Problem Statement**
The core problem is the absence of a central system to record farmers, farms, crops, inputs, harvests, buyers and sales. Paper records cause lost harvest data, weak pricing and food waste. The project addresses this by implementing a structured MySQL database with validation, automation, security, and SDG-focused reporting.

**1.3 Aim and Objectives**
The aim is to design and implement an optimised, secure and functional database application for Mukono's smallholder farmers. The specific objectives are: (i) to gather and document requirements from the four key stakeholders; (ii) to model the data with an EERD including specialization and a union type; (iii) to implement the database in MySQL 8.0 with constraints and realistic data; (iv) to develop queries, views, stored procedures and triggers; (v) to secure the database with role-based access and audit mechanisms; and (vi) to test, document and present the solution.

**1.4 Significance of the Study**
Farmers gain accurate yield records and better bargaining power. Buyers gain price history and reliable supply information. Cooperative officers gain monitoring reports, and the district can measure food security using the two SDG indicators. The audit log strengthens accountability.

**1.5 Scope and Assumptions**
The system stores data only; a graphical front-end is outside scope. All prices are in UGX per kg, and data is accessed through VS Code with a MySQL 8.0 connection. Full assumptions are listed in Part I, Section 1.10.

**1.6 SDG Alignment**
The database directly supports SDG 2 by enabling measurement of total harvest per farmer per season (Indicator 1) and the percentage of harvest sold versus wasted (Indicator 2). These are implemented in `vw_farmer_harvest_summary`, `vw_wastage_report` and `get_sdg_report()`.

### CHAPTER TWO: REQUIREMENTS AND STAKEHOLDERS

**2.1 Stakeholders**
Four user groups were identified: Farmer, Cooperative Officer, Buyer and Admin. Their roles and information needs are detailed in Part I, Section 1.5. Each group maps to a MySQL user or view: farmer_user, officer_user, admin_user and the secure view `vw_farmer_public`.

**2.2 Requirements Elicitation**
Semi-structured interviews and direct observation were used. Three interview questions and the observed evidence are documented in Part I, Section 1.6. The evidence justified the need for unique identifiers, validated numeric fields and an audit trail.

**2.3 Functional and Non-Functional Requirements**
Ten functional requirements FR1–FR10 and five non-functional requirements NFR1–NFR5 were derived; they are listed in Part I, Sections 1.7 and 1.8. Every requirement is traceable to a database object: for example FR8 maps to trigger `trg_sale_before_insert` and NFR4 to the CHECK constraints.

**2.4 Business Rules**
Six business rules BR1–BR6 govern phone format, positive quantities, wastage limits, oversell prevention, disjoint specialization and audit/payment integrity. They appear in Part I, Section 1.9 and are enforced by constraints and triggers.

### CHAPTER THREE: DATABASE DESIGN

**3.1 Conceptual Design (EERD)**
The EERD contains seven main entities (Farmer, Farm, Crop, Input, Harvest, Buyer, Sale) plus PERSON as supertype, PAYMENT as union/category and AUDIT_LOG as a history entity. PERSON specialises into FARMER and BUYER with a disjoint, total constraint and attribute inheritance. A farm belongs to exactly one farmer; a harvest belongs to one farm and one crop, with an optional input. A harvest may generate zero to many sales and a buyer may make zero to many sales. PAYMENT uses `source_type` as a discriminator, and every sale insert writes an AUDIT_LOG entry. The complete textual EERD and Mermaid diagram are given in Part II, Sections 2.1–2.4.

**3.2 Logical Design and Referential Integrity**
The EERD maps to ten relational tables. Primary keys use AUTO_INCREMENT integers; foreign keys use ON DELETE CASCADE where child rows are meaningless without the parent (farm, harvest, farmer, buyer), RESTRICT where historical records must be preserved (sale→harvest/buyer, harvest→crop), and SET NULL for the optional input relationship. UNIQUE constraints prevent duplicate registration numbers, phone numbers, crop names and farm names. These choices directly satisfy business rules BR1–BR6 and the reporting needs identified in Milestone One.

**3.3 Data Dictionary**
The data dictionary in Part II, Section 2.5 documents every field, type, constraint and meaning, and uses the same column names throughout all SQL files (for example `farmer_id`, `harvest_id`, `buyer_id`, `sale_id`).

**3.4 Design Validation Against Requirements**
Referential integrity protects data consistency (NFR4). Indexes on foreign-key columns satisfy NFR2. The secure view and GRANT statements satisfy NFR1. The `mysqldump` command satisfies NFR3. The two SDG views satisfy the indicators set out in Section 1.4.

## 3.4 Five Defense Questions and Model Answers

**Q1. Why did you use a PERSON supertype instead of storing farmer and buyer details in one table?**
**A:** Farmers and buyers share attributes (name, phone, national ID, district) but have different exclusive attributes (farmer_reg_number and cooperative versus buyer_type, licence and credit rating). A supertype/subtype avoids repeating the shared columns, prevents a person being both a farmer and a buyer through the `person_type` discriminator (disjoint constraint), and allows inheritance by joining on `person_id`. It also reduces null values and enforces BR5.

**Q2. How does your database guarantee that a farmer cannot sell more than was harvested?**
**A:** Trigger `trg_sale_before_insert` fires before each sale insert. It reads `harvest_kg - wasted_kg` from the harvest row and subtracts the SUM of any previous sales for that harvest. If the new `quantity_kg` exceeds the remaining amount, the trigger issues `SIGNAL SQLSTATE '45000'` with the message 'Oversell blocked...', so MySQL aborts the insert. Test T4 demonstrates this. CHECK constraints additionally guarantee positive quantity and price, and that wastage never exceeds the harvest.

**Q3. What is a union/category type in your design and where is it used?**
**A:** A union (category) type is a supertype whose instances come from different subtypes. PAYMENT is our union type: `source_type` is the discriminator ('Sale', 'Input Purchase', 'Other'). When the source is a Sale, `sale_id` is a real foreign key; otherwise `sale_id` is NULL and `source_id` holds the external identifier. The CHECK constraint `chk_payment_source` enforces the rule so a payment cannot point to a sale while claiming another source.

**Q4. How did you implement security and the principle of least privilege?**
**A:** I created three users. `farmer_user` can only SELECT from the secure `vw_farmer_public` view and the harvest summary view, plus INSERT/SELECT on `sale`; the secure view deliberately omits `phone` and `national_id`. `officer_user` can read the three reporting views and maintain harvest/sale data but has no access to user administration. `admin_user` has full privileges for maintenance and backup. FLUSH PRIVILEGES applies the changes. The audit trigger records every sale with the MySQL user from `USER()`.

**Q5. How do your reports answer the SDG 2 indicators, and how would you recover the database after a crash?**
**A:** Indicator 1 (total harvest kg per farmer per season) is produced by `vw_farmer_harvest_summary` and `get_sdg_report()`, grouping SUM(harvest_kg) by farmer and season. Indicator 2 (percentage sold vs wasted) is produced by `vw_wastage_report`, computing SUM(sold_kg)/SUM(harvest_kg)*100 and SUM(wasted_kg)/SUM(harvest_kg)*100. For recovery I use `mysqldump -u root -p --databases mukono_farm_db --routines --triggers --events > mukono_farm_db_backup.sql`; restoring is done with `mysql -u root -p < mukono_farm_db_backup.sql`, which also restores procedures and triggers. The audit_log table provides a secondary history of significant changes.

---

*End of FILE: 05_report.md*
