-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 07_event_history_validation.sql
-- Objective: Compare current dashboard MRR logic with event-sourced history
-- Safety: Read-only validation. This script contains no INSERT, UPDATE, DELETE,
--         TRUNCATE, ALTER or DROP statements.
-- ============================================================================

SET search_path TO harbourmetrics;

-- -----------------------------------------------------------------------------
-- RESULT 1: Monthly comparison
--
-- The existing method reproduces the logic used by 01_mrr.sql: it reads the
-- current subscription plan and price for every historical month.
--
-- The event-sourced method reconstructs the latest lifecycle state that existed
-- on each monthly snapshot date and prices that historical plan using plans.
--
-- Both methods use the first day of each month so this audit remains directly
-- comparable with the existing dashboard query.
-- -----------------------------------------------------------------------------
WITH monthly_timeline AS (
    SELECT GENERATE_SERIES(
        '2024-06-01'::DATE,
        '2026-06-01'::DATE,
        '1 month'::INTERVAL
    )::DATE AS snapshot_month
),
existing_customer_month AS (
    SELECT
        mt.snapshot_month,
        s.customer_id,
        s.plan_id AS existing_plan_id,
        s.monthly_price * (1 - COALESCE(s.discount, 0) / 100.0) AS existing_mrr
    FROM monthly_timeline AS mt
    JOIN harbourmetrics.subscriptions AS s
      ON s.start_date <= mt.snapshot_month
     AND (s.end_date IS NULL OR s.end_date > mt.snapshot_month)
),
event_customer_state AS (
    SELECT
        mt.snapshot_month,
        s.customer_id,
        s.discount,
        lifecycle.event_type,
        lifecycle.new_plan_id AS historical_plan_id
    FROM monthly_timeline AS mt
    JOIN harbourmetrics.subscriptions AS s
      ON s.start_date <= mt.snapshot_month
    JOIN LATERAL (
        SELECT
            se.event_type,
            se.new_plan_id
        FROM harbourmetrics.subscription_events AS se
        WHERE se.customer_id = s.customer_id
          AND se.event_date <= mt.snapshot_month
        ORDER BY se.event_date DESC, se.event_id DESC
        LIMIT 1
    ) AS lifecycle ON TRUE
),
event_customer_month AS (
    SELECT
        ecs.snapshot_month,
        ecs.customer_id,
        ecs.historical_plan_id,
        p.base_price * (1 - COALESCE(ecs.discount, 0) / 100.0) AS event_sourced_mrr
    FROM event_customer_state AS ecs
    JOIN harbourmetrics.plans AS p
      ON p.plan_id = ecs.historical_plan_id
    WHERE ecs.event_type <> 'churn'
      AND ecs.historical_plan_id IS NOT NULL
),
existing_monthly AS (
    SELECT
        snapshot_month,
        COUNT(DISTINCT customer_id) AS existing_active_customers,
        SUM(existing_mrr) AS existing_total_mrr
    FROM existing_customer_month
    GROUP BY snapshot_month
),
event_monthly AS (
    SELECT
        snapshot_month,
        COUNT(DISTINCT customer_id) AS event_active_customers,
        SUM(event_sourced_mrr) AS event_total_mrr
    FROM event_customer_month
    GROUP BY snapshot_month
)
SELECT
    mt.snapshot_month,
    COALESCE(em.existing_active_customers, 0) AS existing_active_customers,
    COALESCE(evm.event_active_customers, 0) AS event_active_customers,
    COALESCE(evm.event_active_customers, 0)
        - COALESCE(em.existing_active_customers, 0) AS customer_count_difference,
    ROUND(COALESCE(em.existing_total_mrr, 0), 2) AS existing_total_mrr,
    ROUND(COALESCE(evm.event_total_mrr, 0), 2) AS event_sourced_total_mrr,
    ROUND(
        COALESCE(evm.event_total_mrr, 0)
        - COALESCE(em.existing_total_mrr, 0),
        2
    ) AS mrr_difference,
    ROUND(
        CASE
            WHEN COALESCE(em.existing_total_mrr, 0) = 0 THEN NULL
            ELSE (
                COALESCE(evm.event_total_mrr, 0)
                - COALESCE(em.existing_total_mrr, 0)
            ) / em.existing_total_mrr * 100
        END,
        2
    ) AS mrr_variance_percentage,
    CASE
        WHEN COALESCE(evm.event_active_customers, 0)
                 = COALESCE(em.existing_active_customers, 0)
         AND ABS(
                COALESCE(evm.event_total_mrr, 0)
                - COALESCE(em.existing_total_mrr, 0)
             ) < 0.01
            THEN 'MATCH'
        ELSE 'REVIEW'
    END AS validation_status
FROM monthly_timeline AS mt
LEFT JOIN existing_monthly AS em
  ON em.snapshot_month = mt.snapshot_month
LEFT JOIN event_monthly AS evm
  ON evm.snapshot_month = mt.snapshot_month
ORDER BY mt.snapshot_month DESC;


-- -----------------------------------------------------------------------------
-- RESULT 2: Detailed customer-month differences
--
-- Returns only records where the two approaches disagree. This makes it easy to
-- identify whether a variance comes from an upgrade being back-applied to prior
-- months, an activity-state difference, or another pricing difference.
-- -----------------------------------------------------------------------------
WITH monthly_timeline AS (
    SELECT GENERATE_SERIES(
        '2024-06-01'::DATE,
        '2026-06-01'::DATE,
        '1 month'::INTERVAL
    )::DATE AS snapshot_month
),
existing_customer_month AS (
    SELECT
        mt.snapshot_month,
        s.customer_id,
        s.plan_id AS existing_plan_id,
        s.monthly_price * (1 - COALESCE(s.discount, 0) / 100.0) AS existing_mrr
    FROM monthly_timeline AS mt
    JOIN harbourmetrics.subscriptions AS s
      ON s.start_date <= mt.snapshot_month
     AND (s.end_date IS NULL OR s.end_date > mt.snapshot_month)
),
event_customer_state AS (
    SELECT
        mt.snapshot_month,
        s.customer_id,
        s.discount,
        lifecycle.event_type,
        lifecycle.new_plan_id AS historical_plan_id
    FROM monthly_timeline AS mt
    JOIN harbourmetrics.subscriptions AS s
      ON s.start_date <= mt.snapshot_month
    JOIN LATERAL (
        SELECT
            se.event_type,
            se.new_plan_id
        FROM harbourmetrics.subscription_events AS se
        WHERE se.customer_id = s.customer_id
          AND se.event_date <= mt.snapshot_month
        ORDER BY se.event_date DESC, se.event_id DESC
        LIMIT 1
    ) AS lifecycle ON TRUE
),
event_customer_month AS (
    SELECT
        ecs.snapshot_month,
        ecs.customer_id,
        ecs.historical_plan_id,
        p.base_price * (1 - COALESCE(ecs.discount, 0) / 100.0) AS event_sourced_mrr
    FROM event_customer_state AS ecs
    JOIN harbourmetrics.plans AS p
      ON p.plan_id = ecs.historical_plan_id
    WHERE ecs.event_type <> 'churn'
      AND ecs.historical_plan_id IS NOT NULL
),
customer_comparison AS (
    SELECT
        COALESCE(ecm.snapshot_month, evcm.snapshot_month) AS snapshot_month,
        COALESCE(ecm.customer_id, evcm.customer_id) AS customer_id,
        ecm.existing_plan_id,
        evcm.historical_plan_id,
        ecm.existing_mrr,
        evcm.event_sourced_mrr
    FROM existing_customer_month AS ecm
    FULL OUTER JOIN event_customer_month AS evcm
      ON evcm.snapshot_month = ecm.snapshot_month
     AND evcm.customer_id = ecm.customer_id
)
SELECT
    cc.snapshot_month,
    cc.customer_id,
    c.company_name,
    existing_plan.plan_name AS existing_plan,
    historical_plan.plan_name AS historical_plan,
    ROUND(COALESCE(cc.existing_mrr, 0), 2) AS existing_mrr,
    ROUND(COALESCE(cc.event_sourced_mrr, 0), 2) AS event_sourced_mrr,
    ROUND(
        COALESCE(cc.event_sourced_mrr, 0)
        - COALESCE(cc.existing_mrr, 0),
        2
    ) AS mrr_difference,
    CASE
        WHEN cc.existing_mrr IS NULL
            THEN 'Event history says active; existing method says inactive'
        WHEN cc.event_sourced_mrr IS NULL
            THEN 'Existing method says active; event history says inactive'
        WHEN cc.existing_plan_id <> cc.historical_plan_id
            THEN 'Historical plan differs from final subscription plan'
        ELSE 'Pricing difference'
    END AS variance_reason
FROM customer_comparison AS cc
JOIN harbourmetrics.customers AS c
  ON c.customer_id = cc.customer_id
LEFT JOIN harbourmetrics.plans AS existing_plan
  ON existing_plan.plan_id = cc.existing_plan_id
LEFT JOIN harbourmetrics.plans AS historical_plan
  ON historical_plan.plan_id = cc.historical_plan_id
WHERE cc.existing_mrr IS NULL
   OR cc.event_sourced_mrr IS NULL
   OR ABS(cc.existing_mrr - cc.event_sourced_mrr) >= 0.01
ORDER BY
    cc.snapshot_month DESC,
    ABS(COALESCE(cc.event_sourced_mrr, 0) - COALESCE(cc.existing_mrr, 0)) DESC,
    cc.customer_id;
