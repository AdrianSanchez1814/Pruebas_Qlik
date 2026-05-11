-- =====================================================
-- Database Creation Script for F1 Histórico Project
-- =====================================================
-- Purpose: Create the main database to integrate all schemas
-- Author: Snowflake DDL Generation Agent
-- Date: 2025-01-XX
-- =====================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS F1_HISTORICO
    COMMENT = 'Database for F1 Historical data - Aqualia Project';

-- Use the database
USE DATABASE F1_HISTORICO;

-- Create schemas for each layer
CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Bronze layer - raw data from source systems';

CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Silver layer - cleaned and conformed data';

CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Gold layer - business-ready data marts in star schema';

-- Grant usage on database
GRANT USAGE ON DATABASE F1_HISTORICO TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA F1_HISTORICO.BRONZE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA F1_HISTORICO.SILVER TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA F1_HISTORICO.GOLD TO ROLE SYSADMIN;

-- Set default warehouse
-- ALTER DATABASE F1_HISTORICO SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- Information
SELECT 'Database F1_HISTORICO created successfully with Bronze, Silver, and Gold schemas' AS STATUS;
