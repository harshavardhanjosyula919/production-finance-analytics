# Mock Schema Documentation

## Purpose
These queries demonstrate production finance analysis patterns using realistic but simplified schemas based on publicly available information about production accounting systems.

## Assumptions
- Data stored in BigQuery or Snowflake-style warehouse
- Multi-currency spend standardized to USD
- Production IDs are unique identifiers across all systems

## Core Tables

### global_spend_report
Aggregated spend data from production accounting systems.

| Column | Type | Description |
|--------|------|-------------|
| production_id | STRING | Unique production identifier |
| vendor_id | STRING | Vendor identifier |
| vendor_name | STRING | Vendor display name |
| spend_category | STRING | e.g., 'equipment', 'labor', 'post-production' |
| spend_usd | FLOAT | Spend amount in USD |
| market | STRING | Production location/market |
| fiscal_year | INT | Year of spend |
| fiscal_quarter | INT | Quarter (1-4) |

### production_finance_hub
Production-level details including crew and location data.

| Column | Type | Description |
|--------|------|-------------|
| production_id | STRING | Unique production identifier |
| production_title | STRING | Show/film title |
| production_type | STRING | 'series', 'film', 'unscripted' |
| production_location | STRING | Primary filming location |
| crew_member_id | STRING | Unique crew identifier |
| crew_role | STRING | e.g., 'director', 'dp', 'gaffer' |
| crew_payroll_usd | FLOAT | Payroll cost |
| vendor_spend_usd | FLOAT | Associated vendor spend |
| production_year | INT | Year of production |
| fiscal_quarter | INT | Quarter (1-4) |
| fiscal_year | INT | Fiscal year |

### payroll_accounting_system
Detailed payroll transaction data.

| Column | Type | Description |
|--------|------|-------------|
| transaction_id | STRING | Unique transaction ID |
| production_id | STRING | Production identifier |
| crew_member_id | STRING | Crew identifier |
| pay_period_start | DATE | Pay period start |
| pay_period_end | DATE | Pay period end |
| gross_pay_usd | FLOAT | Gross pay amount |
| tax_jurisdiction | STRING | Tax location |

## Data Quality Notes
Production implementations would include:
- NULL handling for incomplete data
- Currency conversion validation
- Duplicate detection across systems
- Historical data versioning
