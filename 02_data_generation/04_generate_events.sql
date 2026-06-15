-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 04_generate_events.sql
-- Objective: Simulate historical lifecycle events (signups, churn, upgrades) 
--            and synchronize data states across the subscription matrix.
-- ============================================================================

SET search_path TO harbourmetrics;

-- 1. Reset the events ledger
TRUNCATE TABLE harbourmetrics.subscription_events RESTART IDENTITY CASCADE;

-- 2. Insert the baseline 'signup' event for every single customer record
INSERT INTO harbourmetrics.subscription_events (customer_id, event_date, event_type, old_plan_id, new_plan_id)
SELECT 
    customer_id,
    start_date as event_date,
    'signup' as event_type,
    NULL as old_plan_id,
    plan_id as new_plan_id
FROM harbourmetrics.subscriptions;


-- 3. Simulate structured 'churn' events based on your exact business weights
WITH churn_candidates AS (
    SELECT 
        s.subscription_id,
        s.customer_id,
        s.plan_id,
        s.start_date,
        FLOOR(RANDOM() * 100 + 1) as churn_roll,
        -- Generate a realistic lifespan of 30 to 180 days before churning
        (s.start_date + (FLOOR(RANDOM() * 150) + 30)::INT) as calculated_churn_date
    FROM harbourmetrics.subscriptions s
),
selected_churns AS (
    SELECT * FROM churn_candidates
    WHERE 
        (plan_id = 1 AND churn_roll <= 10) OR -- 10% Churn Rate for Basic
        (plan_id = 2 AND churn_roll <= 5)  OR -- 5% Churn Rate for Pro
        (plan_id = 3 AND churn_roll <= 2)     -- 2% Churn Rate for Enterprise
)
INSERT INTO harbourmetrics.subscription_events (customer_id, event_date, event_type, old_plan_id, new_plan_id)
SELECT 
    customer_id,
    calculated_churn_date,
    'churn',
    plan_id as old_plan_id,
    NULL as new_plan_id
FROM selected_churns
-- Ensure we don't drop a churn date into the future relative to our current operational horizon
WHERE calculated_churn_date <= '2026-06-01';


-- 4. Simulate 'upgrade' progression for scaling companies
WITH upgrade_candidates AS (
    SELECT 
        s.customer_id,
        s.plan_id as current_plan,
        s.start_date,
        FLOOR(RANDOM() * 100 + 1) as upgrade_roll,
        (s.start_date + (FLOOR(RANDOM() * 120) + 60)::INT) as calculated_upgrade_date
    FROM harbourmetrics.subscriptions s
    -- Only active or unchurned users on Basic or Pro can upgrade
    WHERE s.plan_id IN (1, 2) 
      AND s.customer_id NOT IN (SELECT customer_id FROM harbourmetrics.subscription_events WHERE event_type = 'churn')
),
selected_upgrades AS (
    SELECT * FROM upgrade_candidates
    WHERE (current_plan = 1 AND upgrade_roll <= 8) OR -- 8% of Basic users upgrade to Pro
          (current_plan = 2 AND upgrade_roll <= 5)    -- 5% of Pro users upgrade to Enterprise
)
INSERT INTO harbourmetrics.subscription_events (customer_id, event_date, event_type, old_plan_id, new_plan_id)
SELECT 
    customer_id,
    calculated_upgrade_date,
    'upgrade',
    current_plan as old_plan_id,
    (current_plan + 1) as new_plan_id
FROM selected_upgrades
WHERE calculated_upgrade_date <= '2026-06-01';


-- 5. Back-propagate historical adjustments to sync the primary subscriptions state table
-- If a customer churned, update their status to 'Canceled' and append their end_date
UPDATE harbourmetrics.subscriptions s
SET 
    status = 'Canceled',
    end_date = e.event_date
FROM harbourmetrics.subscription_events e
WHERE s.customer_id = e.customer_id 
  AND e.event_type = 'churn';

-- If a customer upgraded, adjust their status/price parameters to reflect their final state configuration
UPDATE harbourmetrics.subscriptions s
SET 
    plan_id = e.new_plan_id,
    monthly_price = CASE WHEN e.new_plan_id = 2 THEN 79.00 ELSE 199.00 END
FROM harbourmetrics.subscription_events e
WHERE s.customer_id = e.customer_id 
  AND e.event_type = 'upgrade';

-- Verify ledger event volume balances
SELECT event_type, COUNT(*) 
FROM harbourmetrics.subscription_events 
GROUP BY event_type;