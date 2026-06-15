-- ============================================================================
-- Project: HarbourMetrics - SaaS Revenue & Retention Analytics
-- Script: 01_schema.sql
-- Objective: Initialize the database schema workspace
-- ============================================================================

DROP SCHEMA IF EXISTS harbourmetrics CASCADE;
CREATE SCHEMA harbourmetrics;
SET search_path TO harbourmetrics;