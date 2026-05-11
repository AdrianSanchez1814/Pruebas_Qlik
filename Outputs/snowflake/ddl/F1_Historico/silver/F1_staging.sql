-- =====================================================
-- Silver Layer: Staging Tables
-- =====================================================
-- Schema: F1_HISTORICO.SILVER
-- Purpose: Cleaned and conformed data with correct data types
-- Transformations: Data type corrections, key cleaning, standardized names, duplicate removal
-- =====================================================

USE SCHEMA F1_HISTORICO.SILVER;

-- =====================================================
-- Table: stg_constructor
-- Description: Tabla de constructores limpia y conformada
-- Source: F1_HISTORICO.BRONZE.raw_constructor
-- Transformations: Eliminación de duplicados, limpieza de claves, estandarización de nombres
-- =====================================================
CREATE OR REPLACE TABLE stg_constructor (
    -- Primary Key
    constructor_id NUMBER(38,0) NOT NULL COMMENT 'ID único del constructor',
    
    -- Business Keys and Attributes
    constructor_ref VARCHAR(255) NOT NULL COMMENT 'Referencia alfanumérica del constructor (limpia)',
    constructor_name VARCHAR(500) NOT NULL COMMENT 'Nombre completo del constructor (estandarizado)',
    constructor_nationality VARCHAR(255) COMMENT 'Nacionalidad del constructor (estandarizada)',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de última actualización',
    _source VARCHAR(500) COMMENT 'Origen de los datos',
    
    -- Constraints
    CONSTRAINT pk_stg_constructor PRIMARY KEY (constructor_id),
    CONSTRAINT uk_stg_constructor_ref UNIQUE (constructor_ref)
)
COMMENT = 'Tabla STAGING - Constructores de F1 limpios y conformados'
CLUSTER BY (constructor_id)
;

-- =====================================================
-- Table: stg_driver
-- Description: Tabla de pilotos limpia y conformada
-- Source: F1_HISTORICO.BRONZE.raw_drivers
-- Transformations: Limpieza de datos, corrección de tipos, estandarización de nombres
-- =====================================================
CREATE OR REPLACE TABLE stg_driver (
    -- Primary Key
    driver_id NUMBER(38,0) NOT NULL COMMENT 'ID único del piloto',
    
    -- Business Keys and Attributes
    driver_ref VARCHAR(255) NOT NULL COMMENT 'Referencia alfanumérica del piloto (limpia)',
    driver_number NUMBER(38,0) COMMENT 'Número del piloto (limpio)',
    driver_code VARCHAR(10) COMMENT 'Código de 3 letras del piloto',
    driver_forename VARCHAR(255) NOT NULL COMMENT 'Nombre del piloto (estandarizado)',
    driver_surname VARCHAR(500) NOT NULL COMMENT 'Apellido del piloto (estandarizado)',
    driver_full_name VARCHAR(755) COMMENT 'Nombre completo del piloto (concatenado)',
    date_of_birth DATE COMMENT 'Fecha de nacimiento del piloto',
    driver_nationality VARCHAR(255) COMMENT 'Nacionalidad del piloto (estandarizada)',
    
    -- Calculated Fields
    driver_age NUMBER(38,0) COMMENT 'Edad actual del piloto',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de última actualización',
    _source VARCHAR(500) COMMENT 'Origen de los datos',
    
    -- Constraints
    CONSTRAINT pk_stg_driver PRIMARY KEY (driver_id),
    CONSTRAINT uk_stg_driver_ref UNIQUE (driver_ref)
)
COMMENT = 'Tabla STAGING - Pilotos de F1 limpios y conformados'
CLUSTER BY (driver_id)
;

-- =====================================================
-- Table: stg_race_result
-- Description: Tabla de resultados de carreras limpia y conformada
-- Source: F1_HISTORICO.BRONZE.raw_results
-- Transformations: Limpieza de claves, corrección de tipos de datos, eliminación de duplicados
-- =====================================================
CREATE OR REPLACE TABLE stg_race_result (
    -- Primary Key
    result_id NUMBER(38,0) NOT NULL COMMENT 'ID único del resultado',
    
    -- Foreign Keys
    race_id NUMBER(38,0) NOT NULL COMMENT 'ID de la carrera',
    driver_id NUMBER(38,0) NOT NULL COMMENT 'ID del piloto',
    constructor_id NUMBER(38,0) NOT NULL COMMENT 'ID del constructor',
    
    -- Race Result Attributes
    car_number NUMBER(38,0) COMMENT 'Número del coche en la carrera',
    grid_position NUMBER(38,0) COMMENT 'Posición en la parrilla de salida',
    final_position NUMBER(38,0) COMMENT 'Posición final en la carrera (numérica)',
    final_position_text VARCHAR(50) COMMENT 'Posición final como texto (R, DQ, etc.)',
    position_order NUMBER(38,0) NOT NULL COMMENT 'Orden de posición para clasificación',
    points_earned NUMBER(38,2) DEFAULT 0 COMMENT 'Puntos obtenidos en la carrera',
    laps_completed NUMBER(38,0) COMMENT 'Número de vueltas completadas',
    race_time VARCHAR(255) COMMENT 'Tiempo total de carrera',
    race_time_milliseconds NUMBER(38,0) COMMENT 'Tiempo en milisegundos',
    
    -- Fastest Lap Information
    fastest_lap_number NUMBER(38,0) COMMENT 'Número de vuelta de la vuelta más rápida',
    fastest_lap_rank NUMBER(38,0) COMMENT 'Ranking de la vuelta más rápida',
    fastest_lap_time VARCHAR(50) COMMENT 'Tiempo de la vuelta más rápida',
    fastest_lap_speed NUMBER(38,3) COMMENT 'Velocidad de la vuelta más rápida (km/h)',
    
    -- Status
    status_id NUMBER(38,0) COMMENT 'ID del estado final',
    
    -- Flags
    is_finished BOOLEAN COMMENT 'Indicador si terminó la carrera',
    is_classified BOOLEAN COMMENT 'Indicador si fue clasificado',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha y hora de última actualización',
    _source VARCHAR(500) COMMENT 'Origen de los datos',
    
    -- Constraints
    CONSTRAINT pk_stg_race_result PRIMARY KEY (result_id),
    CONSTRAINT uk_stg_race_result UNIQUE (race_id, driver_id, constructor_id)
)
COMMENT = 'Tabla STAGING - Resultados de carreras de F1 limpios y conformados'
CLUSTER BY (race_id, driver_id)
;

-- =====================================================
-- Create Views for Data Quality
-- =====================================================

-- View: Constructor Data Quality
CREATE OR REPLACE VIEW vw_stg_constructor_quality AS
SELECT 
    constructor_id,
    constructor_ref,
    constructor_name,
    constructor_nationality,
    CASE 
        WHEN constructor_ref IS NULL THEN 'Missing constructor_ref'
        WHEN constructor_name IS NULL THEN 'Missing constructor_name'
        ELSE 'OK'
    END AS data_quality_status,
    _source,
    updated_at
FROM stg_constructor
COMMENT = 'Vista de calidad de datos para constructores';

-- View: Driver Data Quality
CREATE OR REPLACE VIEW vw_stg_driver_quality AS
SELECT 
    driver_id,
    driver_ref,
    driver_full_name,
    driver_nationality,
    CASE 
        WHEN driver_ref IS NULL THEN 'Missing driver_ref'
        WHEN driver_forename IS NULL THEN 'Missing driver_forename'
        WHEN driver_surname IS NULL THEN 'Missing driver_surname'
        ELSE 'OK'
    END AS data_quality_status,
    _source,
    updated_at
FROM stg_driver
COMMENT = 'Vista de calidad de datos para pilotos';

-- View: Race Result Data Quality
CREATE OR REPLACE VIEW vw_stg_race_result_quality AS
SELECT 
    result_id,
    race_id,
    driver_id,
    constructor_id,
    final_position,
    points_earned,
    CASE 
        WHEN race_id IS NULL THEN 'Missing race_id'
        WHEN driver_id IS NULL THEN 'Missing driver_id'
        WHEN constructor_id IS NULL THEN 'Missing constructor_id'
        WHEN position_order IS NULL THEN 'Missing position_order'
        ELSE 'OK'
    END AS data_quality_status,
    _source,
    updated_at
FROM stg_race_result
COMMENT = 'Vista de calidad de datos para resultados';
