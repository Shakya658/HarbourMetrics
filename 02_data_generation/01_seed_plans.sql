-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 01_seed_plans.sql
-- Objective: Populate the product tiers lookup dimension table
-- ============================================================================

SET search_path TO harbourmetrics;

-- Clean out any existing rows to prevent duplicate key errors
TRUNCATE TABLE harbourmetrics.plans RESTART IDENTITY CASCADE;

INSERT INTO harbourmetrics.plans (plan_name, base_price, billing_cycle, feature_tier)
VALUES 
    ('Basic',      29.00,  'Monthly', 'Core'),
    ('Pro',        79.00,  'Monthly', 'Advanced'),
    ('Enterprise', 199.00, 'Monthly', 'Premium');

-- Verify data insertion
SELECT * FROM harbourmetrics.plans;