# 10-Slide Presentation – Transport, Logistics and Fleet Management Database

### SLIDE 1 – TITLE
**Design and Implementation of a Vehicle Fleet Maintenance and Logistics Tracking Database for a Mukono Transport Cooperative**
- CSC2209 Database Programming – Advent 2026 | Domain: Transport, Logistics and Fleet Management
- SDG 9 – Industry, Innovation and Infrastructure
- Candidate / Reg No / UCU

### SLIDE 2 – BACKGROUND AND PROBLEM
- Mixed fleet: trucks, pickups, vans, bus, tricycles
- Paper logbooks and loose fuel receipts
- Unavailable vehicles dispatched, fuel losses, missed services, cargo disputes
- No measure of utilisation or on-time delivery

### SLIDE 3 – AIM, OBJECTIVES AND SDG 9
- Aim: optimised, secure MySQL database for fleet and logistics
- Objectives: requirements → EERD → implementation → programming → security → testing
- SDG 9: efficient, well-maintained transport supports industry and trade
- Indicator 1: Fleet Utilisation %
- Indicator 2: Fuel efficiency (km/L) and on-time delivery %

### SLIDE 4 – STAKEHOLDERS AND REQUIREMENTS
- Driver, Fleet Officer/Dispatcher, Customer, Admin
- Evidence from 3 interview questions + depot observation
- FR1–FR10, NFR1–NFR5, BR1–BR6
- Each requirement maps to a database object

### SLIDE 5 – EERD
- PERSON → DRIVER / CUSTOMER: disjoint, total specialisation with inheritance
- VEHICLE 1:N TRIP; DRIVER 1:N TRIP; ROUTE 1:N TRIP
- TRIP 1:N SHIPMENT; CUSTOMER 1:N SHIPMENT
- VEHICLE 1:N MAINTENANCE and FUEL_RECORD
- EXPENSE = union/category (`source_type`)
- AUDIT_LOG from trigger; Mermaid code in report

### SLIDE 6 – IMPLEMENTATION
- Database `transport_fleet_db` – 11 InnoDB tables
- PK/AUTO_INCREMENT, FK (CASCADE/RESTRICT/SET NULL), UNIQUE, CHECK, DEFAULT
- Generated column `total_cost_ugx` = litres × price
- 10 realistic rows per main table: Ugandan names, routes like Kampala–Jinja, plates like UBC 123A

### SLIDE 7 – QUERIES AND VIEWS
- 5 queries: JOIN, GROUP BY + SUM/AVG/COUNT, subquery, CASE, built-in functions
- `vw_vehicle_utilization` → SDG Indicator 1
- `vw_fuel_efficiency` → km per litre
- `vw_delivery_performance` → on-time %
- `get_sdg_report()` returns all three KPIs

### SLIDE 8 – PROGRAMMING AND SECURITY
- `get_driver_trips(id)`, `record_trip(...)` (transaction + OUT id), `get_sdg_report()`
- Trigger 1: BEFORE INSERT trip blocks retired vehicle / inactive driver
- Trigger 2: AFTER INSERT trip writes audit_log
- Users: driver_user, officer_user, admin_user
- `vw_driver_public` hides phone and national ID
- mysqldump backup command

### SLIDE 9 – TESTING
- 8 tests: valid insert, FK violation, CHECK violation, trigger block, procedures, secure view, audit
- All PASS (see report Section 3.1)
- Live demo: oversell-style trip with vehicle 10 → ERROR 1644

### SLIDE 10 – CONCLUSIONS
- Central validated fleet and logistics database
- Two SDG 9 indicators measurable and reportable
- Automation enforces rules and keeps audit trail
- Least-privilege security protects data
- Recommendation: add web dispatch dashboard and fuel-card integration
- Questions welcome

*End of FILE: 06_presentation.md*
