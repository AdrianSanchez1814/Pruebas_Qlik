-- =====================================================
-- BRONZE LAYER - F1 HISTORICO PROJECT
-- =====================================================
-- Proyecto: F1 Histórico
-- Schema: BRONZE (Datos crudos)
-- Fuente: QlikView - Formula1 - Historico.xlsx
-- Descripción: Tablas espejo de la fuente sin transformaciones
-- =====================================================

USE DATABASE F1_HISTORICO;
USE SCHEMA BRONZE;

-- =====================================================
-- TABLA: raw_constructor
-- =====================================================
-- Descripción: Datos crudos de constructores de F1
-- Fuente: Formula1 - Historico.xlsx (hoja: constructor)
-- Registros: 211 filas, 4 campos
-- =====================================================

CREATE OR REPLACE TABLE raw_constructor (
    -- Campos de negocio (crudos, como vienen de la fuente)
    constructorRef VARCHAR(500) COMMENT 'Referencia única del constructor',
    name VARCHAR(500) COMMENT 'Nombre del constructor',
    nationality VARCHAR(500) COMMENT 'Nacionalidad del constructor',
    url VARCHAR(1000) COMMENT 'URL de información del constructor',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'QlikView_F1_Historico.xlsx' COMMENT 'Fuente de datos origen'
)
COMMENT = 'Tabla bronze - Datos crudos de constructores de Fórmula 1';

-- =====================================================
-- TABLA: raw_resultados
-- =====================================================
-- Descripción: Datos crudos de resultados de carreras F1
-- Fuente: Formula1 - Historico.xlsx (hoja: results)
-- Registros: 26,080 filas, 24 campos
-- =====================================================

CREATE OR REPLACE TABLE raw_resultados (
    -- Identificadores
    resultId VARCHAR(100) COMMENT 'ID único del resultado',
    raceId VARCHAR(100) COMMENT 'ID de la carrera',
    driverId VARCHAR(100) COMMENT 'ID del piloto',
    constructorId VARCHAR(100) COMMENT 'ID del constructor',
    
    -- Información de la carrera
    number VARCHAR(50) COMMENT 'Número del coche',
    grid VARCHAR(50) COMMENT 'Posición en la parrilla de salida',
    position VARCHAR(50) COMMENT 'Posición final',
    positionText VARCHAR(50) COMMENT 'Posición final en texto',
    positionOrder VARCHAR(50) COMMENT 'Orden de posición',
    
    -- Resultados
    points VARCHAR(50) COMMENT 'Puntos obtenidos',
    laps VARCHAR(50) COMMENT 'Vueltas completadas',
    time VARCHAR(200) COMMENT 'Tiempo total de carrera',
    milliseconds VARCHAR(100) COMMENT 'Tiempo en milisegundos',
    fastestLap VARCHAR(50) COMMENT 'Vuelta más rápida',
    rank VARCHAR(50) COMMENT 'Ranking',
    fastestLapTime VARCHAR(100) COMMENT 'Tiempo de vuelta más rápida',
    fastestLapSpeed VARCHAR(100) COMMENT 'Velocidad de vuelta más rápida',
    
    -- Estado
    statusId VARCHAR(50) COMMENT 'ID del estado',
    
    -- Campos adicionales (pueden venir como VARCHAR crudo)
    year VARCHAR(50) COMMENT 'Año de la carrera',
    round VARCHAR(50) COMMENT 'Ronda del campeonato',
    circuitId VARCHAR(100) COMMENT 'ID del circuito',
    constructorRef VARCHAR(500) COMMENT 'Referencia del constructor',
    campo VARCHAR(50) COMMENT 'Campo auxiliar de set analysis',
    
    -- Campos adicionales que pueden existir
    additional_data VARIANT COMMENT 'Datos adicionales en formato JSON',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'QlikView_F1_Historico.xlsx' COMMENT 'Fuente de datos origen'
)
COMMENT = 'Tabla bronze - Datos crudos de resultados de carreras de Fórmula 1';

-- =====================================================
-- TABLA: raw_drivers (estructura inferida)
-- =====================================================
-- Descripción: Datos crudos de pilotos de F1
-- Fuente: Formula1 - Historico.xlsx (hoja: drivers)
-- Nota: Estructura inferida basada en modelo estándar F1
-- =====================================================

CREATE OR REPLACE TABLE raw_drivers (
    -- Campos de negocio (crudos)
    driverId VARCHAR(100) COMMENT 'ID único del piloto',
    driverRef VARCHAR(500) COMMENT 'Referencia única del piloto',
    number VARCHAR(50) COMMENT 'Número del piloto',
    code VARCHAR(10) COMMENT 'Código de 3 letras del piloto',
    forename VARCHAR(500) COMMENT 'Nombre del piloto',
    surname VARCHAR(500) COMMENT 'Apellido del piloto',
    dob VARCHAR(50) COMMENT 'Fecha de nacimiento',
    nationality VARCHAR(500) COMMENT 'Nacionalidad del piloto',
    url VARCHAR(1000) COMMENT 'URL de información del piloto',
    
    -- Campos de auditoría
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de creación del registro',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Fecha de última actualización del registro',
    _source STRING DEFAULT 'QlikView_F1_Historico.xlsx' COMMENT 'Fuente de datos origen'
)
COMMENT = 'Tabla bronze - Datos crudos de pilotos de Fórmula 1';

-- =====================================================
-- ÍNDICES Y OPTIMIZACIÓN
-- =====================================================

-- No se crean índices en Bronze ya que es capa de staging crudo
-- Los datos se cargan tal cual vienen de la fuente

-- =====================================================
-- GRANTS (Opcional - descomentar si se necesita)
-- =====================================================

-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.BRONZE TO ROLE F1_BRONZE_READER;
-- GRANT SELECT ON ALL TABLES IN SCHEMA F1_HISTORICO.BRONZE TO ROLE F1_SILVER_READER;

-- =====================================================
-- NOTAS DE CARGA
-- =====================================================
-- 1. Los datos deben cargarse usando COPY INTO desde archivos QVD o Excel
-- 2. Todos los campos están como VARCHAR para aceptar cualquier dato crudo
-- 3. Los campos de auditoría se actualizan automáticamente
-- 4. La columna _source identifica el origen de los datos
-- =====================================================
