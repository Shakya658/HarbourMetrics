-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 02_seed_customers.sql
-- Objective: Generate 2,000 realistic, synthetically weighted B2B customer profiles
-- ============================================================================

SET search_path TO harbourmetrics;

TRUNCATE TABLE harbourmetrics.customers RESTART IDENTITY CASCADE;

INSERT INTO harbourmetrics.customers (
    company_name, 
    industry, 
    company_size, 
    region, 
    acquisition_channel, 
    signup_date
)
SELECT 
    -- Generate realistic sounding B2B company names
    'Client_' || i || ' ' || (ARRAY['Corp', 'Inc', 'Solutions', 'Holdings', 'Logistics', 'Tech'])[FLOOR(RANDOM() * 6 + 1)],
    
    -- Weighted Industries
    (ARRAY['Tech', 'Tech', 'Retail', 'Retail', 'Finance', 'Healthcare', 'Education'])[FLOOR(RANDOM() * 7 + 1)],
    
    -- Weighted Company Sizes (More Startups/SMBs than Enterprises)
    (ARRAY['Startup', 'Startup', 'SMB', 'SMB', 'Mid-Market', 'Enterprise'])[FLOOR(RANDOM() * 6 + 1)],
    
    -- Regions (Targeting key AU/NZ and global expansions)
    (ARRAY['Australia', 'Australia', 'New Zealand', 'UK', 'US'])[FLOOR(RANDOM() * 5 + 1)],
    
    -- Acquisition Channels
    (ARRAY['Paid Ads', 'Paid Ads', 'Organic', 'Organic', 'Referral', 'Outbound'])[FLOOR(RANDOM() * 6 + 1)],
    
    -- Distribute signup dates pseudo-randomly across the last 24 months (relative to mid-2026)
    (CAST('2024-06-01' AS DATE) + (RANDOM() * (CAST('2026-06-01' AS DATE) - CAST('2024-06-01' AS DATE)))::INT)
FROM generate_series(1, 2000) AS i;

-- Verify the customer count and distributions
SELECT region, COUNT(*), ROUND(COUNT(*)::NUMERIC / 2000 * 100, 2) as pct
FROM harbourmetrics.customers 
GROUP BY region;