-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 04_tables_subscriptions.sql
-- Objective: Create active subscription contracts state table
-- ============================================================================

CREATE TABLE harbourmetrics.subscriptions (
    subscription_id  SERIAL PRIMARY KEY,
    customer_id      INT NOT NULL REFERENCES harbourmetrics.customers(customer_id) ON DELETE CASCADE,
    plan_id          INT NOT NULL REFERENCES harbourmetrics.plans(plan_id),
    start_date       DATE NOT NULL,
    end_date         DATE, -- NULL implies the contract is active and ongoing
    status           VARCHAR(20) NOT NULL CHECK (status IN ('Active', 'Canceled', 'Past_Due', 'Trial')),
    monthly_price    NUMERIC(10, 2) NOT NULL CHECK (monthly_price >= 0),
    discount         NUMERIC(5, 2) DEFAULT 0.00 CHECK (discount BETWEEN 0 AND 100),
    CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

COMMENT ON TABLE harbourmetrics.subscriptions IS 'Fact table capturing current contract states, active statuses, and applied concessions.';