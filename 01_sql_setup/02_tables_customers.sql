-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 02_tables_customers.sql
-- Objective: Create the base dimension table for customer profiles
-- ============================================================================

CREATE TABLE harbourmetrics.customers (
    customer_id          SERIAL PRIMARY KEY,
    company_name         VARCHAR(150) NOT NULL,
    industry             VARCHAR(50) NOT NULL CHECK (industry IN ('Tech', 'Finance', 'Retail', 'Healthcare', 'Education')),
    company_size         VARCHAR(50) NOT NULL CHECK (company_size IN ('Startup', 'SMB', 'Mid-Market', 'Enterprise')),
    region               VARCHAR(50) NOT NULL CHECK (region IN ('Australia', 'New Zealand', 'UK', 'US')),
    acquisition_channel  VARCHAR(50) NOT NULL CHECK (acquisition_channel IN ('Organic', 'Paid Ads', 'Referral', 'Outbound')),
    signup_date          DATE NOT NULL,
    CONSTRAINT chk_signup_date CHECK (signup_date <= CURRENT_DATE)
);

COMMENT ON TABLE harbourmetrics.customers IS 'Dimension table containing unique B2B customer profiles and firmographic data.';