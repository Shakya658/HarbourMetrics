-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 06_calendar_dim.sql
-- Objective: Generate a continuous calendar dimension for Power BI
--            time-intelligence analysis.
-- ============================================================================

SET search_path TO harbourmetrics;

CREATE TABLE IF NOT EXISTS harbourmetrics.calendar_dim (
    date_id DATE PRIMARY KEY,
    calendar_year INT NOT NULL,
    calendar_quarter INT NOT NULL,
    calendar_month INT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    month_short_name VARCHAR(3) NOT NULL,
    week_of_year INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(15) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

TRUNCATE TABLE harbourmetrics.calendar_dim;

INSERT INTO harbourmetrics.calendar_dim
SELECT
    datum AS date_id,
    EXTRACT(YEAR FROM datum)::INT AS calendar_year,
    EXTRACT(QUARTER FROM datum)::INT AS calendar_quarter,
    EXTRACT(MONTH FROM datum)::INT AS calendar_month,
    TRIM(TO_CHAR(datum, 'Month')) AS month_name,
    TO_CHAR(datum, 'Mon') AS month_short_name,
    EXTRACT(WEEK FROM datum)::INT AS week_of_year,
    EXTRACT(ISODOW FROM datum)::INT AS day_of_week,
    TRIM(TO_CHAR(datum, 'Day')) AS day_name,
    EXTRACT(ISODOW FROM datum) IN (6, 7) AS is_weekend
FROM generate_series(
    '2024-01-01'::DATE,
    '2026-12-31'::DATE,
    '1 day'::INTERVAL
) AS datum;

SELECT
    MIN(date_id) AS calendar_start,
    MAX(date_id) AS calendar_end,
    COUNT(*) AS total_generated_days
FROM harbourmetrics.calendar_dim;
