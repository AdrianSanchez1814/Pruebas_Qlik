-- =====================================================================
-- Gold Layer DDL - F1 Histórico Data Marts
-- Aqualia - Snowflake Data Model
-- =====================================================================
-- Purpose: Star schema optimized for Power BI consumption
-- Layer: Gold (Business Data Marts)
-- Schema: F1_HISTORICO.GOLD
-- Source: F1_HISTORICO.SILVER layer tables
-- =====================================================================

USE SCHEMA F1_HISTORICO.GOLD;

-- =====================================================================
-- DIMENSION TABLES
-- =====================================================================

-- =====================================================================
-- DIM_DRIVER
-- =====================================================================
-- Descripción: Dimensión de pilotos para análisis de BI
-- Fuente: F1_HISTORICO.SILVER.stg_drivers
-- Tipo: Dimensión SCD Tipo 1
-- =====================================================================
CREATE OR REPLACE TABLE mart_dim_driver (
    -- Clave primaria
    driver_key NUMBER NOT NULL COMMENT 'Clave surrogate del piloto',
    
    -- Claves de negocio
    driver_id NUMBER NOT NULL COMMENT 'Identificador del piloto',
    driver_ref STRING COMMENT 'Referencia del piloto',
    
    -- Atributos descriptivos
    driver_number NUMBER COMMENT 'Número del piloto',
    driver_code STRING COMMENT 'Código del piloto (ej: HAM, VER, ALO)',
    first_name STRING COMMENT 'Nombre del piloto',
    last_name STRING COMMENT 'Apellido del piloto',
    full_name STRING COMMENT 'Nombre completo del piloto',
    date_of_birth DATE COMMENT 'Fecha de nacimiento',
    age_years NUMBER COMMENT 'Edad en años',
    nationality STRING COMMENT 'Nacionalidad del piloto',
    driver_url STRING COMMENT 'URL de referencia del piloto',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'SILVER.stg_drivers' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_dim_driver PRIMARY KEY (driver_key),
    CONSTRAINT uk_mart_dim_driver UNIQUE (driver_id)
)
COMMENT = 'Dimensión de pilotos para análisis de BI - F1 Histórico';

-- =====================================================================
-- DIM_CONSTRUCTOR
-- =====================================================================
-- Descripción: Dimensión de constructores para análisis de BI
-- Fuente: F1_HISTORICO.SILVER.stg_constructor
-- Tipo: Dimensión SCD Tipo 1
-- =====================================================================
CREATE OR REPLACE TABLE mart_dim_constructor (
    -- Clave primaria
    constructor_key NUMBER NOT NULL COMMENT 'Clave surrogate del constructor',
    
    -- Claves de negocio
    constructor_ref STRING NOT NULL COMMENT 'Referencia del constructor',
    
    -- Atributos descriptivos
    constructor_name STRING COMMENT 'Nombre del constructor',
    nationality STRING COMMENT 'Nacionalidad del constructor',
    constructor_url STRING COMMENT 'URL de referencia del constructor',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'SILVER.stg_constructor' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_dim_constructor PRIMARY KEY (constructor_key),
    CONSTRAINT uk_mart_dim_constructor UNIQUE (constructor_ref)
)
COMMENT = 'Dimensión de constructores para análisis de BI - F1 Histórico';

-- =====================================================================
-- DIM_RACE
-- =====================================================================
-- Descripción: Dimensión de carreras para análisis de BI
-- Fuente: F1_HISTORICO.SILVER.stg_races
-- Tipo: Dimensión SCD Tipo 1
-- =====================================================================
CREATE OR REPLACE TABLE mart_dim_race (
    -- Clave primaria
    race_key NUMBER NOT NULL COMMENT 'Clave surrogate de la carrera',
    
    -- Claves de negocio
    race_id NUMBER NOT NULL COMMENT 'Identificador de la carrera',
    
    -- Atributos descriptivos
    race_year NUMBER COMMENT 'Año de la carrera',
    race_round NUMBER COMMENT 'Ronda del campeonato',
    race_name STRING COMMENT 'Nombre de la carrera',
    circuit_name STRING COMMENT 'Nombre del circuito',
    race_date DATE COMMENT 'Fecha de la carrera',
    
    -- Jerarquías para Power BI
    decade NUMBER COMMENT 'Década de la carrera',
    season STRING COMMENT 'Temporada de la carrera',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'SILVER.stg_races' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_dim_race PRIMARY KEY (race_key),
    CONSTRAINT uk_mart_dim_race UNIQUE (race_id)
)
COMMENT = 'Dimensión de carreras para análisis de BI - F1 Histórico';

-- =====================================================================
-- DIM_DATE
-- =====================================================================
-- Descripción: Dimensión de fechas para análisis temporal
-- Fuente: Generada
-- Tipo: Dimensión conformada
-- =====================================================================
CREATE OR REPLACE TABLE mart_dim_date (
    -- Clave primaria
    date_key NUMBER NOT NULL COMMENT 'Clave de fecha en formato YYYYMMDD',
    
    -- Fecha
    full_date DATE NOT NULL COMMENT 'Fecha completa',
    
    -- Atributos de día
    day_of_month NUMBER COMMENT 'Día del mes (1-31)',
    day_of_week NUMBER COMMENT 'Día de la semana (1-7)',
    day_of_week_name STRING COMMENT 'Nombre del día de la semana',
    day_of_year NUMBER COMMENT 'Día del año (1-366)',
    
    -- Atributos de semana
    week_of_year NUMBER COMMENT 'Semana del año (1-53)',
    
    -- Atributos de mes
    month_number NUMBER COMMENT 'Número del mes (1-12)',
    month_name STRING COMMENT 'Nombre del mes',
    month_abbrev STRING COMMENT 'Abreviatura del mes',
    
    -- Atributos de trimestre
    quarter_number NUMBER COMMENT 'Número del trimestre (1-4)',
    quarter_name STRING COMMENT 'Nombre del trimestre',
    
    -- Atributos de año
    year_number NUMBER COMMENT 'Año',
    decade NUMBER COMMENT 'Década',
    
    -- Indicadores
    is_weekend BOOLEAN COMMENT 'Indica si es fin de semana',
    is_holiday BOOLEAN COMMENT 'Indica si es día festivo',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'GENERATED' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_dim_date PRIMARY KEY (date_key),
    CONSTRAINT uk_mart_dim_date UNIQUE (full_date)
)
COMMENT = 'Dimensión de fechas para análisis temporal - F1 Histórico';

-- =====================================================================
-- DIM_DRIVER_CONSTRUCTOR
-- =====================================================================
-- Descripción: Dimensión puente para resolver la relación many-to-many
--              entre pilotos y constructores
-- Fuente: F1_HISTORICO.SILVER.int_driver_constructor
-- Tipo: Dimensión puente (Bridge table)
-- Propósito: Separada para evitar problemas de join en el modelo estrella
-- =====================================================================
CREATE OR REPLACE TABLE mart_dim_driver_constructor (
    -- Clave primaria
    driver_constructor_key NUMBER NOT NULL COMMENT 'Clave surrogate de la relación',
    
    -- Claves foráneas
    driver_id NUMBER NOT NULL COMMENT 'Identificador del piloto',
    constructor_ref STRING NOT NULL COMMENT 'Referencia del constructor',
    race_id NUMBER NOT NULL COMMENT 'Identificador de la carrera',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'SILVER.int_driver_constructor' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_dim_driver_constructor PRIMARY KEY (driver_constructor_key),
    CONSTRAINT uk_mart_dim_driver_constructor UNIQUE (driver_id, constructor_ref, race_id)
)
COMMENT = 'Dimensión puente para relacionar pilotos con constructores - F1 Histórico';

-- =====================================================================
-- FACT TABLES
-- =====================================================================

-- =====================================================================
-- FACT_RACE_RESULTS
-- =====================================================================
-- Descripción: Tabla de hechos con resultados de carreras
-- Fuente: F1_HISTORICO.SILVER.stg_race_results
-- Granularidad: Una fila por resultado de carrera (piloto + carrera)
-- Tipo: Fact table transaccional
-- =====================================================================
CREATE OR REPLACE TABLE mart_fact_race_results (
    -- Clave primaria
    result_key NUMBER NOT NULL COMMENT 'Clave surrogate del resultado',
    
    -- Claves foráneas a dimensiones
    driver_key NUMBER NOT NULL COMMENT 'Clave de la dimensión de pilotos',
    constructor_key NUMBER NOT NULL COMMENT 'Clave de la dimensión de constructores',
    race_key NUMBER NOT NULL COMMENT 'Clave de la dimensión de carreras',
    date_key NUMBER NOT NULL COMMENT 'Clave de la dimensión de fechas',
    
    -- Claves de negocio (degeneradas)
    result_id NUMBER NOT NULL COMMENT 'Identificador del resultado',
    
    -- Métricas aditivas
    points_scored DECIMAL(10,2) COMMENT 'Puntos obtenidos en la carrera',
    laps_completed NUMBER COMMENT 'Número de vueltas completadas',
    race_time_milliseconds NUMBER COMMENT 'Tiempo de carrera en milisegundos',
    
    -- Métricas semi-aditivas
    grid_position NUMBER COMMENT 'Posición de salida en la parrilla',
    final_position NUMBER COMMENT 'Posición final en la carrera',
    position_order NUMBER COMMENT 'Orden de posición para ordenamiento',
    driver_number NUMBER COMMENT 'Número del piloto',
    fastest_lap NUMBER COMMENT 'Número de vuelta más rápida',
    fastest_lap_rank NUMBER COMMENT 'Ranking de la vuelta más rápida',
    fastest_lap_speed DECIMAL(10,3) COMMENT 'Velocidad de la vuelta más rápida en km/h',
    
    -- Atributos descriptivos
    position_text STRING COMMENT 'Texto de la posición (incluye DNF, DSQ)',
    race_time STRING COMMENT 'Tiempo de carrera en formato texto',
    fastest_lap_time STRING COMMENT 'Tiempo de la vuelta más rápida',
    status_id NUMBER COMMENT 'Identificador del estado del resultado',
    
    -- Indicadores (flags)
    is_finished BOOLEAN COMMENT 'Indica si terminó la carrera',
    is_winner BOOLEAN COMMENT 'Indica si ganó la carrera',
    is_podium BOOLEAN COMMENT 'Indica si quedó en el podio (top 3)',
    is_points_scorer BOOLEAN COMMENT 'Indica si sumó puntos',
    has_fastest_lap BOOLEAN COMMENT 'Indica si tuvo la vuelta más rápida',
    
    -- Campos adicionales
    campo_json VARIANT COMMENT 'Datos adicionales en formato JSON',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'SILVER.stg_race_results' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_fact_race_results PRIMARY KEY (result_key),
    CONSTRAINT uk_mart_fact_race_results UNIQUE (result_id)
)
CLUSTER BY (date_key, race_key)
COMMENT = 'Tabla de hechos con resultados de carreras - F1 Histórico';

-- =====================================================================
-- FACT_DRIVER_SEASON_SUMMARY
-- =====================================================================
-- Descripción: Tabla de hechos agregada con resumen por piloto y temporada
-- Fuente: F1_HISTORICO.GOLD.mart_fact_race_results
-- Granularidad: Una fila por piloto por temporada
-- Tipo: Fact table agregada
-- =====================================================================
CREATE OR REPLACE TABLE mart_fact_driver_season_summary (
    -- Clave primaria
    driver_season_key NUMBER AUTOINCREMENT COMMENT 'Clave surrogate del resumen',
    
    -- Claves foráneas
    driver_key NUMBER NOT NULL COMMENT 'Clave de la dimensión de pilotos',
    season_year NUMBER NOT NULL COMMENT 'Año de la temporada',
    
    -- Métricas agregadas
    total_points DECIMAL(10,2) COMMENT 'Puntos totales de la temporada',
    total_races NUMBER COMMENT 'Total de carreras participadas',
    total_wins NUMBER COMMENT 'Total de victorias',
    total_podiums NUMBER COMMENT 'Total de podios (top 3)',
    total_pole_positions NUMBER COMMENT 'Total de pole positions',
    total_fastest_laps NUMBER COMMENT 'Total de vueltas más rápidas',
    total_dnf NUMBER COMMENT 'Total de carreras no finalizadas',
    
    -- Métricas calculadas
    average_finish_position DECIMAL(10,2) COMMENT 'Posición promedio de finalización',
    win_rate DECIMAL(5,4) COMMENT 'Tasa de victorias',
    podium_rate DECIMAL(5,4) COMMENT 'Tasa de podios',
    finish_rate DECIMAL(5,4) COMMENT 'Tasa de finalización',
    
    -- Ranking
    championship_position NUMBER COMMENT 'Posición en el campeonato',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'GOLD.mart_fact_race_results' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_fact_driver_season PRIMARY KEY (driver_season_key),
    CONSTRAINT uk_mart_fact_driver_season UNIQUE (driver_key, season_year)
)
COMMENT = 'Tabla de hechos agregada con resumen por piloto y temporada - F1 Histórico';

-- =====================================================================
-- FACT_CONSTRUCTOR_SEASON_SUMMARY
-- =====================================================================
-- Descripción: Tabla de hechos agregada con resumen por constructor y temporada
-- Fuente: F1_HISTORICO.GOLD.mart_fact_race_results
-- Granularidad: Una fila por constructor por temporada
-- Tipo: Fact table agregada
-- =====================================================================
CREATE OR REPLACE TABLE mart_fact_constructor_season_summary (
    -- Clave primaria
    constructor_season_key NUMBER AUTOINCREMENT COMMENT 'Clave surrogate del resumen',
    
    -- Claves foráneas
    constructor_key NUMBER NOT NULL COMMENT 'Clave de la dimensión de constructores',
    season_year NUMBER NOT NULL COMMENT 'Año de la temporada',
    
    -- Métricas agregadas
    total_points DECIMAL(10,2) COMMENT 'Puntos totales de la temporada',
    total_races NUMBER COMMENT 'Total de carreras participadas',
    total_wins NUMBER COMMENT 'Total de victorias',
    total_podiums NUMBER COMMENT 'Total de podios (top 3)',
    total_pole_positions NUMBER COMMENT 'Total de pole positions',
    total_fastest_laps NUMBER COMMENT 'Total de vueltas más rápidas',
    
    -- Métricas calculadas
    average_finish_position DECIMAL(10,2) COMMENT 'Posición promedio de finalización',
    win_rate DECIMAL(5,4) COMMENT 'Tasa de victorias',
    podium_rate DECIMAL(5,4) COMMENT 'Tasa de podios',
    
    -- Ranking
    championship_position NUMBER COMMENT 'Posición en el campeonato de constructores',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'GOLD.mart_fact_race_results' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_mart_fact_constructor_season PRIMARY KEY (constructor_season_key),
    CONSTRAINT uk_mart_fact_constructor_season UNIQUE (constructor_key, season_year)
)
COMMENT = 'Tabla de hechos agregada con resumen por constructor y temporada - F1 Histórico';

-- =====================================================================
-- Confirmation
-- =====================================================================
SELECT 'Gold layer tables created successfully: Dimensions (5) and Facts (3)' AS status;
