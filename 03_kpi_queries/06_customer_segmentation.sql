-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 06_customer_segmentation.sql
-- Objective: Categorize accounts into behavioral health segments 
-- ============================================================================

SET search_path TO harbourmetrics;

WITH customer_tenure_calc AS (
    SELECT 
        s.customer_id,
        p.plan_name,
        s.status,
        s.monthly_price * (1 - (s.discount / 100)) AS net_mrr,
        -- Calculate total months active in system
        EXTRACT(YEAR FROM AGE(COALESCE(s.end_date, '2026-06-01'::DATE), s.start_date)) * 12 + 
        EXTRACT(MONTH FROM AGE(COALESCE(s.end_date, '2026-06-01'::DATE), s.start_date)) AS tenure_months,
        -- Check if they have an upgrade event on record
        CASE WHEN s.customer_id IN (
            SELECT customer_id FROM harbourmetrics.subscription_events WHERE event_type = 'upgrade'
        ) THEN 1 ELSE 0 END AS has_upgraded
    FROM harbourmetrics.subscriptions s
    JOIN harbourmetrics.plans p ON s.plan_id = p.plan_id
)
SELECT 
    CASE 
        WHEN status = 'Canceled' THEN 'Churned Account'
        WHEN plan_name = 'Enterprise' AND tenure_months >= 12 THEN 'Enterprise Champion'
        WHEN has_upgraded = 1 THEN 'Expansion Growth Account'
        WHEN net_mrr >= 79.00 AND tenure_months >= 6 THEN 'Core High-Value Stable'
        WHEN tenure_months < 3 THEN 'Onboarding Core (New)'
        ELSE 'Standard Active Tier'
    END AS customer_segment,
    COUNT(customer_id) AS account_count,
    ROUND(SUM(net_mrr), 2) AS total_mrr_contribution,
    ROUND(AVG(tenure_months), 1) AS average_tenure_in_months
FROM customer_tenure_calc
GROUP BY 1
ORDER BY total_mrr_contribution DESC;