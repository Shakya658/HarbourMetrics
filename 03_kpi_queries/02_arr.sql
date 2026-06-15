-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 02_arr.sql
-- Objective: Calculate Annualized Run Rate (ARR) and Month-over-Month (MoM) Growth
-- ============================================================================

SET search_path TO harbourmetrics;

WITH monthly_timeline AS (
    SELECT generate_series('2024-06-01'::DATE, '2026-06-01'::DATE, '1 month'::INTERVAL)::DATE AS calendar_month
),
monthly_mrr_summary AS (
    SELECT 
        t.calendar_month,
        SUM(s.monthly_price * (1 - (s.discount / 100))) AS total_mrr
    FROM monthly_timeline t
    JOIN harbourmetrics.subscriptions s 
      ON s.start_date <= t.calendar_month 
     AND (s.end_date IS NULL OR s.end_date > t.calendar_month)
    GROUP BY 1
),
growth_calculations AS (
    SELECT 
        calendar_month AS snapshot_month,
        ROUND(total_mrr, 2) AS total_mrr,
        ROUND(total_mrr * 12, 2) AS total_arr,
        -- Fetch the previous month's MRR to calculate growth rate
        LAG(total_mrr) OVER (ORDER BY calendar_month) AS previous_month_mrr
    FROM monthly_mrr_summary
)
SELECT 
    snapshot_month,
    total_mrr,
    total_arr,
    ROUND(
        ((total_mrr - previous_month_mrr) / previous_month_mrr) * 100, 2
    ) AS mom_growth_percentage
FROM growth_calculations
ORDER BY snapshot_month DESC;