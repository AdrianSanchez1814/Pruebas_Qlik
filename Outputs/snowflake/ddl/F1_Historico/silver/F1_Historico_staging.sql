-- =====================================================
-- Silver Layer DDL - F1 Histórico Project
-- Schema: F1_HISTORICO.SILVER
-- =====================================================
-- Purpose: Cleaned and conformed data with correct types
-- Data Quality: Correct data types, cleaned keys, standardized names, drop duplicates
-- =====================================================

USE SCHEMA F1_HISTORICO.SILVER;

-- =====================================================
-- Table: stg_constructor
-- Description: Cleaned constructor data
-- Transformations: Data type corrections, key cleaning, name standardization
-- =====================================================
CREATE OR REPLACE TABLE stg_constructor (
    constructor_id NUMBER(38,0) NOT NULL COMMENT 'ID único del constructor (Primary Key)',
    constructor_ref VARCHAR(100) NOT NULL COMMENT 'Referencia del constructor normalizada',
    name VARCHAR(255) NOT NULL COMMENT 'Nombre del constructor limpio',
    nationality VARCHAR(100) COMMENT 'Nacionalidad del constructor estandarizada',
    
    -- Data quality flags
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Indica si el constructor está activo',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Bronze.raw_constructor' COMMENT 'Sistema origen del dato',
    
    -- Constraint
    CONSTRAINT pk_stg_constructor PRIMARY KEY (constructor_id)
)
COMMENT = 'Tabla staging de constructores de Fórmula 1. Datos limpios y conformados.';

-- =====================================================
-- Table: stg_drivers
-- Description: Cleaned driver data
-- Transformations: Data type corrections, key cleaning, name standardization
-- =====================================================
CREATE OR REPLACE TABLE stg_drivers (
    driver_id NUMBER(38,0) NOT NULL COMMENT 'ID único del piloto (Primary Key)',
    driver_ref VARCHAR(100) NOT NULL COMMENT 'Referencia del piloto normalizada',
    driver_number NUMBER(38,0) COMMENT 'Número del piloto',
    code VARCHAR(3) COMMENT 'Código del piloto (3 letras)',
    first_name VARCHAR(100) COMMENT 'Nombre del piloto normalizado',
    last_name VARCHAR(100) COMMENT 'Apellido del piloto normalizado',
    full_name VARCHAR(255) COMMENT 'Nombre completo del piloto',
    date_of_birth DATE COMMENT 'Fecha de nacimiento del piloto',
    nationality VARCHAR(100) COMMENT 'Nacionalidad del piloto estandarizada',
    
    -- Calculated fields
    age_years NUMBER(3,0) COMMENT 'Edad actual del piloto en años',
    
    -- Data quality flags
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Indica si el piloto está activo',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Bronze.raw_drivers' COMMENT 'Sistema origen del dato',
    
    -- Constraint
    CONSTRAINT pk_stg_drivers PRIMARY KEY (driver_id)
)
COMMENT = 'Tabla staging de pilotos de Fórmula 1. Datos limpios y conformados.';

-- =====================================================
-- Table: stg_race_results
-- Description: Cleaned race results data
-- Transformations: Data type corrections, calculated fields, status normalization
-- =====================================================
CREATE OR REPLACE TABLE stg_race_results (
    result_id NUMBER(38,0) NOT NULL COMMENT 'ID único del resultado (Primary Key)',
    race_id NUMBER(38,0) NOT NULL COMMENT 'ID de la carrera',
    driver_id NUMBER(38,0) NOT NULL COMMENT 'ID del piloto (Foreign Key)',
    constructor_id NUMBER(38,0) NOT NULL COMMENT 'ID del constructor (Foreign Key)',
    car_number NUMBER(38,0) COMMENT 'Número del coche',
    grid_position NUMBER(38,0) COMMENT 'Posición en la parrilla de salida',
    final_position NUMBER(38,0) COMMENT 'Posición final en la carrera',
    position_text VARCHAR(50) COMMENT 'Texto de la posición final',
    position_order NUMBER(38,0) COMMENT 'Orden de posición',
    points_earned FLOAT COMMENT 'Puntos obtenidos en la carrera',
    laps_completed NUMBER(38,0) COMMENT 'Número de vueltas completadas',
    race_time VARCHAR(50) COMMENT 'Tiempo total de carrera',
    race_milliseconds NUMBER(38,0) COMMENT 'Tiempo en milisegundos',
    fastest_lap_number NUMBER(38,0) COMMENT 'Número de vuelta más rápida',
    fastest_lap_rank NUMBER(38,0) COMMENT 'Ranking de vuelta rápida',
    fastest_lap_time VARCHAR(50) COMMENT 'Tiempo de vuelta más rápida',
    fastest_lap_speed FLOAT COMMENT 'Velocidad de vuelta más rápida (km/h)',
    status_id NUMBER(38,0) COMMENT 'ID del estado de finalización',
    
    -- Calculated fields
    grid_gain NUMBER(38,0) COMMENT 'Posiciones ganadas desde la parrilla',
    is_finished BOOLEAN COMMENT 'Indica si completó la carrera',
    is_podium BOOLEAN COMMENT 'Indica si llegó al podium (top 3)',
    is_points BOOLEAN COMMENT 'Indica si obtuvo puntos',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Bronze.raw_resultados' COMMENT 'Sistema origen del dato',
    
    -- Constraints
    CONSTRAINT pk_stg_race_results PRIMARY KEY (result_id)
)
COMMENT = 'Tabla staging de resultados de carreras de Fórmula 1. Datos limpios y conformados.';

-- =====================================================
-- Create indexes for performance
-- =====================================================

-- Indexes on stg_constructor
CREATE INDEX IF NOT EXISTS idx_stg_constructor_ref ON stg_constructor(constructor_ref);
CREATE INDEX IF NOT EXISTS idx_stg_constructor_name ON stg_constructor(name);

-- Indexes on stg_drivers
CREATE INDEX IF NOT EXISTS idx_stg_drivers_ref ON stg_drivers(driver_ref);
CREATE INDEX IF NOT EXISTS idx_stg_drivers_code ON stg_drivers(code);
CREATE INDEX IF NOT EXISTS idx_stg_drivers_name ON stg_drivers(last_name, first_name);

-- Indexes on stg_race_results
CREATE INDEX IF NOT EXISTS idx_stg_results_race ON stg_race_results(race_id);
CREATE INDEX IF NOT EXISTS idx_stg_results_driver ON stg_race_results(driver_id);
CREATE INDEX IF NOT EXISTS idx_stg_results_constructor ON stg_race_results(constructor_id);

-- =====================================================
-- Create views for data quality monitoring
-- =====================================================

CREATE OR REPLACE VIEW vw_silver_data_quality AS
SELECT 
    'stg_constructor' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT constructor_id) AS unique_keys,
    SUM(CASE WHEN is_active THEN 1 ELSE 0 END) AS active_records,
    MAX(updated_at) AS last_updated
FROM stg_constructor
UNION ALL
SELECT 
    'stg_drivers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT driver_id) AS unique_keys,
    SUM(CASE WHEN is_active THEN 1 ELSE 0 END) AS active_records,
    MAX(updated_at) AS last_updated
FROM stg_drivers
UNION ALL
SELECT 
    'stg_race_results' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT result_id) AS unique_keys,
    SUM(CASE WHEN is_finished THEN 1 ELSE 0 END) AS finished_races,
    MAX(updated_at) AS last_updated
FROM stg_race_results;

-- Information
SELECT 'Silver layer tables created successfully' AS STATUS;
