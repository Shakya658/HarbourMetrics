-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 05_channel_performance.sql
-- Objective: Evaluate customer acquisition channel volume and total MRR contribution
-- ============================================================================

SET search_path TO harbourmetrics;

SELECT 
    c.acquisition_channel,
    -- Total volume of customers acquired through this channel
    COUNT(c.customer_id) AS total_customers_acquired,
    
    -- Total current Monthly Recurring Revenue contributed by this channel
    ROUND(SUM(s.monthly_price * (1 - (s.discount / 100))), 2) AS active_mrr_contribution,
    
    -- Average revenue per customer within this specific channel segment
    ROUND(AVG(s.monthly_price * (1 - (s.discount / 100))), 2) AS channel_arpu
FROM harbourmetrics.customers c
JOIN harbourmetrics.subscriptions s ON c.customer_id = s.customer_id
GROUP BY c.acquisition_channel
ORDER BY active_mrr_contribution DESC;