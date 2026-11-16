# 10-Slide Presentation – CSC2209 Database Programming Project
## Farmer Produce Tracking and Market Linkage Database for Mukono District

Use these slides verbatim in PowerPoint. Each slide has a title, bullet content and a presenter note.

---

### SLIDE 1 – TITLE
**Design and Implementation of a Farmer Produce Tracking and Market Linkage Database for Mukono District**

- CSC2209 Database Programming – Project-Based Exam, Advent 2026
- Domain: Agriculture and Food Systems
- SDG 2 – Zero Hunger
- Candidate: ______________ | Reg No: ______________
- Uganda Christian University – Department of Computing & Technology

*Presenter note: Introduce yourself, state the chosen domain and the SDG, and say that the system replaces paper records in Mukono.*

---

### SLIDE 2 – BACKGROUND AND PROBLEM
**The Problem on the Ground**

- Smallholder farmers in Mukono grow maize, beans, matooke, coffee, cassava and tomatoes
- Records are kept on paper: notebooks, loose slips and memory
- Consequences: lost harvest data, weak price negotiation, post-harvest food waste
- No central system links farmers → farms → crops → inputs → harvests → buyers → sales

*Presenter note: Refer to the market-day observation: overwritten figures, lost slips, unsold tomatoes left in crates.*

---

### SLIDE 3 – AIM, OBJECTIVES AND SDG MAPPING
**Aim:** Build an optimised, secure MySQL database that tracks produce and links farmers to buyers.

- Objective 1: Gather requirements from 4 stakeholders
- Objective 2: Model the data with an EERD (specialization + union type)
- Objective 3: Implement DDL, constraints and realistic data
- Objective 4: Develop queries, views, procedures and triggers
- **SDG 2 – Zero Hunger**: more produce sold, less wasted → better food security
- Indicator 1: Total harvest (kg) per farmer per season
- Indicator 2: % of harvest sold vs wasted

*Presenter note: Emphasise that both indicators are computed directly by views, not guessed.*

---

### SLIDE 4 – STAKEHOLDERS AND REQUIREMENTS
**Who Uses the System and What They Need**

| Stakeholder | Information need |
|-------------|------------------|
| Farmer | Own harvest kg, sales, prices, remaining stock |
| Cooperative Officer | Member yields, wastage reports, SDG reports |
| Buyer | Available produce, quality, price history |
| Admin | Users, privileges, backups, audit trail |

- Requirements: 10 Functional (FR1–FR10), 5 Non-Functional (NFR1–NFR5)
- 6 Business Rules, 5 Assumptions, evidence from interviews and observation

*Presenter note: Mention the three interview questions (recording harvest, deciding price, unsold produce) as evidence.*

---

### SLIDE 5 – EERD (CONCEPTUAL DESIGN)
**Seven Main Entities + Supertype, Union and Audit**

- PERSON → FARMER / BUYER: **disjoint, total specialization** with inheritance
- FARMER 1 : N FARM; FARM 1 : N HARVEST; CROP 1 : N HARVEST
- INPUT 0 : N HARVEST (optional input, SET NULL on delete)
- HARVEST 0 : N SALE; BUYER 0 : N SALE
- PAYMENT = **union/category** with discriminator `source_type`
- AUDIT_LOG records every sale insert
- Mermaid EERD code is included in the report (Part II)

*Presenter note: Point out multiplicities and participation: farm has total participation in the farmer relationship.*

---

### SLIDE 6 – DATABASE IMPLEMENTATION (DDL + DATA)
**MySQL 8.0 Schema in VS Code**

- Database: `mukono_farm_db` – 10 InnoDB tables, utf8mb4
- PK + AUTO_INCREMENT on every table; FKs with CASCADE / RESTRICT / SET NULL
- UNIQUE: phone, national ID, registration numbers, crop name, farm name
- NOT NULL and DEFAULT on required attributes
- CHECK: phone format, harvest_kg > 0, price > 0, wasted_kg ≤ harvest_kg
- 10 realistic rows per main table: names like Nalongo, Kato, Achieng; crops Maize, Beans, Matooke, Coffee
- Sale `total_amount` is a generated column = quantity × price

*Presenter note: Explain that validation is inside the database so no bad data can enter even from a bad front-end.*

---

### SLIDE 7 – QUERIES AND REPORTING VIEWS
**From Raw Data to Decisions**

- 5 SELECT queries: JOIN, GROUP BY + SUM/AVG/COUNT, subquery, CASE, built-in functions
- `vw_farmer_harvest_summary` → SDG Indicator 1 (harvest kg per farmer per season)
- `vw_sales_by_crop` → revenue and average price per crop (market linkage)
- `vw_wastage_report` → SDG Indicator 2 (% sold vs % wasted)
- Example finding: coffee has the highest revenue per kg; cassava and tomatoes show the highest wastage

*Presenter note: Run one view live, e.g. SELECT * FROM vw_wastage_report, and read a row aloud.*

---

### SLIDE 8 – DATABASE PROGRAMMING AND SECURITY
**Automation, Audit and Least Privilege**

- `get_farmer_sales(p_farmer_id)` – all sales for one farmer
- `record_sale(...)` – transaction, OUT total, error handler with ROLLBACK + RESIGNAL
- `get_sdg_report()` – SDG figures for all farmers
- Trigger 1: BEFORE INSERT on Sale – blocks overselling
- Trigger 2: AFTER INSERT on Sale – writes to AUDIT_LOG
- Users: farmer_user, officer_user, admin_user with least-privilege GRANTs
- `vw_farmer_public` hides phone and national ID
- Backup: `mysqldump ... --routines --triggers > mukono_farm_db_backup.sql`

*Presenter note: Demonstrate the oversell error and then show the audit_log row.*

---

### SLIDE 9 – TESTING
**8 Tests – All Passed**

| Test | What was tested | Result |
|------|-----------------|--------|
| T1 | Valid crop INSERT | PASS |
| T2 | Foreign key violation | Rejected – PASS |
| T3 | CHECK violation (negative kg) | Rejected – PASS |
| T4 | Oversell blocked by trigger | Blocked – PASS |
| T5 | record_sale returns correct total | PASS |
| T6 | get_sdg_report output | PASS |
| T7 | Secure view hides sensitive columns | PASS |
| T8 | Audit row created after sale | PASS |

*Presenter note: The full test plan with expected and actual results is in the report, Section 3.1.*

---

### SLIDE 10 – CONCLUSIONS AND LESSONS
**What Was Achieved**

- A central, validated database now links farmers, farms, crops, inputs, harvests, buyers and sales
- The two SDG 2 indicators are measurable and reportable
- Automation enforces business rules and keeps an audit trail
- Role-based security protects sensitive farmer data
- **Lessons:** constraints belong in the database; transactions protect multi-step operations; good design starts with stakeholder evidence
- **Recommendation:** extend with a web/mobile front-end and a district-level dashboard
- Questions welcome

*Presenter note: Thank the examiners and offer to demonstrate any SQL file live.*

---

*End of FILE: 06_presentation.md*
