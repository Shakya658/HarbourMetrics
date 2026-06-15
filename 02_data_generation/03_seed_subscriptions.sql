-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 03_seed_subscriptions.sql
-- Objective: Generate historical subscription records with true row-by-row random distribution
-- ============================================================================

SET search_path TO harbourmetrics;

TRUNCATE TABLE harbourmetrics.subscriptions RESTART IDENTITY CASCADE;

WITH randomized_customers AS (
    SELECT 
        customer_id,
        signup_date,
        acquisition_channel,
        -- Force a completely unique random integer between 1 and 100 for every single row
        FLOOR(RANDOM() * 100 + 1) as rand_val
    FROM harbourmetrics.customers
)
INSERT INTO harbourmetrics.subscriptions (
    customer_id,
    plan_id,
    start_date,
    end_date,
    status,
    monthly_price,
    discount
)
SELECT 
    rc.customer_id,
    -- Assign plan weights: 1-60 (Basic), 61-90 (Pro), 91-100 (Enterprise)
    CASE 
        WHEN rc.rand_val <= 60 THEN 1
        WHEN rc.rand_val <= 90 THEN 2
        ELSE 3
    END as plan_id,
    rc.signup_date as start_date,
    NULL as end_date,
    'Active' as status,
    -- Match standard prices exactly to the plan IDs
    CASE 
        WHEN rc.rand_val <= 60 THEN 29.00
        WHEN rc.rand_val <= 90 THEN 79.00
        ELSE 199.00
    END as monthly_price,
    -- Apply random enterprise/outbound discounts (0%, 5%, 10%, 15%)
    CASE 
        WHEN rc.rand_val > 90 AND rc.acquisition_channel = 'Outbound' THEN (FLOOR(RANDOM() * 4) * 5.00)
        ELSE 0.00
    END as discount
FROM randomized_customers rc;

-- Verify the new distribution matches the CEO's original rules
SELECT 
    p.plan_name, 
    COUNT(*) as contract_count, 
    ROUND(COUNT(*)::NUMERIC / 2000 * 100, 2) as actual_percentage
FROM harbourmetrics.subscriptions s
JOIN harbourmetrics.plans p ON s.plan_id = p.plan_id
GROUP BY p.plan_name;