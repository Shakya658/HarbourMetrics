-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 03_churn_demographics.sql
-- Objective: Analyze Churn Volumes and Gross Revenue Loss across Tiers
-- ============================================================================

SET search_path TO harbourmetrics;

SELECT 
    p.plan_name,
    -- Total count of users who ever signed up for this tier
    COUNT(s.customer_id) AS total_historical_signups,
    
    -- Count of users within this tier who canceled
    COUNT(CASE WHEN s.status = 'Canceled' THEN 1 END) AS total_churned_customers,
    
    -- Churn rate per tier
    ROUND(
        (COUNT(CASE WHEN s.status = 'Canceled' THEN 1 END)::NUMERIC / 
         COUNT(s.customer_id)) * 100, 2
    ) AS tier_churn_rate_percentage,
    
    -- Monthly recurring revenue lost due to these departures
    ROUND(
        SUM(CASE WHEN s.status = 'Canceled' THEN s.monthly_price * (1 - (s.discount / 100)) ELSE 0 END), 2
    ) AS gross_mrr_lost
FROM harbourmetrics.subscriptions s
JOIN harbourmetrics.plans p ON s.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY gross_mrr_lost DESC;