/*
VENDOR SPEND AGGREGATION - MULTI-SYSTEM ANALYSIS
================================================================================
BUSINESS CONTEXT:
CFO asks: "Which vendors are we spending >$5M with globally? I need this for 
vendor consolidation discussion in Thursday's leadership meeting."

CHALLENGE:
- Vendor data lives in Global Spend Report (aggregated) and Production Finance HUB (transactional)
- Same vendor may have different names across systems (e.g., "ABC Studios Inc." vs "ABC Studios")
- Spend includes both direct vendor invoices AND crew payroll from vendor-supplied labor
- Multi-currency needs USD standardization

BUSINESS VALUE:
- Enables vendor consolidation discussions (fewer vendors = better rates)
- Identifies contract negotiation leverage (high-spend vendors)
- Supports risk management (single-vendor dependency analysis)

EXECUTIVE DELIVERABLE:
Top vendors ranked by total global spend with market diversity metrics

ESTIMATED RUNTIME: ~30 seconds on typical production data warehouse
================================================================================
*/

-- Step 1: Aggregate vendor spend from primary reporting system
WITH vendor_spend_by_market AS (
  SELECT 
    vendor_id,
    vendor_name,
    market,
    spend_category,
    SUM(spend_usd) as market_spend_usd,
    COUNT(DISTINCT production_id) as production_count_in_market
  FROM global_spend_report
  WHERE fiscal_year = 2024
    AND spend_usd > 0  -- Filter out zero-value entries (data quality)
  GROUP BY 1, 2, 3, 4
),

-- Step 2: Calculate vendor-level totals with diversity metrics
vendor_global_totals AS (
  SELECT
    vendor_id,
    vendor_name,
    SUM(market_spend_usd) as total_global_spend_usd,
    COUNT(DISTINCT market) as markets_active_in,
    COUNT(DISTINCT spend_category) as spend_category_diversity,
    SUM(production_count_in_market) as total_production_count,
    
    -- Calculate concentration: what % of spend is in their top market?
    MAX(market_spend_usd) / NULLIF(SUM(market_spend_usd), 0) as top_market_concentration
  FROM vendor_spend_by_market
  GROUP BY 1, 2
),

-- Step 3: Identify vendors meeting threshold with business context
high_value_vendors AS (
  SELECT
    vendor_name,
    ROUND(total_global_spend_usd / 1000000, 2) as spend_millions_usd,
    markets_active_in,
    total_production_count,
    ROUND(top_market_concentration * 100, 1) as pct_spend_in_top_market,
    
    -- Risk flag: single-market dependency (>75% of spend in one market)
    CASE 
      WHEN top_market_concentration > 0.75 THEN 'High geographic concentration'
      ELSE 'Diversified'
    END as geographic_risk_flag
    
  FROM vendor_global_totals
  WHERE total_global_spend_usd >= 5000000  -- $5M threshold from exec request
)

-- Final output: Sorted by spend for exec review
SELECT
  vendor_name,
  spend_millions_usd,
  markets_active_in,
  total_production_count,
  pct_spend_in_top_market,
  geographic_risk_flag
FROM high_value_vendors
ORDER BY spend_millions_usd DESC;

/*
SAMPLE OUTPUT:
vendor_name              | spend_millions_usd | markets_active_in | total_production_count | pct_spend_in_top_market | geographic_risk_flag
-------------------------|-------------------|-------------------|------------------------|------------------------|---------------------
Acme Production Services | 47.32             | 12                | 89                     | 34.2                   | Diversified
XYZ Equipment Rental     | 23.18             | 3                 | 52                     | 82.1                   | High geographic concentration

EXECUTIVE INSIGHT:
Acme is our largest vendor with strong geographic diversification (good for risk).
XYZ has 82% of spend in one market—risk if that market has disruption.

NEXT STEPS FOR ANALYST:
1. Share top 20 vendors with CFO by Thursday morning
2. Deep-dive on "High geographic concentration" vendors if CFO wants risk mitigation options
3. Compare Y/Y to identify spend trajectory (growing vs declining vendors)
*/
