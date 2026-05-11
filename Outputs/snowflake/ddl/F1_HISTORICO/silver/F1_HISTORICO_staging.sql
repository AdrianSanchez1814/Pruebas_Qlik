-- =====================================================================
-- Silver Layer DDL - F1 Histórico Staging Tables
-- Aqualia - Snowflake Data Model
-- =====================================================================
-- Purpose: Cleaned and conformed tables with correct data types
-- Layer: Silver (Staging Data)
-- Schema: F1_HISTORICO.SILVER
-- Source: F1_HISTORICO.BRONZE layer tables
-- =====================================================================

USE SCHEMA F1_HISTORICO.SILVER;

-- =====================================================================
-- STG_CONSTRUCTOR
-- =====================================================================
-- Descripción: Tabla staging con información limpia de constructores
-- Fuente: F1_HISTORICO.BRONZE.raw_constructor
-- Transformaciones aplicadas:
--   - Conversión de tipos de datos apropiados
--   - Limpieza de claves
--   - Estandarización de nombres
--   - Eliminación de duplicados
-- =====================================================================
CREATE OR REPLACE TABLE stg_constructor (
    -- Clave primaria
    constructor_key NUMBER AUTOINCREMENT COMMENT 'Clave surrogate del constructor',
    constructorRef STRING NOT NULL COMMENT 'Referencia única del constructor (clave de negocio)',
    
    -- Campos de negocio
    constructor_name STRING COMMENT 'Nombre del constructor',
    nationality STRING COMMENT 'Nacionalidad del constructor',
    url STRING COMMENT 'URL de referencia del constructor',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'BRONZE.raw_constructor' COMMENT 'Sistema fuente del dato',
    
    -- Constraint
    CONSTRAINT pk_stg_constructor PRIMARY KEY (constructor_key),
    CONSTRAINT uk_stg_constructor UNIQUE (constructorRef)
)
COMMENT = 'Tabla staging con datos limpios de constructores de Fórmula 1';

-- =====================================================================
-- STG_DRIVERS
-- =====================================================================
-- Descripción: Tabla staging con información limpia de pilotos
-- Fuente: F1_HISTORICO.BRONZE.raw_drivers
-- Transformaciones aplicadas:
--   - Conversión de tipos de datos apropiados
--   - Conversión de fecha de nacimiento a DATE
--   - Limpieza de claves
--   - Estandarización de nombres
--   - Eliminación de duplicados
-- =====================================================================
CREATE OR REPLACE TABLE stg_drivers (
    -- Clave primaria
    driver_key NUMBER AUTOINCREMENT COMMENT 'Clave surrogate del piloto',
    driverId NUMBER NOT NULL COMMENT 'Identificador único del piloto (clave de negocio)',
    
    -- Campos de negocio
    driverRef STRING COMMENT 'Referencia del piloto',
    driver_number NUMBER COMMENT 'Número del piloto',
    driver_code STRING COMMENT 'Código del piloto (ej: HAM, VER)',
    forename STRING COMMENT 'Nombre del piloto',
    surname STRING COMMENT 'Apellido del piloto',
    full_name STRING COMMENT 'Nombre completo del piloto',
    date_of_birth DATE COMMENT 'Fecha de nacimiento',
    nationality STRING COMMENT 'Nacionalidad del piloto',
    url STRING COMMENT 'URL de referencia del piloto',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'BRONZE.raw_drivers' COMMENT 'Sistema fuente del dato',
    
    -- Constraint
    CONSTRAINT pk_stg_drivers PRIMARY KEY (driver_key),
    CONSTRAINT uk_stg_drivers UNIQUE (driverId)
)
COMMENT = 'Tabla staging con datos limpios de pilotos de Fórmula 1';

-- =====================================================================
-- STG_RACES
-- =====================================================================
-- Descripción: Tabla staging con información de carreras (extraída de resultados)
-- Fuente: F1_HISTORICO.BRONZE.raw_resultados (campos de carrera)
-- Transformaciones aplicadas:
--   - Extracción de información única de carreras
--   - Conversión de tipos de datos
--   - Eliminación de duplicados
-- =====================================================================
CREATE OR REPLACE TABLE stg_races (
    -- Clave primaria
    race_key NUMBER AUTOINCREMENT COMMENT 'Clave surrogate de la carrera',
    raceId NUMBER NOT NULL COMMENT 'Identificador único de la carrera (clave de negocio)',
    
    -- Campos de negocio (a poblar desde fuente o transformación)
    race_year NUMBER COMMENT 'Año de la carrera',
    race_round NUMBER COMMENT 'Ronda del campeonato',
    circuit_name STRING COMMENT 'Nombre del circuito',
    race_date DATE COMMENT 'Fecha de la carrera',
    race_name STRING COMMENT 'Nombre de la carrera',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'BRONZE.raw_resultados' COMMENT 'Sistema fuente del dato',
    
    -- Constraint
    CONSTRAINT pk_stg_races PRIMARY KEY (race_key),
    CONSTRAINT uk_stg_races UNIQUE (raceId)
)
COMMENT = 'Tabla staging con datos limpios de carreras de Fórmula 1';

-- =====================================================================
-- STG_RACE_RESULTS
-- =====================================================================
-- Descripción: Tabla staging con resultados limpios de carreras
-- Fuente: F1_HISTORICO.BRONZE.raw_resultados
-- Transformaciones aplicadas:
--   - Conversión de tipos de datos numéricos
--   - Conversión de campos de tiempo
--   - Limpieza de claves foráneas
--   - Manejo de valores nulos
--   - Eliminación de duplicados
-- =====================================================================
CREATE OR REPLACE TABLE stg_race_results (
    -- Clave primaria
    result_key NUMBER AUTOINCREMENT COMMENT 'Clave surrogate del resultado',
    resultId NUMBER NOT NULL COMMENT 'Identificador único del resultado (clave de negocio)',
    
    -- Claves foráneas
    raceId NUMBER NOT NULL COMMENT 'Identificador de la carrera',
    driverId NUMBER NOT NULL COMMENT 'Identificador del piloto',
    constructorRef STRING NOT NULL COMMENT 'Referencia del constructor',
    
    -- Campos de resultados
    driver_number NUMBER COMMENT 'Número del piloto en la carrera',
    grid_position NUMBER COMMENT 'Posición de salida en la parrilla',
    final_position NUMBER COMMENT 'Posición final en la carrera',
    position_text STRING COMMENT 'Texto de la posición final (incluye DNF, DSQ, etc.)',
    position_order NUMBER COMMENT 'Orden de posición para ordenamiento',
    points_scored DECIMAL(10,2) COMMENT 'Puntos obtenidos',
    laps_completed NUMBER COMMENT 'Número de vueltas completadas',
    race_time STRING COMMENT 'Tiempo total de carrera',
    race_time_milliseconds NUMBER COMMENT 'Tiempo en milisegundos',
    fastest_lap NUMBER COMMENT 'Número de vuelta más rápida',
    fastest_lap_rank NUMBER COMMENT 'Ranking de la vuelta más rápida',
    fastest_lap_time STRING COMMENT 'Tiempo de la vuelta más rápida',
    fastest_lap_speed DECIMAL(10,3) COMMENT 'Velocidad de la vuelta más rápida en km/h',
    status_id NUMBER COMMENT 'Identificador del estado del resultado',
    
    -- Campos adicionales
    campo_json VARIANT COMMENT 'Datos adicionales en formato JSON',
    
    -- Campos calculados
    is_finished BOOLEAN COMMENT 'Indica si el piloto terminó la carrera',
    is_winner BOOLEAN COMMENT 'Indica si el piloto ganó la carrera',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'BRONZE.raw_resultados' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_stg_race_results PRIMARY KEY (result_key),
    CONSTRAINT uk_stg_race_results UNIQUE (resultId)
)
COMMENT = 'Tabla staging con resultados limpios de carreras de Fórmula 1';

-- =====================================================================
-- INT_DRIVER_CONSTRUCTOR
-- =====================================================================
-- Descripción: Tabla intermedia para relacionar pilotos con constructores por carrera
-- Fuente: F1_HISTORICO.SILVER.stg_race_results
-- Propósito: Resolver relaciones many-to-many entre pilotos y constructores
-- =====================================================================
CREATE OR REPLACE TABLE int_driver_constructor (
    -- Clave primaria
    driver_constructor_key NUMBER AUTOINCREMENT COMMENT 'Clave surrogate de la relación',
    
    -- Claves foráneas
    driverId NUMBER NOT NULL COMMENT 'Identificador del piloto',
    constructorRef STRING NOT NULL COMMENT 'Referencia del constructor',
    raceId NUMBER NOT NULL COMMENT 'Identificador de la carrera',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'SILVER.stg_race_results' COMMENT 'Sistema fuente del dato',
    
    -- Constraints
    CONSTRAINT pk_int_driver_constructor PRIMARY KEY (driver_constructor_key),
    CONSTRAINT uk_int_driver_constructor UNIQUE (driverId, constructorRef, raceId)
)
COMMENT = 'Tabla intermedia para relacionar pilotos con constructores por carrera';

-- =====================================================================
-- Confirmation
-- =====================================================================
SELECT 'Silver layer tables created successfully: stg_constructor, stg_drivers, stg_races, stg_race_results, int_driver_constructor' AS status;
