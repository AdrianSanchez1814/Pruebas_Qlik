-- =====================================================
-- DATABASE CREATION FOR F1 HISTORICO PROJECT
-- =====================================================
-- Proyecto: F1 Histórico
-- Fuente: QlikView - Formula1 - Historico.xlsx
-- Fecha de creación: 2026-05-06
-- =====================================================

-- Crear la base de datos principal
CREATE DATABASE IF NOT EXISTS F1_HISTORICO
    COMMENT = 'Base de datos para el proyecto F1 Histórico - Medallion Architecture (Bronze, Silver, Gold)';

-- Usar la base de datos creada
USE DATABASE F1_HISTORICO;

-- =====================================================
-- CREAR SCHEMAS PARA ARQUITECTURA MEDALLION
-- =====================================================

-- Schema Bronze: Datos crudos sin transformar
CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Capa Bronze - Datos crudos espejo de SQL Server sin transformaciones';

-- Schema Silver: Datos conformados y limpios
CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Capa Silver - Datos conformados con tipos corregidos, claves limpias y nombres estandarizados';

-- Schema Gold: Datos para consumo BI
CREATE SCHEMA IF NOT EXISTS GOLD
    COMMENT = 'Capa Gold - Esquema estrella optimizado para consumo en Power BI';

-- =====================================================
-- ROLES Y PERMISOS (Opcional - descomentar si se necesita)
-- =====================================================

-- CREATE ROLE IF NOT EXISTS F1_BRONZE_READER;
-- GRANT USAGE ON DATABASE F1_HISTORICO TO ROLE F1_BRONZE_READER;
-- GRANT USAGE ON SCHEMA F1_HISTORICO.BRONZE TO ROLE F1_BRONZE_READER;
-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.BRONZE TO ROLE F1_BRONZE_READER;

-- CREATE ROLE IF NOT EXISTS F1_SILVER_READER;
-- GRANT USAGE ON DATABASE F1_HISTORICO TO ROLE F1_SILVER_READER;
-- GRANT USAGE ON SCHEMA F1_HISTORICO.SILVER TO ROLE F1_SILVER_READER;
-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.SILVER TO ROLE F1_SILVER_READER;

-- CREATE ROLE IF NOT EXISTS F1_GOLD_READER;
-- GRANT USAGE ON DATABASE F1_HISTORICO TO ROLE F1_GOLD_READER;
-- GRANT USAGE ON SCHEMA F1_HISTORICO.GOLD TO ROLE F1_GOLD_READER;
-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.GOLD TO ROLE F1_GOLD_READER;

-- =====================================================
-- WAREHOUSE (Opcional - descomentar si se necesita crear)
-- =====================================================

-- CREATE WAREHOUSE IF NOT EXISTS F1_WH
--     WAREHOUSE_SIZE = 'SMALL'
--     AUTO_SUSPEND = 300
--     AUTO_RESUME = TRUE
--     INITIALLY_SUSPENDED = TRUE
--     COMMENT = 'Warehouse para procesamiento de datos F1 Histórico';

-- =====================================================
-- CONFIGURACIÓN COMPLETADA
-- =====================================================
-- La base de datos F1_HISTORICO y sus schemas están listos
-- Siguiente paso: Ejecutar los scripts de creación de tablas:
--   1. bronze/F1_Historico_raw.sql
--   2. silver/F1_Historico_staging.sql
--   3. gold/F1_Historico_marts.sql
-- =====================================================
