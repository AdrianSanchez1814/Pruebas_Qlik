-- =====================================================
-- Bronze Layer DDL - F1 Histórico Project
-- Schema: F1_HISTORICO.BRONZE
-- =====================================================
-- Purpose: Mirror tables from SQL Server (untransformed)
-- Source: Formula1 - Historico.xlsx
-- Tables: constructor, Resultados, Drivers
-- =====================================================

USE SCHEMA F1_HISTORICO.BRONZE;

-- =====================================================
-- Table: raw_constructor
-- Description: Constructor information (teams)
-- Source: Formula1 - Historico.xlsx - constructor sheet
-- Rows: 211 | Fields: 4 | Keys: constructorId
-- =====================================================
CREATE OR REPLACE TABLE raw_constructor (
    constructorId NUMBER(38,0) COMMENT 'ID único del constructor (Primary Key)',
    constructorRef VARCHAR(255) COMMENT 'Referencia del constructor',
    name VARCHAR(255) COMMENT 'Nombre del constructor',
    nationality VARCHAR(255) COMMENT 'Nacionalidad del constructor',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Formula1_Historico.xlsx' COMMENT 'Sistema origen del dato'
)
COMMENT = 'Tabla raw de constructores de Fórmula 1. Contiene 211 equipos históricos.';

-- =====================================================
-- Table: raw_resultados
-- Description: Race results data
-- Source: Formula1 - Historico.xlsx - results sheet
-- Rows: 26,080 | Fields: 24 | Keys: constructorId, driverRef
-- =====================================================
CREATE OR REPLACE TABLE raw_resultados (
    resultId NUMBER(38,0) COMMENT 'ID único del resultado',
    raceId NUMBER(38,0) COMMENT 'ID de la carrera',
    driverId NUMBER(38,0) COMMENT 'ID del piloto',
    constructorId NUMBER(38,0) COMMENT 'ID del constructor (Foreign Key)',
    number NUMBER(38,0) COMMENT 'Número del coche',
    grid NUMBER(38,0) COMMENT 'Posición en la parrilla de salida',
    position NUMBER(38,0) COMMENT 'Posición final en la carrera',
    positionText VARCHAR(50) COMMENT 'Texto de la posición final',
    positionOrder NUMBER(38,0) COMMENT 'Orden de posición',
    points FLOAT COMMENT 'Puntos obtenidos',
    laps NUMBER(38,0) COMMENT 'Número de vueltas completadas',
    time VARCHAR(255) COMMENT 'Tiempo total de carrera',
    milliseconds NUMBER(38,0) COMMENT 'Tiempo en milisegundos',
    fastestLap NUMBER(38,0) COMMENT 'Número de vuelta más rápida',
    rank NUMBER(38,0) COMMENT 'Ranking de vuelta rápida',
    fastestLapTime VARCHAR(50) COMMENT 'Tiempo de vuelta más rápida',
    fastestLapSpeed FLOAT COMMENT 'Velocidad de vuelta más rápida',
    statusId NUMBER(38,0) COMMENT 'ID del estado de finalización',
    driverRef VARCHAR(255) COMMENT 'Referencia del piloto',
    code VARCHAR(10) COMMENT 'Código del piloto (3 letras)',
    forename VARCHAR(255) COMMENT 'Nombre del piloto',
    surname VARCHAR(255) COMMENT 'Apellido del piloto',
    dob DATE COMMENT 'Fecha de nacimiento del piloto',
    nationalityDriver VARCHAR(255) COMMENT 'Nacionalidad del piloto',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Formula1_Historico.xlsx' COMMENT 'Sistema origen del dato'
)
COMMENT = 'Tabla raw de resultados de carreras de Fórmula 1. Contiene 26,080 resultados históricos.';

-- =====================================================
-- Table: raw_drivers
-- Description: Driver information
-- Source: Formula1 - Historico.xlsx - drivers sheet
-- Rows: 857 | Fields: 8 | Keys: driverRef
-- =====================================================
CREATE OR REPLACE TABLE raw_drivers (
    driverId NUMBER(38,0) COMMENT 'ID único del piloto (Primary Key)',
    driverRef VARCHAR(255) COMMENT 'Referencia del piloto',
    number_driver NUMBER(38,0) COMMENT 'Número del piloto',
    code VARCHAR(10) COMMENT 'Código del piloto (3 letras)',
    forename VARCHAR(255) COMMENT 'Nombre del piloto',
    surname VARCHAR(255) COMMENT 'Apellido del piloto',
    dob DATE COMMENT 'Fecha de nacimiento del piloto',
    nationalityDriver VARCHAR(255) COMMENT 'Nacionalidad del piloto',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Formula1_Historico.xlsx' COMMENT 'Sistema origen del dato'
)
COMMENT = 'Tabla raw de pilotos de Fórmula 1. Contiene 857 pilotos históricos.';

-- =====================================================
-- Create views for easy access
-- =====================================================

CREATE OR REPLACE VIEW vw_bronze_summary AS
SELECT 
    'raw_constructor' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM raw_constructor
UNION ALL
SELECT 
    'raw_resultados' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM raw_resultados
UNION ALL
SELECT 
    'raw_drivers' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM raw_drivers;

-- Information
SELECT 'Bronze layer tables created successfully' AS STATUS;
