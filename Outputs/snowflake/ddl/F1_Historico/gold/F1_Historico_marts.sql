-- =====================================================
-- GOLD LAYER - F1 HISTORICO PROJECT
-- =====================================================
-- Proyecto: F1 Histórico
-- Schema: GOLD (Star Schema para consumo BI)
-- Fuente: SILVER layer
-- Descripción: Esquema estrella optimizado para Power BI con tablas de hechos y dimensiones
-- =====================================================

USE DATABASE F1_HISTORICO;
USE SCHEMA GOLD;

-- =====================================================
-- DIMENSIÓN: dim_driver
-- =====================================================
-- Descripción: Dimensión de pilotos con atributos descriptivos
-- Origen: SILVER.stg_driver
-- Tipo: Dimensión SCD Tipo 1 (sobrescritura)
-- =====================================================

CREATE OR REPLACE TABLE dim_driver (
    -- Clave subrogada
    driver_key NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'Clave subrogada única del piloto',
    
    -- Clave de negocio
    driver_ref VARCHAR(500) NOT NULL COMMENT 'Referencia de negocio del piloto',
    
    -- Atributos descriptivos
    driver_code VARCHAR(10) COMMENT 'Código de 3 letras del piloto (ej: HAM, VER, ALO)',
    driver_number VARCHAR(50) COMMENT 'Número permanente del piloto',
    first_name VARCHAR(500) NOT NULL COMMENT 'Nombre del piloto',
    last_name VARCHAR(500) NOT NULL COMMENT 'Apellido del piloto',
    full_name VARCHAR(1000) COMMENT 'Nombre completo del piloto',
    nationality VARCHAR(200) COMMENT 'Nacionalidad del piloto',
    date_of_birth DATE COMMENT 'Fecha de nacimiento',
    age_years NUMBER COMMENT 'Edad en años',
    info_url VARCHAR(1000) COMMENT 'URL de información del piloto',
    
    -- Categorización adicional
    driver_generation VARCHAR(50) COMMENT 'Generación del piloto (Leyenda, Veterano, Actual, Novato)',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización',
    _source STRING DEFAULT 'SILVER.stg_driver' COMMENT 'Fuente de datos',
    
    -- Constraints
    CONSTRAINT uk_dim_driver_ref UNIQUE (driver_ref)
)
COMMENT = 'Dimensión de pilotos para análisis BI';

-- =====================================================
-- DIMENSIÓN: dim_constructor
-- =====================================================
-- Descripción: Dimensión de constructores con atributos descriptivos
-- Origen: SILVER.stg_constructor
-- Tipo: Dimensión SCD Tipo 1 (sobrescritura)
-- =====================================================

CREATE OR REPLACE TABLE dim_constructor (
    -- Clave subrogada
    constructor_key NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'Clave subrogada única del constructor',
    
    -- Clave de negocio
    constructor_ref VARCHAR(500) NOT NULL COMMENT 'Referencia de negocio del constructor',
    
    -- Atributos descriptivos
    constructor_name VARCHAR(500) NOT NULL COMMENT 'Nombre del constructor',
    nationality VARCHAR(200) COMMENT 'Nacionalidad del constructor',
    info_url VARCHAR(1000) COMMENT 'URL de información del constructor',
    
    -- Categorización adicional
    constructor_status VARCHAR(50) COMMENT 'Estado del constructor (Activo, Histórico)',
    constructor_era VARCHAR(50) COMMENT 'Era del constructor',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización',
    _source STRING DEFAULT 'SILVER.stg_constructor' COMMENT 'Fuente de datos',
    
    -- Constraints
    CONSTRAINT uk_dim_constructor_ref UNIQUE (constructor_ref)
)
COMMENT = 'Dimensión de constructores para análisis BI';

-- =====================================================
-- DIMENSIÓN: dim_date
-- =====================================================
-- Descripción: Dimensión de fechas (calendario) para análisis temporal
-- Origen: Generada
-- Tipo: Dimensión conformada
-- =====================================================

CREATE OR REPLACE TABLE dim_date (
    -- Clave subrogada
    date_key NUMBER PRIMARY KEY COMMENT 'Clave de fecha en formato YYYYMMDD',
    
    -- Fecha completa
    full_date DATE NOT NULL COMMENT 'Fecha completa',
    
    -- Atributos de día
    day_of_week NUMBER COMMENT 'Día de la semana (1=Domingo, 7=Sábado)',
    day_name VARCHAR(20) COMMENT 'Nombre del día (Lunes, Martes, etc.)',
    day_of_month NUMBER COMMENT 'Día del mes (1-31)',
    day_of_year NUMBER COMMENT 'Día del año (1-366)',
    
    -- Atributos de semana
    week_of_year NUMBER COMMENT 'Semana del año (1-53)',
    iso_week NUMBER COMMENT 'Semana ISO (1-53)',
    
    -- Atributos de mes
    month_number NUMBER COMMENT 'Número del mes (1-12)',
    month_name VARCHAR(20) COMMENT 'Nombre del mes',
    month_short_name VARCHAR(10) COMMENT 'Nombre corto del mes (Ene, Feb, etc.)',
    
    -- Atributos de trimestre
    quarter_number NUMBER COMMENT 'Número del trimestre (1-4)',
    quarter_name VARCHAR(10) COMMENT 'Nombre del trimestre (Q1, Q2, Q3, Q4)',
    
    -- Atributos de año
    year_number NUMBER COMMENT 'Año (YYYY)',
    
    -- Indicadores
    is_weekend BOOLEAN COMMENT 'Indica si es fin de semana',
    is_holiday BOOLEAN COMMENT 'Indica si es día festivo',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    _source STRING DEFAULT 'GENERATED' COMMENT 'Fuente de datos'
)
COMMENT = 'Dimensión de calendario para análisis temporal';

-- =====================================================
-- DIMENSIÓN: dim_race
-- =====================================================
-- Descripción: Dimensión de carreras con información del evento
-- Origen: SILVER.stg_race_result (agregado)
-- Tipo: Dimensión
-- =====================================================

CREATE OR REPLACE TABLE dim_race (
    -- Clave subrogada
    race_key NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'Clave subrogada única de la carrera',
    
    -- Clave de negocio
    race_id NUMBER NOT NULL COMMENT 'ID de negocio de la carrera',
    
    -- Atributos descriptivos
    race_year NUMBER NOT NULL COMMENT 'Año de la carrera',
    race_round NUMBER NOT NULL COMMENT 'Ronda del campeonato',
    circuit_id VARCHAR(100) COMMENT 'ID del circuito',
    circuit_name VARCHAR(500) COMMENT 'Nombre del circuito',
    circuit_country VARCHAR(200) COMMENT 'País del circuito',
    race_date DATE COMMENT 'Fecha de la carrera',
    race_name VARCHAR(500) COMMENT 'Nombre de la carrera (ej: Gran Premio de España)',
    
    -- Categorización
    race_season VARCHAR(50) COMMENT 'Temporada (ej: 2023)',
    is_sprint_race BOOLEAN DEFAULT FALSE COMMENT 'Indica si es carrera sprint',
    
    -- Claves foráneas a dimensiones
    date_key NUMBER COMMENT 'FK a dim_date',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización',
    _source STRING DEFAULT 'SILVER.stg_race_result' COMMENT 'Fuente de datos',
    
    -- Constraints
    CONSTRAINT uk_dim_race_id UNIQUE (race_id)
)
COMMENT = 'Dimensión de carreras para análisis BI';

-- =====================================================
-- TABLA DE HECHOS: fact_race_result
-- =====================================================
-- Descripción: Hechos de resultados de carreras (granularidad: un resultado por piloto por carrera)
-- Origen: SILVER.stg_race_result
-- Tipo: Tabla de hechos transaccional
-- =====================================================

CREATE OR REPLACE TABLE fact_race_result (
    -- Clave subrogada de la tabla de hechos
    fact_race_result_key NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'Clave subrogada única del hecho',
    
    -- Claves foráneas a dimensiones
    race_key NUMBER NOT NULL COMMENT 'FK a dim_race',
    driver_key NUMBER NOT NULL COMMENT 'FK a dim_driver',
    constructor_key NUMBER NOT NULL COMMENT 'FK a dim_constructor',
    date_key NUMBER COMMENT 'FK a dim_date',
    
    -- Claves de negocio (degeneradas)
    result_id NUMBER COMMENT 'ID de negocio del resultado',
    
    -- Métricas aditivas
    points_earned DECIMAL(10,2) COMMENT 'Puntos obtenidos en la carrera',
    laps_completed NUMBER COMMENT 'Número de vueltas completadas',
    race_time_milliseconds NUMBER COMMENT 'Tiempo de carrera en milisegundos',
    
    -- Métricas no aditivas
    grid_position NUMBER COMMENT 'Posición en parrilla de salida',
    finish_position NUMBER COMMENT 'Posición final',
    position_order NUMBER COMMENT 'Orden de posición',
    car_number NUMBER COMMENT 'Número del coche',
    fastest_lap_number NUMBER COMMENT 'Número de vuelta más rápida',
    fastest_lap_rank NUMBER COMMENT 'Ranking de vuelta más rápida',
    fastest_lap_speed_kmh DECIMAL(10,3) COMMENT 'Velocidad de vuelta más rápida',
    
    -- Indicadores (flags)
    did_finish BOOLEAN COMMENT 'Indica si terminó la carrera',
    scored_points BOOLEAN COMMENT 'Indica si obtuvo puntos',
    had_fastest_lap BOOLEAN COMMENT 'Indica si tuvo la vuelta más rápida',
    started_from_pole BOOLEAN COMMENT 'Indica si salió desde la pole position',
    finished_on_podium BOOLEAN COMMENT 'Indica si terminó en el podio (top 3)',
    won_race BOOLEAN COMMENT 'Indica si ganó la carrera',
    
    -- Atributos degenerados
    finish_position_text VARCHAR(50) COMMENT 'Posición final en texto',
    race_time_formatted VARCHAR(200) COMMENT 'Tiempo de carrera formateado',
    fastest_lap_time VARCHAR(100) COMMENT 'Tiempo de vuelta más rápida',
    status_id NUMBER COMMENT 'ID del estado de finalización',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización',
    _source STRING DEFAULT 'SILVER.stg_race_result' COMMENT 'Fuente de datos'
)
CLUSTER BY (date_key, race_key)
COMMENT = 'Tabla de hechos de resultados de carreras para análisis BI';

-- =====================================================
-- TABLA DE HECHOS AGREGADOS: fact_championship_standings
-- =====================================================
-- Descripción: Hechos agregados de clasificación de campeonatos
-- Origen: GOLD.fact_race_result (agregado)
-- Tipo: Tabla de hechos agregada
-- =====================================================

CREATE OR REPLACE TABLE fact_championship_standings (
    -- Clave subrogada
    standings_key NUMBER AUTOINCREMENT PRIMARY KEY COMMENT 'Clave subrogada única',
    
    -- Claves foráneas
    driver_key NUMBER COMMENT 'FK a dim_driver (NULL si es campeonato de constructores)',
    constructor_key NUMBER COMMENT 'FK a dim_constructor (NULL si es campeonato de pilotos)',
    
    -- Dimensión de temporada
    championship_year NUMBER NOT NULL COMMENT 'Año del campeonato',
    championship_type VARCHAR(50) NOT NULL COMMENT 'Tipo de campeonato (Pilotos, Constructores)',
    
    -- Métricas agregadas
    total_points DECIMAL(10,2) COMMENT 'Total de puntos acumulados',
    total_wins NUMBER COMMENT 'Total de victorias',
    total_podiums NUMBER COMMENT 'Total de podios (top 3)',
    total_races NUMBER COMMENT 'Total de carreras participadas',
    total_poles NUMBER COMMENT 'Total de pole positions',
    total_fastest_laps NUMBER COMMENT 'Total de vueltas más rápidas',
    
    -- Ranking
    final_position NUMBER COMMENT 'Posición final en el campeonato',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización',
    _source STRING DEFAULT 'GOLD.fact_race_result' COMMENT 'Fuente de datos'
)
COMMENT = 'Tabla de hechos agregados de clasificaciones de campeonatos';

-- =====================================================
-- VISTA DE ANÁLISIS: vw_race_analysis
-- =====================================================
-- Descripción: Vista analítica con todas las dimensiones y métricas
-- =====================================================

CREATE OR REPLACE VIEW vw_race_analysis AS
SELECT 
    -- Dimensiones
    d.full_date AS race_date,
    d.year_number AS year,
    d.month_name AS month,
    dr.race_name,
    dr.race_round,
    dr.circuit_name,
    dr.circuit_country,
    dd.full_name AS driver_name,
    dd.nationality AS driver_nationality,
    dd.driver_code,
    dc.constructor_name,
    dc.nationality AS constructor_nationality,
    
    -- Métricas
    f.grid_position,
    f.finish_position,
    f.points_earned,
    f.laps_completed,
    f.race_time_formatted,
    f.fastest_lap_time,
    f.fastest_lap_speed_kmh,
    
    -- Indicadores
    f.won_race,
    f.finished_on_podium,
    f.started_from_pole,
    f.scored_points,
    f.did_finish,
    
    -- Métricas calculadas
    (f.grid_position - f.finish_position) AS positions_gained,
    CASE 
        WHEN f.finish_position = 1 THEN 25
        WHEN f.finish_position = 2 THEN 18
        WHEN f.finish_position = 3 THEN 15
        ELSE f.points_earned 
    END AS points_verification
    
FROM 
    fact_race_result f
    INNER JOIN dim_driver dd ON f.driver_key = dd.driver_key
    INNER JOIN dim_constructor dc ON f.constructor_key = dc.constructor_key
    INNER JOIN dim_race dr ON f.race_key = dr.race_key
    LEFT JOIN dim_date d ON f.date_key = d.date_key
COMMENT = 'Vista analítica completa para Power BI';

-- =====================================================
-- VISTA DE ANÁLISIS: vw_championship_summary
-- =====================================================
-- Descripción: Vista de resumen de campeonatos por año
-- =====================================================

CREATE OR REPLACE VIEW vw_championship_summary AS
SELECT 
    championship_year,
    championship_type,
    COALESCE(dd.full_name, dc.constructor_name) AS competitor_name,
    total_points,
    total_wins,
    total_podiums,
    total_races,
    final_position,
    RANK() OVER (PARTITION BY championship_year, championship_type ORDER BY total_points DESC) AS points_rank
FROM 
    fact_championship_standings fcs
    LEFT JOIN dim_driver dd ON fcs.driver_key = dd.driver_key
    LEFT JOIN dim_constructor dc ON fcs.constructor_key = dc.constructor_key
COMMENT = 'Vista de resumen de campeonatos por año';

-- =====================================================
-- ÍNDICES Y CLUSTERING
-- =====================================================

-- El clustering ya está definido en fact_race_result
-- Clustering adicional si es necesario:
-- ALTER TABLE fact_race_result CLUSTER BY (date_key, race_key);

-- =====================================================
-- GRANTS (Opcional - descomentar si se necesita)
-- =====================================================

-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.GOLD TO ROLE F1_GOLD_READER;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA F1_HISTORICO.GOLD TO ROLE F1_GOLD_READER;

-- =====================================================
-- NOTAS DE IMPLEMENTACIÓN
-- =====================================================
-- 1. Este esquema estrella está optimizado para Power BI
-- 2. Las dimensiones son SCD Tipo 1 (sobrescritura simple)
-- 3. La tabla de hechos principal es fact_race_result
-- 4. fact_championship_standings es una tabla de hechos agregada
-- 5. Las vistas proporcionan análisis pre-calculados
-- 6. El clustering por date_key y race_key optimiza queries por fecha
-- 7. Las claves subrogadas facilitan la gestión de cambios
-- 8. Los indicadores booleanos simplifican filtros en Power BI
-- =====================================================
