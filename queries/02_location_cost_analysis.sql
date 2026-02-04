/*
LOCATION ECONOMICS - COST EFFICIENCY ANALYSIS
================================================================================
BUSINESS CONTEXT:
VP of Production asks: "We're deciding where to film Season 2. Should we stick 
with Location A or shift to Location B? I need cost per crew member and total 
cost benchmarks by location type."

CHALLENGE:
- Crew costs (payroll) live in one system, vendor costs in another
- Location "efficiency" depends on production type (series vs film have different crew ratios)
- Currency and cost-of-living differences across markets
- Need to compare apples-to-apples (similar production types)

BUSINESS VALUE:
- Informs location strategy ($5-10M+ decision per production)
- Identifies cost outliers (locations that are unusually expensive/cheap)
- Supports vendor negotiations ("Market rate in this location is X")

EXECUTIVE DELIVERABLE:
Location benchmarks with cost-per-crew-member for strategic planning

ESTIMATED RUNTIME: ~45 seconds
================================================================================
*/

-- Step 1: Combine crew and vendor costs at production level
WITH production_location_costs AS (
  SELECT
    production_id,
    production_title,
    production_type,
    production_location,
    production_year,
    
    -- Aggregate crew metrics
    COUNT(DISTINCT crew_member_id) as unique_crew_count,
    SUM(crew_payroll_usd) as total_crew_payroll_usd,
    
    -- Aggregate vendor spend
    SUM(vendor_spend_usd) as total_vendor_spend_usd,
    
    -- Total location cost (crew + vendors)
    SUM(crew_payroll_usd + vendor_spend_usd) as total_location_cost_usd
    
  FROM production_finance_hub
  WHERE production_year = 2024
    AND production_location IS NOT NULL
    AND crew_payroll_usd > 0  -- Filter incomplete records
  GROUP BY 1, 2, 3, 4, 5
),

-- Step 2: Calculate location benchmarks by production type
location_benchmarks AS (
  SELECT
    production_location,
    production_type,
    
    -- Volume metrics
    COUNT(DISTINCT production_id) as production_count,
    SUM(unique_crew_count) as total_crew_across_productions,
    
    -- Cost metrics (averages for benchmarking)
    ROUND(AVG(unique_crew_count), 0) as avg_crew_size,
    ROUND(AVG(total_location_cost_usd), 0) as avg_total_cost_per_production,
    ROUND(AVG(total_crew_payroll_usd), 0) as avg_crew_payroll_per_production,
    ROUND(AVG(total_vendor_spend_usd), 0) as avg_vendor_spend_per_production,
    
    -- Efficiency metric: cost per crew member
    ROUND(AVG(total_location_cost_usd / NULLIF(unique_crew_count, 0)), 0) as avg_cost_per_crew_member,
    
    -- Breakdown: what % of cost is crew vs vendor?
    ROUND(AVG(total_crew_payroll_usd / NULLIF(total_location_cost_usd, 0)) * 100, 1) as pct_cost_is_crew
    
  FROM production_location_costs
  GROUP BY 1, 2
  HAVING COUNT(DISTINCT production_id) >= 3  -- Need 3+ productions for valid benchmark
),

-- Step 3: Add context flags for executive review
location_analysis AS (
  SELECT
    production_location,
    production_type,
    production_count,
    avg_crew_size,
    avg_total_cost_per_production,
    avg_cost_per_crew_member,
    pct_cost_is_crew,
    
    -- Flag high-cost locations (top 25% by cost-per-crew)
    CASE 
      WHEN avg_cost_per_crew_member > 
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_cost_per_crew_member) OVER (PARTITION BY production_type)
      THEN 'High Cost'
      WHEN avg_cost_per_crew_member < 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_cost_per_crew_member) OVER (PARTITION BY production_type)
      THEN 'Low Cost'
      ELSE 'Average Cost'
    END as cost_tier
    
  FROM location_benchmarks
)

-- Final output: Show series productions (most common type)
SELECT
  production_location,
  production_count,
  avg_crew_size,
  avg_total_cost_per_production,
  avg_cost_per_crew_member,
  cost_tier
FROM location_analysis
WHERE production_type = 'series'  -- Filter to series for exec request
ORDER BY avg_cost_per_crew_member DESC;

/*
SAMPLE OUTPUT:
production_location | production_count | avg_crew_size | avg_total_cost_per_production | avg_cost_per_crew_member | cost_tier
--------------------|------------------|---------------|-------------------------------|--------------------------|----------
Los Angeles, CA     | 24               | 127           | 18500000                      | 145669                   | High Cost
Vancouver, BC       | 18               | 98            | 9200000                       | 93878                    | Average Cost
Atlanta, GA         | 15               | 104           | 8100000                       | 77885                    | Low Cost

EXECUTIVE INSIGHT:
If filming Season 2 in Atlanta vs LA, expect ~46% lower cost per crew member.
For a typical 100-person crew over 6 months, that's ~$4M in savings.

CAVEATS FOR EXEC:
- Does not account for tax incentives (add 20-30% value in some locations)
- Quality of crew talent varies by location (can't measure with cost alone)
- "Average Cost" includes productions with varying complexity

NEXT STEPS:
1. Add tax incentive data if available (manual input from Production team)
2. Segment by production budget tier (high-budget shows may skew costs)
3. Include timeline analysis (longer shoots = lower daily rate but higher total cost)
*/
