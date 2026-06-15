-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 05_tables_events.sql
-- Objective: Create change logs to track customer journey state transformations
-- ============================================================================

CREATE TABLE harbourmetrics.subscription_events (
    event_id         SERIAL PRIMARY KEY,
    customer_id      INT NOT NULL REFERENCES harbourmetrics.customers(customer_id) ON DELETE CASCADE,
    event_date       DATE NOT NULL,
    event_type       VARCHAR(30) NOT NULL CHECK (event_type IN ('signup', 'upgrade', 'downgrade', 'churn', 'reactivation')),
    old_plan_id      INT REFERENCES harbourmetrics.plans(plan_id),
    new_plan_id      INT REFERENCES harbourmetrics.plans(plan_id),
    
    -- Business logic check: Upgrades/downgrades must indicate plan state mutations
    CONSTRAINT chk_plan_mutation CHECK (
        (event_type = 'signup' AND old_plan_id IS NULL AND new_plan_id IS NOT NULL) OR
        (event_type = 'churn' AND old_plan_id IS NOT NULL AND new_plan_id IS NULL) OR
        (event_type IN ('upgrade', 'downgrade') AND old_plan_id IS NOT NULL AND new_plan_id IS NOT NULL AND old_plan_id <> new_plan_id) OR
        (event_type = 'reactivation' AND old_plan_id IS NULL AND new_plan_id IS NOT NULL)
    )
);

COMMENT ON TABLE harbourmetrics.subscription_events IS 'Immutable ledger tracking state modifications across a user lifecycle over time.';