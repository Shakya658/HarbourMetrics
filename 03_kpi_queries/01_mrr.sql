-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 01_mrr.sql
-- Objective: Calculate historical Monthly Recurring Revenue (MRR) and ARPU trends
-- ============================================================================

SET search_path TO harbourmetrics;

WITH monthly_timeline AS (
    -- Generate a continuous series of months representing our 24-month horizon
    SELECT generate_series(
        '2024-06-01'::DATE, 
        '2026-06-01'::DATE, 
        '1 month'::INTERVAL
    )::DATE AS calendar_month
),
monthly_mrr_calc AS (
    SELECT 
        t.calendar_month,
        s.customer_id,
        -- Calculate net price after subtracting applied discounts
        s.monthly_price * (1 - (s.discount / 100)) AS net_mrr
    FROM monthly_timeline t
    JOIN harbourmetrics.subscriptions s 
      ON s.start_date <= t.calendar_month  -- Subscription must have started before or during this month
     AND (s.end_date IS NULL OR s.end_date > t.calendar_month) -- And must not have churned before this month
)
SELECT 
    calendar_month AS snapshot_month,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(SUM(net_mrr), 2) AS total_mrr,
    -- Average Revenue Per User (ARPU) = Total MRR / Active Customers
    ROUND(AVG(net_mrr), 2) AS arpu
FROM monthly_mrr_calc
GROUP BY 1
ORDER BY 1 DESC;