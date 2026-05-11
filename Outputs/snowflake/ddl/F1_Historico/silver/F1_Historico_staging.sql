-- =====================================================
-- SILVER LAYER - F1 HISTORICO PROJECT
-- =====================================================
-- Proyecto: F1 Histórico
-- Schema: SILVER (Datos conformados)
-- Fuente: BRONZE layer
-- Descripción: Datos conformados con tipos correctos, claves limpias, nombres estandarizados
-- =====================================================

USE DATABASE F1_HISTORICO;
USE SCHEMA SILVER;

-- =====================================================
-- TABLA: stg_constructor
-- =====================================================
-- Descripción: Constructores de F1 con datos conformados
-- Origen: BRONZE.raw_constructor
-- Transformaciones: Tipos de datos corregidos, claves limpias, eliminación de duplicados
-- =====================================================

CREATE OR REPLACE TABLE stg_constructor (
    -- Clave primaria
    constructor_id NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'ID único autogenerado del constructor',
    
    -- Campos de negocio conformados
    constructor_ref VARCHAR(500) NOT NULL COMMENT 'Referencia única del constructor (limpia y estandarizada)',
    constructor_name VARCHAR(500) NOT NULL COMMENT 'Nombre oficial del constructor',
    nationality VARCHAR(200) COMMENT 'Nacionalidad del constructor',
    info_url VARCHAR(1000) COMMENT 'URL de información oficial del constructor',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'BRONZE.raw_constructor' COMMENT 'Fuente de datos origen',
    
    -- Constraints
    CONSTRAINT uk_constructor_ref UNIQUE (constructor_ref)
)
COMMENT = 'Tabla silver - Constructores de Fórmula 1 conformados';

-- =====================================================
-- TABLA: stg_driver
-- =====================================================
-- Descripción: Pilotos de F1 con datos conformados
-- Origen: BRONZE.raw_drivers
-- Transformaciones: Tipos de datos corregidos, fechas convertidas, nombres estandarizados
-- =====================================================

CREATE OR REPLACE TABLE stg_driver (
    -- Clave primaria
    driver_id NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'ID único autogenerado del piloto',
    
    -- Campos de negocio conformados
    driver_ref VARCHAR(500) NOT NULL COMMENT 'Referencia única del piloto (limpia)',
    driver_number VARCHAR(50) COMMENT 'Número permanente del piloto',
    driver_code VARCHAR(10) COMMENT 'Código de 3 letras del piloto (ej: HAM, VER)',
    first_name VARCHAR(500) NOT NULL COMMENT 'Nombre del piloto',
    last_name VARCHAR(500) NOT NULL COMMENT 'Apellido del piloto',
    full_name VARCHAR(1000) COMMENT 'Nombre completo del piloto (concatenado)',
    date_of_birth DATE COMMENT 'Fecha de nacimiento del piloto',
    nationality VARCHAR(200) COMMENT 'Nacionalidad del piloto',
    info_url VARCHAR(1000) COMMENT 'URL de información oficial del piloto',
    
    -- Campos calculados
    age_years NUMBER COMMENT 'Edad actual del piloto en años',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'BRONZE.raw_drivers' COMMENT 'Fuente de datos origen',
    
    -- Constraints
    CONSTRAINT uk_driver_ref UNIQUE (driver_ref)
)
COMMENT = 'Tabla silver - Pilotos de Fórmula 1 conformados';

-- =====================================================
-- TABLA: stg_race_result
-- =====================================================
-- Descripción: Resultados de carreras de F1 conformados
-- Origen: BRONZE.raw_resultados
-- Transformaciones: Tipos numéricos corregidos, relaciones establecidas, duplicados eliminados
-- =====================================================

CREATE OR REPLACE TABLE stg_race_result (
    -- Clave primaria
    result_id NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'ID único autogenerado del resultado',
    
    -- Claves foráneas (referencias a otras tablas)
    race_id NUMBER NOT NULL COMMENT 'ID de la carrera',
    driver_id NUMBER COMMENT 'ID del piloto (FK a stg_driver)',
    constructor_id NUMBER COMMENT 'ID del constructor (FK a stg_constructor)',
    
    -- Información de la carrera
    car_number NUMBER COMMENT 'Número del coche en la carrera',
    grid_position NUMBER COMMENT 'Posición en la parrilla de salida',
    finish_position NUMBER COMMENT 'Posición final de llegada',
    finish_position_text VARCHAR(50) COMMENT 'Posición final en texto (incluye "R", "D", "E", "W", "F", "N")',
    position_order NUMBER COMMENT 'Orden de posición para ordenamiento',
    
    -- Resultados de carrera
    points_earned DECIMAL(10,2) COMMENT 'Puntos obtenidos en la carrera',
    laps_completed NUMBER COMMENT 'Número de vueltas completadas',
    race_time_formatted VARCHAR(200) COMMENT 'Tiempo total de carrera (formato: HH:MM:SS.mmm)',
    race_time_milliseconds NUMBER COMMENT 'Tiempo total de carrera en milisegundos',
    
    -- Vuelta rápida
    fastest_lap_number NUMBER COMMENT 'Número de vuelta más rápida',
    fastest_lap_rank NUMBER COMMENT 'Ranking de vuelta más rápida',
    fastest_lap_time VARCHAR(100) COMMENT 'Tiempo de vuelta más rápida (formato: MM:SS.mmm)',
    fastest_lap_speed_kmh DECIMAL(10,3) COMMENT 'Velocidad de vuelta más rápida en Km/h',
    
    -- Estado del resultado
    status_id NUMBER COMMENT 'ID del estado de finalización',
    
    -- Campos adicionales
    race_year NUMBER COMMENT 'Año de la carrera',
    race_round NUMBER COMMENT 'Ronda del campeonato',
    circuit_id VARCHAR(100) COMMENT 'ID del circuito',
    constructor_ref VARCHAR(500) COMMENT 'Referencia del constructor',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'BRONZE.raw_resultados' COMMENT 'Fuente de datos origen'
)
COMMENT = 'Tabla silver - Resultados de carreras de Fórmula 1 conformados';

-- =====================================================
-- VISTA: vw_race_result_enhanced
-- =====================================================
-- Descripción: Vista con resultados enriquecidos con datos de pilotos y constructores
-- =====================================================

CREATE OR REPLACE VIEW vw_race_result_enhanced AS
SELECT 
    rr.result_id,
    rr.race_id,
    rr.race_year,
    rr.race_round,
    rr.circuit_id,
    
    -- Información del piloto
    rr.driver_id,
    d.driver_ref,
    d.driver_code,
    d.full_name AS driver_full_name,
    d.nationality AS driver_nationality,
    
    -- Información del constructor
    rr.constructor_id,
    c.constructor_ref,
    c.constructor_name,
    c.nationality AS constructor_nationality,
    
    -- Resultados
    rr.car_number,
    rr.grid_position,
    rr.finish_position,
    rr.finish_position_text,
    rr.position_order,
    rr.points_earned,
    rr.laps_completed,
    rr.race_time_formatted,
    rr.race_time_milliseconds,
    rr.fastest_lap_number,
    rr.fastest_lap_rank,
    rr.fastest_lap_time,
    rr.fastest_lap_speed_kmh,
    rr.status_id,
    
    -- Auditoría
    rr.created_at,
    rr.updated_at,
    rr._source
FROM 
    stg_race_result rr
    LEFT JOIN stg_driver d ON rr.driver_id = d.driver_id
    LEFT JOIN stg_constructor c ON rr.constructor_id = c.constructor_id
COMMENT = 'Vista enriquecida de resultados de carreras con información de pilotos y constructores';

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices en stg_race_result para mejorar rendimiento de queries
-- CREATE INDEX idx_race_result_race_id ON stg_race_result(race_id);
-- CREATE INDEX idx_race_result_driver_id ON stg_race_result(driver_id);
-- CREATE INDEX idx_race_result_constructor_id ON stg_race_result(constructor_id);
-- CREATE INDEX idx_race_result_year ON stg_race_result(race_year);

-- =====================================================
-- GRANTS (Opcional - descomentar si se necesita)
-- =====================================================

-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.SILVER TO ROLE F1_SILVER_READER;
-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.SILVER TO ROLE F1_GOLD_READER;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA F1_HISTORICO.SILVER TO ROLE F1_SILVER_READER;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA F1_HISTORICO.SILVER TO ROLE F1_GOLD_READER;

-- =====================================================
-- NOTAS DE TRANSFORMACIÓN
-- =====================================================
-- 1. Los datos se cargan desde BRONZE usando INSERT INTO ... SELECT
-- 2. Se aplican conversiones de tipo de datos (VARCHAR -> NUMBER, DATE, etc.)
-- 3. Se eliminan duplicados usando ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)
-- 4. Se estandarizan nombres y referencias
-- 5. Los campos calculados se actualizan en cada carga
-- =====================================================
