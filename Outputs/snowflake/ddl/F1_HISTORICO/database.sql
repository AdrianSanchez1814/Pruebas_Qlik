-- =====================================================================
-- Database Creation Script for F1 Histórico Project
-- Aqualia - Snowflake Data Model
-- =====================================================================
-- Purpose: Create the main database and schemas for the F1 Histórico data model
-- Author: Snowflake Data Model Design Agent
-- Date: 2026-05-07
-- =====================================================================

-- Create database
CREATE DATABASE IF NOT EXISTS F1_HISTORICO
    COMMENT = 'Database for F1 Histórico project - Aqualia migration from QlikView';

-- Use database
USE DATABASE F1_HISTORICO;

-- Create schemas for bronze, silver, and gold layers
CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Bronze layer - Raw data mirror from source systems';

CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Silver layer - Cleaned and conformed data';

CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Gold layer - Business-ready data marts for BI consumption';

-- Set default warehouse (adjust as needed)
-- USE WAREHOUSE <your_warehouse_name>;

-- Grant usage on database to roles (adjust roles as needed)
-- GRANT USAGE ON DATABASE F1_HISTORICO TO ROLE <your_role>;
-- GRANT USAGE ON SCHEMA F1_HISTORICO.BRONZE TO ROLE <your_role>;
-- GRANT USAGE ON SCHEMA F1_HISTORICO.SILVER TO ROLE <your_role>;
-- GRANT USAGE ON SCHEMA F1_HISTORICO.GOLD TO ROLE <your_role>;

-- Confirmation message
SELECT 'Database F1_HISTORICO and schemas (BRONZE, SILVER, GOLD) created successfully' AS status;
