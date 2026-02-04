# Production Finance Analytics - SQL Portfolio

## Overview
This repository demonstrates SQL analysis approaches for production finance use cases at scale, including multi-system data aggregation, location cost benchmarking, and workforce trend analysis.

**Context**: These queries are designed for production finance environments managing:
- $15B+ annual content spend
- 50+ production countries
- 100+ concurrent productions
- Multi-system data sources (spend reporting, payroll, production management)

**Created by**: Sri Harshavardhan Josyula  
**Contact**: harshajosyula75@gmail.com  


---

## Repository Structure
```
production-finance-analytics/
├── queries/          # SQL analysis samples
├── schemas/          # Mock schema documentation
└── docs/             # Supporting documentation
```

---

## Query Samples

### 1. Vendor Spend Aggregation ([view query](queries/01_vendor_spend_aggregation.sql))
**Business Use Case**: CFO needs to identify high-value vendors (>$5M annual spend) for contract negotiation planning

**Key Features**:
- Multi-system data aggregation (vendor invoices + labor costs)
- Geographic diversification metrics
- Risk flagging for single-market dependency

**Output**: Ranked list of vendors with spend totals and concentration analysis

**Estimated Runtime**: ~30 seconds on production data warehouse

---

### 2. Location Cost Analysis ([view query](queries/02_location_cost_analysis.sql))
**Business Use Case**: VP of Production deciding where to film Season 2 based on cost efficiency

**Key Features**:
- Cost-per-crew-member benchmarking across locations
- Production type normalization (series vs film)
- Statistical flagging of high/low cost locations

**Output**: Location benchmarks with efficiency metrics for strategic planning

**Estimated Runtime**: ~45 seconds

---

### 3. Crew Count Trend Analysis ([view query](queries/03_crew_count_trends.sql))
**Business Use Case**: Head of Production Planning forecasting 2025 labor budget

**Key Features**:
- Quarterly trend analysis by crew category
- Normalization for production volume changes (crew-per-production metric)
- Quarter-over-quarter growth calculations

**Output**: Trend data showing which crew categories are growing fastest

**Estimated Runtime**: ~20 seconds

---

## Design Principles

### 1. Business Context First
Every query includes:
- The executive request that triggered the analysis
- The business value of the insight
- Sample output with executive-friendly interpretation

**Why**: Production finance analysis serves decision-makers who need context, not just numbers.

### 2. Speed Over Perfection
Queries prioritize:
- Fast turnaround (20-60 second runtimes)
- 80% accuracy in 20% of time
- Clear assumptions documented in comments

**Why**: Ad hoc analysis often needs directional insights quickly rather than perfect precision slowly.

### 3. Self-Documenting Code
Each query includes:
- Business context header
- Inline comments explaining logic
- Sample output with interpretation
- Next steps for analyst

**Why**: Production finance teams rotate; queries need to be maintainable by others.

### 4. Flexible Foundations
Queries use CTEs (Common Table Expressions) for:
- Easy modification of filters and thresholds
- Clear step-by-step logic flow
- Reusable components

**Why**: Executive requests evolve; "vendor spend >$5M" becomes ">$3M" the next week.

---

## Technical Notes

**SQL Dialect**: BigQuery / Snowflake style (ANSI SQL compliant)

**Mock Data**: Schemas are based on publicly available production finance system patterns. Production implementations would include:
- Additional data quality validation (NULL checks, duplicate detection)
- Currency conversion with historical exchange rates
- Historical data versioning for trend analysis
- Access control and row-level security

**Performance**: Queries assume:
- Partitioned tables by fiscal year/quarter
- Indexed on production_id, vendor_id, crew_member_id
- Pre-aggregated spend tables for faster lookups

---

## Use Cases Demonstrated

✅ **Multi-system data aggregation** (Global Spend Report + Payroll + Production HUB)  
✅ **Executive-facing analysis** (clear business context + actionable insights)  
✅ **Statistical analysis** (percentiles, trends, concentration metrics)  
✅ **Risk identification** (geographic concentration, cost outliers)  
✅ **Forecasting support** (trend extrapolation for budget planning)

---

## Related Artifacts

📄 **Production Finance Optimization Memo**: [View memo](docs/Production_Finance_Data_Workflow_-_Sample_Analysis.pdf)  
*Analysis of data workflow improvement strategies for Production Finance O&I teams*

---

## About This Portfolio

This portfolio was created as part of application materials demonstrating analytical thinking, SQL proficiency, and production finance domain knowledge.

**Skills Demonstrated**:
- Advanced SQL (CTEs, window functions, aggregations)
- Multi-system data integration
- Business context translation
- Executive communication
- Data quality awareness

---

**Contact**: harshajosyula75@gmail.com  
**Application**: Netflix Production Finance Data Analyst Role (JR38497)

*Last Updated: February 2026*
