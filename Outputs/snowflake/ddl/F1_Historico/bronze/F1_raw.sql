-- =====================================================
-- Bronze Layer: Raw Tables
-- =====================================================
-- Schema: F1_HISTORICO.BRONZE
-- Purpose: Mirror tables from source (Excel) with no transformations
-- Source: Formula1 - Historico.xlsx
-- =====================================================

USE SCHEMA F1_HISTORICO.BRONZE;

-- =====================================================
-- Table: raw_constructor
-- Description: Tabla de constructores de F1 en estado bruto
-- Source: Formula1 - Historico.xlsx, hoja: constructor
-- Records: 211
-- =====================================================
CREATE OR REPLACE TABLE raw_constructor (
    -- Primary Key
    constructorId NUMBER(38,0) COMMENT 'ID único del constructor',
    
    -- Business Keys and Attributes
    constructorRef VARCHAR(255) COMMENT 'Referencia alfanumérica del constructor',
    name VARCHAR(500) COMMENT 'Nombre completo del constructor',
    nationalityCostructor VARCHAR(255) COMMENT 'Nacionalidad del constructor',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de última actualización',
    _source VARCHAR(500) DEFAULT 'Formula1 - Historico.xlsx::constructor' COMMENT 'Origen de los datos'
)
COMMENT = 'Tabla RAW - Constructores de Fórmula 1 sin transformaciones'
;

-- =====================================================
-- Table: raw_drivers
-- Description: Tabla de pilotos de F1 en estado bruto
-- Source: Formula1 - Historico.xlsx, hoja: drivers
-- Records: 857
-- =====================================================
CREATE OR REPLACE TABLE raw_drivers (
    -- Primary Key
    driverId NUMBER(38,0) COMMENT 'ID único del piloto',
    
    -- Business Keys and Attributes
    driverRef VARCHAR(255) COMMENT 'Referencia alfanumérica del piloto',
    number_driver NUMBER(38,0) COMMENT 'Número del piloto',
    code VARCHAR(10) COMMENT 'Código de 3 letras del piloto',
    forename VARCHAR(255) COMMENT 'Nombre del piloto',
    surname VARCHAR(500) COMMENT 'Apellido del piloto',
    dob DATE COMMENT 'Fecha de nacimiento del piloto',
    nationalityDriver VARCHAR(255) COMMENT 'Nacionalidad del piloto',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de última actualización',
    _source VARCHAR(500) DEFAULT 'Formula1 - Historico.xlsx::drivers' COMMENT 'Origen de los datos'
)
COMMENT = 'Tabla RAW - Pilotos de Fórmula 1 sin transformaciones'
;

-- =====================================================
-- Table: raw_results
-- Description: Tabla de resultados de carreras de F1 en estado bruto
-- Source: Formula1 - Historico.xlsx, hoja: results
-- Records: 26,080
-- =====================================================
CREATE OR REPLACE TABLE raw_results (
    -- Primary Key
    resultId NUMBER(38,0) COMMENT 'ID único del resultado',
    
    -- Foreign Keys
    raceId NUMBER(38,0) COMMENT 'ID de la carrera',
    driverId NUMBER(38,0) COMMENT 'ID del piloto',
    constructorId NUMBER(38,0) COMMENT 'ID del constructor',
    
    -- Race Result Attributes
    number NUMBER(38,0) COMMENT 'Número del coche en la carrera',
    grid NUMBER(38,0) COMMENT 'Posición en la parrilla de salida',
    position NUMBER(38,0) COMMENT 'Posición final en la carrera',
    positionText VARCHAR(50) COMMENT 'Posición final como texto',
    positionOrder NUMBER(38,0) COMMENT 'Orden de posición para clasificación',
    points NUMBER(38,2) COMMENT 'Puntos obtenidos en la carrera',
    laps NUMBER(38,0) COMMENT 'Número de vueltas completadas',
    time VARCHAR(255) COMMENT 'Tiempo total de carrera',
    milliseconds NUMBER(38,0) COMMENT 'Tiempo en milisegundos',
    
    -- Fastest Lap Information
    fastestLap NUMBER(38,0) COMMENT 'Número de vuelta de la vuelta más rápida',
    rank NUMBER(38,0) COMMENT 'Ranking de la vuelta más rápida',
    fastestLapTime VARCHAR(50) COMMENT 'Tiempo de la vuelta más rápida',
    fastestLapSpeed NUMBER(38,3) COMMENT 'Velocidad de la vuelta más rápida',
    
    -- Status
    statusId NUMBER(38,0) COMMENT 'ID del estado final (terminó, abandonó, etc.)',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de última actualización',
    _source VARCHAR(500) DEFAULT 'Formula1 - Historico.xlsx::results' COMMENT 'Origen de los datos'
)
COMMENT = 'Tabla RAW - Resultados de carreras de Fórmula 1 sin transformaciones'
;

-- =====================================================
-- Create Streams for CDC
-- =====================================================
CREATE OR REPLACE STREAM raw_constructor_stream 
ON TABLE raw_constructor
COMMENT = 'Stream para captura de cambios en raw_constructor';

CREATE OR REPLACE STREAM raw_drivers_stream 
ON TABLE raw_drivers
COMMENT = 'Stream para captura de cambios en raw_drivers';

CREATE OR REPLACE STREAM raw_results_stream 
ON TABLE raw_results
COMMENT = 'Stream para captura de cambios en raw_results';
