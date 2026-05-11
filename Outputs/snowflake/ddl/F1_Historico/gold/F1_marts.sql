-- =====================================================
-- Gold Layer: Data Marts (Star Schema)
-- =====================================================
-- Schema: F1_HISTORICO.GOLD
-- Purpose: Business consumption layer optimized for Power BI
-- Model: Star Schema with dimension and fact tables
-- =====================================================

USE SCHEMA F1_HISTORICO.GOLD;

-- =====================================================
-- DIMENSION TABLES
-- =====================================================

-- =====================================================
-- Dimension: dim_constructor
-- Description: Dimensión de constructores para análisis de BI
-- Type: SCD Type 1
-- Grain: Un registro por constructor
-- =====================================================
CREATE OR REPLACE TABLE dim_constructor (
    -- Surrogate Key
    constructor_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Clave sustituta del constructor',
    
    -- Business Key
    constructor_id NUMBER(38,0) NOT NULL COMMENT 'ID del constructor (natural key)',
    
    -- Descriptive Attributes
    constructor_ref VARCHAR(255) NOT NULL COMMENT 'Referencia del constructor',
    constructor_name VARCHAR(500) NOT NULL COMMENT 'Nombre del constructor',
    constructor_nationality VARCHAR(255) COMMENT 'Nacionalidad del constructor',
    constructor_nationality_group VARCHAR(100) COMMENT 'Grupo de nacionalidad (Europa, Asia, América)',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de actualización',
    _source VARCHAR(500) COMMENT 'Origen de datos',
    
    -- Constraints
    CONSTRAINT pk_dim_constructor PRIMARY KEY (constructor_key),
    CONSTRAINT uk_dim_constructor UNIQUE (constructor_id)
)
COMMENT = 'Dimensión de Constructores para análisis de BI'
;

-- =====================================================
-- Dimension: dim_driver
-- Description: Dimensión de pilotos para análisis de BI
-- Type: SCD Type 1
-- Grain: Un registro por piloto
-- =====================================================
CREATE OR REPLACE TABLE dim_driver (
    -- Surrogate Key
    driver_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Clave sustituta del piloto',
    
    -- Business Key
    driver_id NUMBER(38,0) NOT NULL COMMENT 'ID del piloto (natural key)',
    
    -- Descriptive Attributes
    driver_ref VARCHAR(255) NOT NULL COMMENT 'Referencia del piloto',
    driver_code VARCHAR(10) COMMENT 'Código del piloto',
    driver_number NUMBER(38,0) COMMENT 'Número del piloto',
    driver_forename VARCHAR(255) NOT NULL COMMENT 'Nombre del piloto',
    driver_surname VARCHAR(500) NOT NULL COMMENT 'Apellido del piloto',
    driver_full_name VARCHAR(755) COMMENT 'Nombre completo del piloto',
    date_of_birth DATE COMMENT 'Fecha de nacimiento',
    driver_age NUMBER(38,0) COMMENT 'Edad del piloto',
    driver_nationality VARCHAR(255) COMMENT 'Nacionalidad del piloto',
    driver_nationality_group VARCHAR(100) COMMENT 'Grupo de nacionalidad',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de actualización',
    _source VARCHAR(500) COMMENT 'Origen de datos',
    
    -- Constraints
    CONSTRAINT pk_dim_driver PRIMARY KEY (driver_key),
    CONSTRAINT uk_dim_driver UNIQUE (driver_id)
)
COMMENT = 'Dimensión de Pilotos para análisis de BI'
;

-- =====================================================
-- Dimension: dim_race (Placeholder - to be populated from additional source)
-- Description: Dimensión de carreras
-- Type: SCD Type 1
-- Grain: Un registro por carrera
-- Note: Esta dimensión necesitará ser alimentada con datos adicionales de carreras
-- =====================================================
CREATE OR REPLACE TABLE dim_race (
    -- Surrogate Key
    race_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Clave sustituta de la carrera',
    
    -- Business Key
    race_id NUMBER(38,0) NOT NULL COMMENT 'ID de la carrera (natural key)',
    
    -- Descriptive Attributes
    race_year NUMBER(4,0) COMMENT 'Año de la carrera',
    race_round NUMBER(38,0) COMMENT 'Ronda de la carrera en la temporada',
    circuit_name VARCHAR(500) COMMENT 'Nombre del circuito',
    race_name VARCHAR(500) COMMENT 'Nombre de la carrera',
    race_date DATE COMMENT 'Fecha de la carrera',
    circuit_location VARCHAR(255) COMMENT 'Ubicación del circuito',
    circuit_country VARCHAR(255) COMMENT 'País del circuito',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de actualización',
    _source VARCHAR(500) COMMENT 'Origen de datos',
    
    -- Constraints
    CONSTRAINT pk_dim_race PRIMARY KEY (race_key),
    CONSTRAINT uk_dim_race UNIQUE (race_id)
)
COMMENT = 'Dimensión de Carreras para análisis de BI (requiere datos adicionales)'
;

-- =====================================================
-- Dimension: dim_status (Placeholder - to be populated from additional source)
-- Description: Dimensión de estados de resultado
-- Type: SCD Type 1
-- Grain: Un registro por estado
-- =====================================================
CREATE OR REPLACE TABLE dim_status (
    -- Surrogate Key
    status_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Clave sustituta del estado',
    
    -- Business Key
    status_id NUMBER(38,0) NOT NULL COMMENT 'ID del estado (natural key)',
    
    -- Descriptive Attributes
    status_name VARCHAR(255) COMMENT 'Nombre del estado',
    status_category VARCHAR(100) COMMENT 'Categoría del estado (Finished, Mechanical, Accident, etc.)',
    is_finished BOOLEAN COMMENT 'Indicador si terminó la carrera',
    is_classified BOOLEAN COMMENT 'Indicador si fue clasificado',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de actualización',
    _source VARCHAR(500) COMMENT 'Origen de datos',
    
    -- Constraints
    CONSTRAINT pk_dim_status PRIMARY KEY (status_key),
    CONSTRAINT uk_dim_status UNIQUE (status_id)
)
COMMENT = 'Dimensión de Estados de Resultado para análisis de BI (requiere datos adicionales)'
;

-- =====================================================
-- FACT TABLES
-- =====================================================

-- =====================================================
-- Fact: fact_race_result
-- Description: Tabla de hechos de resultados de carreras
-- Type: Transaction Fact Table
-- Grain: Un registro por resultado de piloto en una carrera
-- =====================================================
CREATE OR REPLACE TABLE fact_race_result (
    -- Surrogate Key
    result_key NUMBER(38,0) AUTOINCREMENT COMMENT 'Clave sustituta del resultado',
    
    -- Business Key
    result_id NUMBER(38,0) NOT NULL COMMENT 'ID del resultado (natural key)',
    
    -- Foreign Keys (Dimension Keys)
    race_key NUMBER(38,0) NOT NULL COMMENT 'Clave de la carrera',
    driver_key NUMBER(38,0) NOT NULL COMMENT 'Clave del piloto',
    constructor_key NUMBER(38,0) NOT NULL COMMENT 'Clave del constructor',
    status_key NUMBER(38,0) COMMENT 'Clave del estado',
    
    -- Degenerate Dimensions
    car_number NUMBER(38,0) COMMENT 'Número del coche',
    grid_position NUMBER(38,0) COMMENT 'Posición en parrilla',
    final_position NUMBER(38,0) COMMENT 'Posición final',
    final_position_text VARCHAR(50) COMMENT 'Posición final texto',
    position_order NUMBER(38,0) COMMENT 'Orden de posición',
    
    -- Metrics/Facts
    points_earned NUMBER(38,2) DEFAULT 0 COMMENT 'Puntos obtenidos',
    laps_completed NUMBER(38,0) COMMENT 'Vueltas completadas',
    race_time_milliseconds NUMBER(38,0) COMMENT 'Tiempo de carrera en ms',
    race_time_seconds NUMBER(38,2) COMMENT 'Tiempo de carrera en segundos',
    race_time_minutes NUMBER(38,2) COMMENT 'Tiempo de carrera en minutos',
    
    -- Fastest Lap Metrics
    fastest_lap_number NUMBER(38,0) COMMENT 'Número de vuelta más rápida',
    fastest_lap_rank NUMBER(38,0) COMMENT 'Ranking de vuelta más rápida',
    fastest_lap_speed NUMBER(38,3) COMMENT 'Velocidad de vuelta más rápida',
    fastest_lap_time VARCHAR(50) COMMENT 'Tiempo de vuelta más rápida',
    
    -- Flags
    is_finished BOOLEAN COMMENT 'Terminó la carrera',
    is_classified BOOLEAN COMMENT 'Fue clasificado',
    is_winner BOOLEAN COMMENT 'Ganó la carrera',
    is_podium BOOLEAN COMMENT 'Finalizó en podio (top 3)',
    is_points_position BOOLEAN COMMENT 'Finalizó en posición de puntos',
    has_fastest_lap BOOLEAN COMMENT 'Tuvo la vuelta más rápida',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de actualización',
    _source VARCHAR(500) COMMENT 'Origen de datos',
    
    -- Constraints
    CONSTRAINT pk_fact_race_result PRIMARY KEY (result_key),
    CONSTRAINT uk_fact_race_result UNIQUE (result_id),
    CONSTRAINT fk_fact_race FOREIGN KEY (race_key) REFERENCES dim_race(race_key),
    CONSTRAINT fk_fact_driver FOREIGN KEY (driver_key) REFERENCES dim_driver(driver_key),
    CONSTRAINT fk_fact_constructor FOREIGN KEY (constructor_key) REFERENCES dim_constructor(constructor_key),
    CONSTRAINT fk_fact_status FOREIGN KEY (status_key) REFERENCES dim_status(status_key)
)
COMMENT = 'Tabla de Hechos - Resultados de Carreras de F1 optimizada para Power BI'
CLUSTER BY (race_key, driver_key, constructor_key)
;

-- =====================================================
-- AGGREGATE TABLES (For Performance)
-- =====================================================

-- =====================================================
-- Aggregate: mart_driver_stats
-- Description: Estadísticas agregadas por piloto
-- Purpose: Optimizar consultas de análisis de pilotos
-- =====================================================
CREATE OR REPLACE TABLE mart_driver_stats (
    driver_key NUMBER(38,0) NOT NULL COMMENT 'Clave del piloto',
    
    -- Aggregated Metrics
    total_races NUMBER(38,0) COMMENT 'Total de carreras',
    total_wins NUMBER(38,0) COMMENT 'Total de victorias',
    total_podiums NUMBER(38,0) COMMENT 'Total de podios',
    total_points NUMBER(38,2) COMMENT 'Total de puntos',
    total_pole_positions NUMBER(38,0) COMMENT 'Total de pole positions',
    total_fastest_laps NUMBER(38,0) COMMENT 'Total de vueltas más rápidas',
    avg_finish_position NUMBER(38,2) COMMENT 'Promedio de posición final',
    dnf_count NUMBER(38,0) COMMENT 'Número de carreras sin finalizar',
    dnf_rate NUMBER(5,2) COMMENT 'Tasa de abandono (%)',
    points_per_race NUMBER(38,2) COMMENT 'Puntos promedio por carrera',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de actualización',
    _source VARCHAR(500) COMMENT 'Origen de datos',
    
    -- Constraints
    CONSTRAINT pk_mart_driver_stats PRIMARY KEY (driver_key),
    CONSTRAINT fk_mart_driver_stats FOREIGN KEY (driver_key) REFERENCES dim_driver(driver_key)
)
COMMENT = 'Tabla agregada - Estadísticas de Pilotos para Power BI'
;

-- =====================================================
-- Aggregate: mart_constructor_stats
-- Description: Estadísticas agregadas por constructor
-- Purpose: Optimizar consultas de análisis de constructores
-- =====================================================
CREATE OR REPLACE TABLE mart_constructor_stats (
    constructor_key NUMBER(38,0) NOT NULL COMMENT 'Clave del constructor',
    
    -- Aggregated Metrics
    total_races NUMBER(38,0) COMMENT 'Total de carreras',
    total_wins NUMBER(38,0) COMMENT 'Total de victorias',
    total_podiums NUMBER(38,0) COMMENT 'Total de podios',
    total_points NUMBER(38,2) COMMENT 'Total de puntos',
    total_fastest_laps NUMBER(38,0) COMMENT 'Total de vueltas más rápidas',
    avg_finish_position NUMBER(38,2) COMMENT 'Promedio de posición final',
    dnf_count NUMBER(38,0) COMMENT 'Número de carreras sin finalizar',
    dnf_rate NUMBER(5,2) COMMENT 'Tasa de abandono (%)',
    points_per_race NUMBER(38,2) COMMENT 'Puntos promedio por carrera',
    
    -- Audit Columns
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de actualización',
    _source VARCHAR(500) COMMENT 'Origen de datos',
    
    -- Constraints
    CONSTRAINT pk_mart_constructor_stats PRIMARY KEY (constructor_key),
    CONSTRAINT fk_mart_constructor_stats FOREIGN KEY (constructor_key) REFERENCES dim_constructor(constructor_key)
)
COMMENT = 'Tabla agregada - Estadísticas de Constructores para Power BI'
;

-- =====================================================
-- VIEWS FOR POWER BI
-- =====================================================

-- View: vw_race_results_detailed
CREATE OR REPLACE VIEW vw_race_results_detailed AS
SELECT 
    -- IDs
    f.result_id,
    f.result_key,
    
    -- Race Information
    r.race_id,
    r.race_year,
    r.race_round,
    r.race_name,
    r.race_date,
    r.circuit_name,
    r.circuit_country,
    
    -- Driver Information
    d.driver_id,
    d.driver_full_name,
    d.driver_code,
    d.driver_nationality,
    
    -- Constructor Information
    c.constructor_id,
    c.constructor_name,
    c.constructor_nationality,
    
    -- Result Information
    f.grid_position,
    f.final_position,
    f.final_position_text,
    f.points_earned,
    f.laps_completed,
    f.race_time_minutes,
    f.fastest_lap_speed,
    f.fastest_lap_rank,
    
    -- Flags
    f.is_winner,
    f.is_podium,
    f.is_points_position,
    f.is_finished,
    f.has_fastest_lap
    
FROM fact_race_result f
INNER JOIN dim_race r ON f.race_key = r.race_key
INNER JOIN dim_driver d ON f.driver_key = d.driver_key
INNER JOIN dim_constructor c ON f.constructor_key = c.constructor_key
COMMENT = 'Vista detallada de resultados para Power BI';

-- View: vw_driver_performance
CREATE OR REPLACE VIEW vw_driver_performance AS
SELECT 
    d.driver_id,
    d.driver_full_name,
    d.driver_nationality,
    s.total_races,
    s.total_wins,
    s.total_podiums,
    s.total_points,
    s.total_fastest_laps,
    s.avg_finish_position,
    s.dnf_rate,
    s.points_per_race
FROM dim_driver d
LEFT JOIN mart_driver_stats s ON d.driver_key = s.driver_key
COMMENT = 'Vista de rendimiento de pilotos para Power BI';

-- View: vw_constructor_performance
CREATE OR REPLACE VIEW vw_constructor_performance AS
SELECT 
    c.constructor_id,
    c.constructor_name,
    c.constructor_nationality,
    s.total_races,
    s.total_wins,
    s.total_podiums,
    s.total_points,
    s.total_fastest_laps,
    s.avg_finish_position,
    s.dnf_rate,
    s.points_per_race
FROM dim_constructor c
LEFT JOIN mart_constructor_stats s ON c.constructor_key = s.constructor_key
COMMENT = 'Vista de rendimiento de constructores para Power BI';
