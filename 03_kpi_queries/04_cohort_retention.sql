-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 04_cohort_retention.sql
-- Objective: Compute B2B customer cohort retention intervals over time
-- ============================================================================

SET search_path TO harbourmetrics;

WITH cohort_sizes AS (
    -- Establish the starting baseline size for each monthly cohort group
    SELECT 
        DATE_TRUNC('month', signup_date)::DATE AS cohort_month,
        COUNT(customer_id) AS starting_cohort_size
    FROM harbourmetrics.customers
    GROUP BY 1
),
user_retention_intervals AS (
    -- Calculate how many months each customer stayed active before canceling
    SELECT 
        c.customer_id,
        DATE_TRUNC('month', c.signup_date)::DATE AS cohort_month,
        s.status,
        -- If active, they've stayed the maximum length. If canceled, calculate elapsed months
        CASE 
            WHEN s.status = 'Canceled' THEN 
                EXTRACT(YEAR FROM AGE(s.end_date, s.start_date)) * 12 + 
                EXTRACT(MONTH FROM AGE(s.end_date, s.start_date))
            ELSE 99 -- Placeholder for active accounts that haven't churned
        END AS months_retained
    FROM harbourmetrics.customers c
    JOIN harbourmetrics.subscriptions s ON c.customer_id = s.customer_id
)
SELECT 
    cs.cohort_month,
    cs.starting_cohort_size,
    
    -- Month 0 is always 100% of the starting size
    cs.starting_cohort_size AS month_0_active,
    
    -- Count users who survived past Month 1, Month 3, and Month 6
    COUNT(DISTINCT CASE WHEN uri.months_retained >= 1 THEN uri.customer_id END) AS month_1_active,
    COUNT(DISTINCT CASE WHEN uri.months_retained >= 3 THEN uri.customer_id END) AS month_3_active,
    COUNT(DISTINCT CASE WHEN uri.months_retained >= 6 THEN uri.customer_id END) AS month_6_active
FROM cohort_sizes cs
JOIN user_retention_intervals uri ON cs.cohort_month = uri.cohort_month
GROUP BY cs.cohort_month, cs.starting_cohort_size
ORDER BY cs.cohort_month DESC;