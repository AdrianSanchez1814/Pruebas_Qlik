-- =====================================================
-- Gold Layer DDL - F1 Histórico Project
-- Schema: F1_HISTORICO.GOLD
-- =====================================================
-- Purpose: Star schema for Power BI consumption
-- Design: Fact and dimension tables optimized for analytics
-- =====================================================

USE SCHEMA F1_HISTORICO.GOLD;

-- =====================================================
-- DIMENSION TABLES
-- =====================================================

-- =====================================================
-- Dimension: dim_constructor
-- Description: Constructor dimension (SCD Type 1)
-- Source: Silver.stg_constructor
-- =====================================================
CREATE OR REPLACE TABLE dim_constructor (
    constructor_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Surrogate key del constructor',
    constructor_id NUMBER(38,0) NOT NULL COMMENT 'ID natural del constructor',
    constructor_ref VARCHAR(100) NOT NULL COMMENT 'Referencia del constructor',
    constructor_name VARCHAR(255) NOT NULL COMMENT 'Nombre del constructor',
    nationality VARCHAR(100) COMMENT 'Nacionalidad del constructor',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Indica si el constructor está activo',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Silver.stg_constructor' COMMENT 'Sistema origen del dato',
    
    -- Constraints
    CONSTRAINT pk_dim_constructor PRIMARY KEY (constructor_key),
    CONSTRAINT uk_dim_constructor_id UNIQUE (constructor_id)
)
COMMENT = 'Dimensión de constructores de Fórmula 1 para análisis';

-- =====================================================
-- Dimension: dim_driver
-- Description: Driver dimension (SCD Type 1)
-- Source: Silver.stg_drivers
-- =====================================================
CREATE OR REPLACE TABLE dim_driver (
    driver_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Surrogate key del piloto',
    driver_id NUMBER(38,0) NOT NULL COMMENT 'ID natural del piloto',
    driver_ref VARCHAR(100) NOT NULL COMMENT 'Referencia del piloto',
    driver_number NUMBER(38,0) COMMENT 'Número del piloto',
    driver_code VARCHAR(3) COMMENT 'Código del piloto (3 letras)',
    first_name VARCHAR(100) COMMENT 'Nombre del piloto',
    last_name VARCHAR(100) COMMENT 'Apellido del piloto',
    full_name VARCHAR(255) COMMENT 'Nombre completo del piloto',
    date_of_birth DATE COMMENT 'Fecha de nacimiento del piloto',
    nationality VARCHAR(100) COMMENT 'Nacionalidad del piloto',
    age_years NUMBER(3,0) COMMENT 'Edad del piloto en años',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Indica si el piloto está activo',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Silver.stg_drivers' COMMENT 'Sistema origen del dato',
    
    -- Constraints
    CONSTRAINT pk_dim_driver PRIMARY KEY (driver_key),
    CONSTRAINT uk_dim_driver_id UNIQUE (driver_id)
)
COMMENT = 'Dimensión de pilotos de Fórmula 1 para análisis';

-- =====================================================
-- Dimension: dim_race
-- Description: Race dimension
-- Source: Silver.stg_race_results (distinct races)
-- =====================================================
CREATE OR REPLACE TABLE dim_race (
    race_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Surrogate key de la carrera',
    race_id NUMBER(38,0) NOT NULL COMMENT 'ID natural de la carrera',
    race_name VARCHAR(255) COMMENT 'Nombre de la carrera',
    circuit_name VARCHAR(255) COMMENT 'Nombre del circuito',
    race_date DATE COMMENT 'Fecha de la carrera',
    race_year NUMBER(4,0) COMMENT 'Año de la carrera',
    race_round NUMBER(2,0) COMMENT 'Ronda del campeonato',
    country VARCHAR(100) COMMENT 'País donde se celebra la carrera',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Silver.stg_race_results' COMMENT 'Sistema origen del dato',
    
    -- Constraints
    CONSTRAINT pk_dim_race PRIMARY KEY (race_key),
    CONSTRAINT uk_dim_race_id UNIQUE (race_id)
)
COMMENT = 'Dimensión de carreras de Fórmula 1 para análisis';

-- =====================================================
-- Dimension: dim_status
-- Description: Race finish status dimension
-- Source: Silver.stg_race_results (distinct status)
-- =====================================================
CREATE OR REPLACE TABLE dim_status (
    status_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Surrogate key del estado',
    status_id NUMBER(38,0) NOT NULL COMMENT 'ID natural del estado',
    status_name VARCHAR(100) COMMENT 'Nombre del estado de finalización',
    status_category VARCHAR(50) COMMENT 'Categoría del estado (Finished, Accident, Technical, etc.)',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Silver.stg_race_results' COMMENT 'Sistema origen del dato',
    
    -- Constraints
    CONSTRAINT pk_dim_status PRIMARY KEY (status_key),
    CONSTRAINT uk_dim_status_id UNIQUE (status_id)
)
COMMENT = 'Dimensión de estados de finalización de carrera';

-- =====================================================
-- FACT TABLES
-- =====================================================

-- =====================================================
-- Fact: mart_race_results
-- Description: Fact table for race results (grain: one row per result)
-- Source: Silver.stg_race_results
-- Grain: Result level (driver, race, constructor combination)
-- =====================================================
CREATE OR REPLACE TABLE mart_race_results (
    result_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Surrogate key del resultado',
    
    -- Foreign Keys to Dimensions
    race_key NUMBER(38,0) NOT NULL COMMENT 'Foreign key a dim_race',
    driver_key NUMBER(38,0) NOT NULL COMMENT 'Foreign key a dim_driver',
    constructor_key NUMBER(38,0) NOT NULL COMMENT 'Foreign key a dim_constructor',
    status_key NUMBER(38,0) COMMENT 'Foreign key a dim_status',
    
    -- Natural Key
    result_id NUMBER(38,0) NOT NULL COMMENT 'ID natural del resultado',
    
    -- Measures - Race Position
    car_number NUMBER(38,0) COMMENT 'Número del coche',
    grid_position NUMBER(38,0) COMMENT 'Posición de salida en la parrilla',
    final_position NUMBER(38,0) COMMENT 'Posición final en la carrera',
    position_order NUMBER(38,0) COMMENT 'Orden de posición',
    grid_gain NUMBER(38,0) COMMENT 'Posiciones ganadas desde la parrilla',
    
    -- Measures - Points and Performance
    points_earned FLOAT COMMENT 'Puntos obtenidos en la carrera',
    laps_completed NUMBER(38,0) COMMENT 'Número de vueltas completadas',
    race_time_text VARCHAR(50) COMMENT 'Tiempo total de carrera (texto)',
    race_milliseconds NUMBER(38,0) COMMENT 'Tiempo total en milisegundos',
    
    -- Measures - Fastest Lap
    fastest_lap_number NUMBER(38,0) COMMENT 'Número de vuelta más rápida',
    fastest_lap_rank NUMBER(38,0) COMMENT 'Ranking de vuelta rápida',
    fastest_lap_time VARCHAR(50) COMMENT 'Tiempo de vuelta más rápida',
    fastest_lap_speed FLOAT COMMENT 'Velocidad de vuelta más rápida (km/h)',
    
    -- Flags and Categories
    is_finished BOOLEAN COMMENT 'Indica si completó la carrera',
    is_podium BOOLEAN COMMENT 'Indica si llegó al podium (top 3)',
    is_winner BOOLEAN COMMENT 'Indica si ganó la carrera',
    is_points BOOLEAN COMMENT 'Indica si obtuvo puntos',
    
    -- Audit columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Timestamp de última actualización',
    _source STRING DEFAULT 'Silver.stg_race_results' COMMENT 'Sistema origen del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_race_results PRIMARY KEY (result_key),
    CONSTRAINT uk_mart_race_results_id UNIQUE (result_id),
    CONSTRAINT fk_mart_race_key FOREIGN KEY (race_key) REFERENCES dim_race(race_key),
    CONSTRAINT fk_mart_driver_key FOREIGN KEY (driver_key) REFERENCES dim_driver(driver_key),
    CONSTRAINT fk_mart_constructor_key FOREIGN KEY (constructor_key) REFERENCES dim_constructor(constructor_key),
    CONSTRAINT fk_mart_status_key FOREIGN KEY (status_key) REFERENCES dim_status(status_key)
)
CLUSTER BY (race_key)
COMMENT = 'Fact table de resultados de carreras de Fórmula 1 - Star Schema para Power BI';

-- =====================================================
-- Create indexes for performance
-- =====================================================

-- Indexes on dimensions
CREATE INDEX IF NOT EXISTS idx_dim_constructor_ref ON dim_constructor(constructor_ref);
CREATE INDEX IF NOT EXISTS idx_dim_driver_ref ON dim_driver(driver_ref);
CREATE INDEX IF NOT EXISTS idx_dim_driver_code ON dim_driver(driver_code);
CREATE INDEX IF NOT EXISTS idx_dim_race_date ON dim_race(race_date);
CREATE INDEX IF NOT EXISTS idx_dim_race_year ON dim_race(race_year);

-- Indexes on fact table
CREATE INDEX IF NOT EXISTS idx_mart_race ON mart_race_results(race_key);
CREATE INDEX IF NOT EXISTS idx_mart_driver ON mart_race_results(driver_key);
CREATE INDEX IF NOT EXISTS idx_mart_constructor ON mart_race_results(constructor_key);
CREATE INDEX IF NOT EXISTS idx_mart_points ON mart_race_results(points_earned);

-- =====================================================
-- Create views for Power BI consumption
-- =====================================================

-- View: Summary by Constructor
CREATE OR REPLACE VIEW vw_constructor_performance AS
SELECT 
    dc.constructor_name,
    dc.nationality,
    COUNT(DISTINCT mr.race_key) AS total_races,
    SUM(mr.points_earned) AS total_points,
    COUNT(CASE WHEN mr.is_winner THEN 1 END) AS total_wins,
    COUNT(CASE WHEN mr.is_podium THEN 1 END) AS total_podiums,
    AVG(mr.final_position) AS avg_position,
    AVG(mr.points_earned) AS avg_points_per_race
FROM mart_race_results mr
JOIN dim_constructor dc ON mr.constructor_key = dc.constructor_key
WHERE mr.is_finished = TRUE
GROUP BY dc.constructor_name, dc.nationality;

-- View: Summary by Driver
CREATE OR REPLACE VIEW vw_driver_performance AS
SELECT 
    dd.full_name,
    dd.driver_code,
    dd.nationality,
    COUNT(DISTINCT mr.race_key) AS total_races,
    SUM(mr.points_earned) AS total_points,
    COUNT(CASE WHEN mr.is_winner THEN 1 END) AS total_wins,
    COUNT(CASE WHEN mr.is_podium THEN 1 END) AS total_podiums,
    AVG(mr.final_position) AS avg_position,
    AVG(mr.points_earned) AS avg_points_per_race
FROM mart_race_results mr
JOIN dim_driver dd ON mr.driver_key = dd.driver_key
WHERE mr.is_finished = TRUE
GROUP BY dd.full_name, dd.driver_code, dd.nationality;

-- View: Race Results Detail
CREATE OR REPLACE VIEW vw_race_results_detail AS
SELECT 
    dr.race_name,
    dr.race_date,
    dr.race_year,
    dr.circuit_name,
    dr.country,
    dd.full_name AS driver_name,
    dd.driver_code,
    dc.constructor_name,
    mr.final_position,
    mr.grid_position,
    mr.grid_gain,
    mr.points_earned,
    mr.laps_completed,
    mr.fastest_lap_time,
    mr.fastest_lap_speed,
    ds.status_name,
    mr.is_finished,
    mr.is_podium,
    mr.is_winner
FROM mart_race_results mr
JOIN dim_race dr ON mr.race_key = dr.race_key
JOIN dim_driver dd ON mr.driver_key = dd.driver_key
JOIN dim_constructor dc ON mr.constructor_key = dc.constructor_key
LEFT JOIN dim_status ds ON mr.status_key = ds.status_key;

-- =====================================================
-- Create summary view for monitoring
-- =====================================================

CREATE OR REPLACE VIEW vw_gold_summary AS
SELECT 
    'dim_constructor' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM dim_constructor
UNION ALL
SELECT 
    'dim_driver' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM dim_driver
UNION ALL
SELECT 
    'dim_race' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM dim_race
UNION ALL
SELECT 
    'dim_status' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM dim_status
UNION ALL
SELECT 
    'mart_race_results' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS last_updated
FROM mart_race_results;

-- Information
SELECT 'Gold layer star schema created successfully' AS STATUS;
