-- =====================================================================
-- Bronze Layer DDL - F1 Histórico Raw Tables
-- Aqualia - Snowflake Data Model
-- =====================================================================
-- Purpose: Mirror tables from source Excel files (untransformed)
-- Layer: Bronze (Raw Data)
-- Schema: F1_HISTORICO.BRONZE
-- Source: Formula1 - Historico.xlsx
-- =====================================================================

USE SCHEMA F1_HISTORICO.BRONZE;

-- =====================================================================
-- RAW_CONSTRUCTOR
-- =====================================================================
-- Descripción: Tabla raw con información de constructores de F1
-- Fuente: Formula1 - Historico.xlsx (hoja: constructor)
-- Filas: 211
-- Campos: 4
-- =====================================================================
CREATE OR REPLACE TABLE raw_constructor (
    -- Clave primaria
    constructorRef STRING COMMENT 'Referencia única del constructor',
    
    -- Campos de negocio
    name STRING COMMENT 'Nombre del constructor',
    nationality STRING COMMENT 'Nacionalidad del constructor',
    url STRING COMMENT 'URL de referencia del constructor',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'Formula1 - Historico.xlsx' COMMENT 'Sistema fuente del dato'
)
COMMENT = 'Tabla raw con datos de constructores de Fórmula 1';

-- =====================================================================
-- RAW_RESULTADOS
-- =====================================================================
-- Descripción: Tabla raw con resultados de carreras de F1
-- Fuente: Formula1 - Historico.xlsx (hoja: results)
-- Filas: 26,080
-- Campos: 18-24 (varía según versión del QVW)
-- =====================================================================
CREATE OR REPLACE TABLE raw_resultados (
    -- Claves
    resultId STRING COMMENT 'Identificador único del resultado',
    raceId STRING COMMENT 'Identificador de la carrera',
    driverId STRING COMMENT 'Identificador del piloto',
    constructorRef STRING COMMENT 'Referencia del constructor',
    
    -- Campos de resultados
    number STRING COMMENT 'Número del piloto en la carrera',
    grid STRING COMMENT 'Posición de salida en la parrilla',
    position STRING COMMENT 'Posición final en la carrera',
    positionText STRING COMMENT 'Texto de la posición final',
    positionOrder STRING COMMENT 'Orden de posición',
    points STRING COMMENT 'Puntos obtenidos',
    laps STRING COMMENT 'Número de vueltas completadas',
    time STRING COMMENT 'Tiempo total de carrera',
    milliseconds STRING COMMENT 'Tiempo en milisegundos',
    fastestLap STRING COMMENT 'Vuelta más rápida',
    rank STRING COMMENT 'Ranking de la vuelta más rápida',
    fastestLapTime STRING COMMENT 'Tiempo de la vuelta más rápida',
    fastestLapSpeed STRING COMMENT 'Velocidad de la vuelta más rápida',
    statusId STRING COMMENT 'Estado del resultado',
    
    -- Campos adicionales que pueden existir
    campo VARIANT COMMENT 'Campo adicional en formato JSON para datos variables',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'Formula1 - Historico.xlsx' COMMENT 'Sistema fuente del dato'
)
COMMENT = 'Tabla raw con resultados de carreras de Fórmula 1';

-- =====================================================================
-- RAW_DRIVERS
-- =====================================================================
-- Descripción: Tabla raw con información de pilotos de F1
-- Fuente: Formula1 - Historico.xlsx (hoja: drivers)
-- Filas: 857
-- Campos: 8
-- =====================================================================
CREATE OR REPLACE TABLE raw_drivers (
    -- Clave primaria
    driverId STRING COMMENT 'Identificador único del piloto',
    
    -- Campos de negocio
    driverRef STRING COMMENT 'Referencia del piloto',
    number STRING COMMENT 'Número del piloto',
    code STRING COMMENT 'Código del piloto',
    forename STRING COMMENT 'Nombre del piloto',
    surname STRING COMMENT 'Apellido del piloto',
    dob STRING COMMENT 'Fecha de nacimiento',
    nationality STRING COMMENT 'Nacionalidad del piloto',
    url STRING COMMENT 'URL de referencia del piloto',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'Formula1 - Historico.xlsx' COMMENT 'Sistema fuente del dato'
)
COMMENT = 'Tabla raw con datos de pilotos de Fórmula 1';

-- =====================================================================
-- Confirmation
-- =====================================================================
SELECT 'Bronze layer tables created successfully: raw_constructor, raw_resultados, raw_drivers' AS status;
