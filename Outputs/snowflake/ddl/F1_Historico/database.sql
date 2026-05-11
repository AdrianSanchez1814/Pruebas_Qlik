-- =====================================================
-- Database Creation Script for F1 Histórico Project
-- =====================================================
-- Description: Database and schemas for the F1 Histórico data warehouse
-- Created: 2024
-- Project: F1 Histórico - Aqualia
-- =====================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS F1_HISTORICO
    COMMENT = 'Base de datos para el proyecto F1 Histórico - Migración desde QlikView';

-- Use the database
USE DATABASE F1_HISTORICO;

-- Create Bronze Schema (Raw data)
CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Esquema para datos en bruto sin transformaciones desde las fuentes';

-- Create Silver Schema (Cleaned/Conformed data)
CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Esquema para datos limpiados y conformados con tipos de datos corregidos';

-- Create Gold Schema (Business layer - Star Schema)
CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Esquema para capa de negocio optimizada para consumo en Power BI';

-- Grant usage on schemas
GRANT USAGE ON SCHEMA BRONZE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA SILVER TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA GOLD TO ROLE SYSADMIN;

-- Grant all privileges on schemas
GRANT ALL PRIVILEGES ON SCHEMA BRONZE TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON SCHEMA SILVER TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON SCHEMA GOLD TO ROLE SYSADMIN;
