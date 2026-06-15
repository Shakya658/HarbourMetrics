-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 03_tables_plans.sql
-- Objective: Create the product catalog reference table
-- ============================================================================

CREATE TABLE harbourmetrics.plans (
    plan_id        SERIAL PRIMARY KEY,
    plan_name      VARCHAR(50) NOT NULL UNIQUE CHECK (plan_name IN ('Basic', 'Pro', 'Enterprise')),
    base_price     NUMERIC(10, 2) NOT NULL CHECK (base_price >= 0),
    billing_cycle  VARCHAR(20) NOT NULL CHECK (billing_cycle IN ('Monthly', 'Annual')),
    feature_tier   VARCHAR(20) NOT NULL
);

COMMENT ON TABLE harbourmetrics.plans IS 'Lookup dimension table detailing subscription product tiers and pricing rules.';