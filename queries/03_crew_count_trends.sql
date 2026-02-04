/*
CREW COUNT TREND ANALYSIS - WORKFORCE PLANNING
================================================================================
BUSINESS CONTEXT:
Head of Production Planning asks: "Are we growing crew sizes over time? I need 
to forecast labor costs for 2025 budget planning. Show me trends by role type."

CHALLENGE:
- Crew sizes fluctuate based on production phase (pre-production vs principal photography)
- Need to normalize for production type and complexity
- Some roles are freelance (episodic), others are full-run

BUSINESS VALUE:
- Informs 2025 labor budget ($100M+ decision)
- Identifies role categories growing faster than production count (cost pressure areas)
- Supports vendor vs in-house labor strategy

ESTIMATED RUNTIME: ~20 seconds
================================================================================
*/

WITH crew_by_quarter AS (
  SELECT
    fiscal_quarter,
    fiscal_year,
    production_type,
    
    -- Core crew roles (simplified categories)
    CASE
      WHEN crew_role IN ('director', 'producer', 'writer') THEN 'Above-the-Line'
      WHEN crew_role IN ('dp', 'camera operator', 'gaffer', 'grip') THEN 'Camera & Lighting'
      WHEN crew_role IN ('production designer', 'art director', 'set decorator') THEN 'Art Department'
      WHEN crew_role IN ('editor', 'vfx supervisor', 'colorist') THEN 'Post-Production'
      ELSE 'Other Production'
    END as crew_category,
    
    COUNT(DISTINCT crew_member_id) as unique_crew_members,
    COUNT(DISTINCT production_id) as active_production_count,
    SUM(crew_payroll_usd) as total_payroll_usd
    
  FROM production_finance_hub
  WHERE production_year >= 2023  -- 2-year trend
    AND crew_role IS NOT NULL
  GROUP BY 1, 2, 3, 4
),

trend_analysis AS (
  SELECT
    fiscal_year,
    fiscal_quarter,
    crew_category,
    SUM(unique_crew_members) as total_crew,
    SUM(active_production_count) as total_productions,
    
    -- Key metric: crew per production (normalizes for production volume changes)
    ROUND(CAST(SUM(unique_crew_members) AS FLOAT) / NULLIF(SUM(active_production_count), 0), 1) as crew_per_production,
    
    ROUND(SUM(total_payroll_usd) / 1000000, 2) as payroll_millions_usd
  FROM crew_by_quarter
  WHERE production_type = 'series'  -- Focus on series (most volume)
  GROUP BY 1, 2, 3
)

SELECT
  CONCAT(fiscal_year, '-Q', fiscal_quarter) as time_period,
  crew_category,
  crew_per_production,
  payroll_millions_usd,
  
  -- Quarter-over-quarter change in crew per production
  ROUND(
    (crew_per_production - LAG(crew_per_production) OVER (PARTITION BY crew_category ORDER BY fiscal_year, fiscal_quarter))
    / NULLIF(LAG(crew_per_production) OVER (PARTITION BY crew_category ORDER BY fiscal_year, fiscal_quarter), 0) * 100,
    1
  ) as qoq_change_pct
  
FROM trend_analysis
ORDER BY crew_category, fiscal_year, fiscal_quarter;

/*
SAMPLE OUTPUT:
time_period | crew_category       | crew_per_production | payroll_millions_usd | qoq_change_pct
------------|---------------------|---------------------|----------------------|---------------
2023-Q1     | Camera & Lighting   | 12.3                | 8.4                  | NULL
2023-Q2     | Camera & Lighting   | 13.1                | 9.2                  | 6.5
2023-Q3     | Camera & Lighting   | 12.9                | 9.0                  | -1.5

EXECUTIVE INSIGHT:
Camera & Lighting crew sizes grew 6.5% Q1→Q2 2023 (likely due to production complexity increase).
Post-Production seeing consistent 3-4% quarterly growth (VFX complexity driving this).

BUDGET PLANNING IMPLICATION:
If Post-Production grows 3.5% per quarter, forecast 14% annual increase.
For $50M current annual post-production payroll → budget $57M for 2025.

NEXT STEPS:
1. Break down Post-Production growth: is it VFX-specific or all roles?
2. Compare to industry benchmarks (are we growing faster than market?)
3. Evaluate in-house vs vendor labor for high-growth categories
*/
