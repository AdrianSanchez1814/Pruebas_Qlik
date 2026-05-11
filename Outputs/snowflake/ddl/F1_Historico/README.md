# F1 Histórico - Snowflake Data Warehouse

## 📋 Descripción del Proyecto

Este proyecto implementa un Data Warehouse en Snowflake para el análisis histórico de datos de Fórmula 1, migrando desde QlikView a una arquitectura moderna Medallion (Bronze-Silver-Gold) optimizada para consumo en Power BI.

**Fuente de datos:** QlikView - Formula1 - Historico.xlsx  
**Destino:** Snowflake Database `F1_HISTORICO`  
**Consumidor principal:** Power BI  

---

## 🏗️ Arquitectura

### Capas de Datos (Medallion Architecture)

```
┌─────────────────────────────────────────────────────────────────┐
│                         GOLD LAYER (BI)                         │
│  - Esquema Estrella para Power BI                               │
│  - Dimensiones: dim_driver, dim_constructor, dim_race, dim_date │
│  - Hechos: fact_race_result, fact_championship_standings        │
│  - Vistas: vw_race_analysis, vw_championship_summary            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ ETL Transformations
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       SILVER LAYER (Conformed)                  │
│  - Datos limpios y conformados                                  │
│  - Tipos de datos corregidos                                    │
│  - Duplicados eliminados                                        │
│  - Tablas: stg_constructor, stg_driver, stg_race_result         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Data Ingestion
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       BRONZE LAYER (Raw)                        │
│  - Datos crudos sin transformar                                 │
│  - Espejo de la fuente (QlikView/Excel)                         │
│  - Tablas: raw_constructor, raw_drivers, raw_resultados         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Estructura de Archivos

```
Outputs/snowflake/ddl/F1_Historico/
│
├── database.sql                          # Creación de database y schemas
│
├── bronze/
│   └── F1_Historico_raw.sql             # DDL capa Bronze (raw tables)
│
├── silver/
│   └── F1_Historico_staging.sql         # DDL capa Silver (staging tables)
│
├── gold/
│   └── F1_Historico_marts.sql           # DDL capa Gold (star schema)
│
├── docs/
│   ├── decisions/
│   │   └── ADR_F1_Historico_model.md    # Architecture Decision Record
│   └── README.md                         # Este archivo
│
└── scripts/ (opcional - para ETL)
    ├── load_bronze.sql
    ├── load_silver.sql
    └── load_gold.sql
```

---

## 🚀 Guía de Ejecución

### **Prerequisitos**

1. ✅ Cuenta activa de Snowflake
2. ✅ Rol con permisos de CREATE DATABASE, CREATE SCHEMA, CREATE TABLE
3. ✅ Cliente Snowflake (SnowSQL, Snowflake Web UI, o DBeaver)
4. ✅ Archivos de datos: Formula1 - Historico.xlsx o archivos QVD exportados

### **Orden de Ejecución**

Ejecutar los scripts en el siguiente orden estricto:

#### **Paso 1: Crear Base de Datos y Schemas**

```sql
-- Archivo: database.sql
-- Crea: F1_HISTORICO database y schemas BRONZE, SILVER, GOLD
```

**Comando:**
```bash
snowsql -f database.sql
```

**Verificación:**
```sql
SHOW DATABASES LIKE 'F1_HISTORICO';
SHOW SCHEMAS IN DATABASE F1_HISTORICO;
```

**Resultado esperado:**
```
F1_HISTORICO.BRONZE
F1_HISTORICO.SILVER
F1_HISTORICO.GOLD
```

---

#### **Paso 2: Crear Tablas Bronze (Raw)**

```sql
-- Archivo: bronze/F1_Historico_raw.sql
-- Crea: raw_constructor, raw_drivers, raw_resultados
```

**Comando:**
```bash
snowsql -f bronze/F1_Historico_raw.sql
```

**Verificación:**
```sql
USE DATABASE F1_HISTORICO;
USE SCHEMA BRONZE;
SHOW TABLES;
```

**Resultado esperado:**
```
raw_constructor
raw_drivers
raw_resultados
```

---

#### **Paso 3: Cargar Datos en Bronze**

**Opción A: Desde archivo local (CSV/Excel)**

```sql
-- Crear Stage interno
CREATE OR REPLACE STAGE F1_HISTORICO.BRONZE.f1_stage;

-- Subir archivos
PUT file:///path/to/constructor.csv @f1_stage AUTO_COMPRESS=TRUE;
PUT file:///path/to/drivers.csv @f1_stage AUTO_COMPRESS=TRUE;
PUT file:///path/to/resultados.csv @f1_stage AUTO_COMPRESS=TRUE;

-- Cargar datos
COPY INTO F1_HISTORICO.BRONZE.raw_constructor
FROM @f1_stage/constructor.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO F1_HISTORICO.BRONZE.raw_drivers
FROM @f1_stage/drivers.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

COPY INTO F1_HISTORICO.BRONZE.raw_resultados
FROM @f1_stage/resultados.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
```

**Opción B: Desde S3/Azure Blob (recomendado para producción)**

```sql
-- Crear External Stage
CREATE OR REPLACE STAGE f1_external_stage
  URL = 's3://mi-bucket/f1-data/'
  CREDENTIALS = (AWS_KEY_ID='xxx' AWS_SECRET_KEY='yyy');

-- Cargar datos
COPY INTO F1_HISTORICO.BRONZE.raw_constructor
FROM @f1_external_stage/constructor/
FILE_FORMAT = (TYPE = CSV);
```

**Verificación:**
```sql
SELECT COUNT(*) FROM F1_HISTORICO.BRONZE.raw_constructor;  -- Esperado: 211
SELECT COUNT(*) FROM F1_HISTORICO.BRONZE.raw_resultados;   -- Esperado: 26,080
```

---

#### **Paso 4: Crear Tablas Silver (Staging)**

```sql
-- Archivo: silver/F1_Historico_staging.sql
-- Crea: stg_constructor, stg_driver, stg_race_result, vistas
```

**Comando:**
```bash
snowsql -f silver/F1_Historico_staging.sql
```

**Verificación:**
```sql
USE SCHEMA SILVER;
SHOW TABLES;
SHOW VIEWS;
```

---

#### **Paso 5: Cargar Datos en Silver (Transformación)**

**Script de transformación (ejemplo):**

```sql
-- Cargar stg_constructor desde Bronze
INSERT INTO F1_HISTORICO.SILVER.stg_constructor
    (constructor_ref, constructor_name, nationality, info_url, _source)
SELECT DISTINCT
    TRIM(UPPER(constructorRef)) AS constructor_ref,
    TRIM(name) AS constructor_name,
    TRIM(nationality) AS nationality,
    TRIM(url) AS info_url,
    'BRONZE.raw_constructor' AS _source
FROM F1_HISTORICO.BRONZE.raw_constructor
WHERE constructorRef IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY TRIM(UPPER(constructorRef)) ORDER BY created_at DESC) = 1;

-- Cargar stg_driver desde Bronze
INSERT INTO F1_HISTORICO.SILVER.stg_driver
    (driver_ref, driver_number, driver_code, first_name, last_name, 
     full_name, date_of_birth, nationality, info_url, age_years, _source)
SELECT DISTINCT
    TRIM(UPPER(driverRef)) AS driver_ref,
    TRIM(number) AS driver_number,
    TRIM(UPPER(code)) AS driver_code,
    TRIM(forename) AS first_name,
    TRIM(surname) AS last_name,
    CONCAT(TRIM(forename), ' ', TRIM(surname)) AS full_name,
    TRY_TO_DATE(dob) AS date_of_birth,
    TRIM(nationality) AS nationality,
    TRIM(url) AS info_url,
    DATEDIFF(YEAR, TRY_TO_DATE(dob), CURRENT_DATE()) AS age_years,
    'BRONZE.raw_drivers' AS _source
FROM F1_HISTORICO.BRONZE.raw_drivers
WHERE driverRef IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY TRIM(UPPER(driverRef)) ORDER BY created_at DESC) = 1;

-- Cargar stg_race_result desde Bronze (simplificado)
INSERT INTO F1_HISTORICO.SILVER.stg_race_result
    (race_id, driver_id, constructor_id, car_number, grid_position, 
     finish_position, finish_position_text, position_order, points_earned, 
     laps_completed, race_time_formatted, race_time_milliseconds, 
     fastest_lap_number, fastest_lap_rank, fastest_lap_time, fastest_lap_speed_kmh,
     status_id, race_year, race_round, circuit_id, constructor_ref, _source)
SELECT 
    TRY_CAST(raceId AS NUMBER) AS race_id,
    TRY_CAST(driverId AS NUMBER) AS driver_id,
    TRY_CAST(constructorId AS NUMBER) AS constructor_id,
    TRY_CAST(number AS NUMBER) AS car_number,
    TRY_CAST(grid AS NUMBER) AS grid_position,
    TRY_CAST(position AS NUMBER) AS finish_position,
    positionText AS finish_position_text,
    TRY_CAST(positionOrder AS NUMBER) AS position_order,
    TRY_CAST(points AS DECIMAL(10,2)) AS points_earned,
    TRY_CAST(laps AS NUMBER) AS laps_completed,
    time AS race_time_formatted,
    TRY_CAST(milliseconds AS NUMBER) AS race_time_milliseconds,
    TRY_CAST(fastestLap AS NUMBER) AS fastest_lap_number,
    TRY_CAST(rank AS NUMBER) AS fastest_lap_rank,
    fastestLapTime AS fastest_lap_time,
    TRY_CAST(fastestLapSpeed AS DECIMAL(10,3)) AS fastest_lap_speed_kmh,
    TRY_CAST(statusId AS NUMBER) AS status_id,
    TRY_CAST(year AS NUMBER) AS race_year,
    TRY_CAST(round AS NUMBER) AS race_round,
    circuitId,
    constructorRef AS constructor_ref,
    'BRONZE.raw_resultados' AS _source
FROM F1_HISTORICO.BRONZE.raw_resultados
WHERE resultId IS NOT NULL;
```

**Verificación:**
```sql
SELECT COUNT(*) FROM F1_HISTORICO.SILVER.stg_constructor;  -- Esperado: ~211
SELECT COUNT(*) FROM F1_HISTORICO.SILVER.stg_race_result;  -- Esperado: ~26,080
```

---

#### **Paso 6: Crear Tablas Gold (Star Schema)**

```sql
-- Archivo: gold/F1_Historico_marts.sql
-- Crea: dim_*, fact_*, vistas analíticas
```

**Comando:**
```bash
snowsql -f gold/F1_Historico_marts.sql
```

**Verificación:**
```sql
USE SCHEMA GOLD;
SHOW TABLES;
SHOW VIEWS;
```

---

#### **Paso 7: Cargar Datos en Gold (Modelado Dimensional)**

**Script de carga (ejemplo):**

```sql
-- Cargar dim_driver
INSERT INTO F1_HISTORICO.GOLD.dim_driver
    (driver_ref, driver_code, driver_number, first_name, last_name, 
     full_name, nationality, date_of_birth, age_years, info_url, 
     driver_generation, _source)
SELECT 
    driver_ref,
    driver_code,
    driver_number,
    first_name,
    last_name,
    full_name,
    nationality,
    date_of_birth,
    age_years,
    info_url,
    CASE 
        WHEN age_years > 60 THEN 'Leyenda'
        WHEN age_years > 40 THEN 'Veterano'
        WHEN age_years > 25 THEN 'Actual'
        ELSE 'Novato'
    END AS driver_generation,
    'SILVER.stg_driver' AS _source
FROM F1_HISTORICO.SILVER.stg_driver;

-- Cargar dim_constructor
INSERT INTO F1_HISTORICO.GOLD.dim_constructor
    (constructor_ref, constructor_name, nationality, info_url, 
     constructor_status, constructor_era, _source)
SELECT 
    constructor_ref,
    constructor_name,
    nationality,
    info_url,
    'Histórico' AS constructor_status,  -- Determinar lógica según año activo
    CASE 
        WHEN constructor_name IN ('Ferrari', 'McLaren', 'Mercedes', 'Red Bull') THEN 'Moderna'
        ELSE 'Clásica'
    END AS constructor_era,
    'SILVER.stg_constructor' AS _source
FROM F1_HISTORICO.SILVER.stg_constructor;

-- Generar dim_date (calendario completo)
-- Ver script completo en documentación de Snowflake Date Dimension

-- Cargar dim_race
INSERT INTO F1_HISTORICO.GOLD.dim_race
    (race_id, race_year, race_round, circuit_id, race_season, _source)
SELECT DISTINCT
    race_id,
    race_year,
    race_round,
    circuit_id,
    CAST(race_year AS VARCHAR) AS race_season,
    'SILVER.stg_race_result' AS _source
FROM F1_HISTORICO.SILVER.stg_race_result;

-- Cargar fact_race_result
INSERT INTO F1_HISTORICO.GOLD.fact_race_result
    (race_key, driver_key, constructor_key, date_key, result_id,
     points_earned, laps_completed, race_time_milliseconds,
     grid_position, finish_position, position_order, car_number,
     fastest_lap_number, fastest_lap_rank, fastest_lap_speed_kmh,
     did_finish, scored_points, had_fastest_lap, started_from_pole, 
     finished_on_podium, won_race, finish_position_text, 
     race_time_formatted, fastest_lap_time, status_id, _source)
SELECT 
    dr.race_key,
    dd.driver_key,
    dc.constructor_key,
    NULL AS date_key,  -- Join con dim_date por fecha de carrera
    rr.result_id,
    rr.points_earned,
    rr.laps_completed,
    rr.race_time_milliseconds,
    rr.grid_position,
    rr.finish_position,
    rr.position_order,
    rr.car_number,
    rr.fastest_lap_number,
    rr.fastest_lap_rank,
    rr.fastest_lap_speed_kmh,
    (rr.status_id = 1) AS did_finish,  -- Ajustar lógica según status
    (rr.points_earned > 0) AS scored_points,
    (rr.fastest_lap_rank = 1) AS had_fastest_lap,
    (rr.grid_position = 1) AS started_from_pole,
    (rr.finish_position <= 3) AS finished_on_podium,
    (rr.finish_position = 1) AS won_race,
    rr.finish_position_text,
    rr.race_time_formatted,
    rr.fastest_lap_time,
    rr.status_id,
    'SILVER.stg_race_result' AS _source
FROM 
    F1_HISTORICO.SILVER.stg_race_result rr
    INNER JOIN F1_HISTORICO.GOLD.dim_race dr ON rr.race_id = dr.race_id
    INNER JOIN F1_HISTORICO.GOLD.dim_driver dd ON rr.driver_id = dd.driver_ref  -- Ajustar join
    INNER JOIN F1_HISTORICO.GOLD.dim_constructor dc ON rr.constructor_ref = dc.constructor_ref;
```

**Verificación:**
```sql
-- Verificar carga de dimensiones
SELECT COUNT(*) FROM F1_HISTORICO.GOLD.dim_driver;        -- ~850
SELECT COUNT(*) FROM F1_HISTORICO.GOLD.dim_constructor;   -- ~211
SELECT COUNT(*) FROM F1_HISTORICO.GOLD.dim_race;          -- ~X carreras

-- Verificar tabla de hechos
SELECT COUNT(*) FROM F1_HISTORICO.GOLD.fact_race_result;  -- ~26,080

-- Probar vista analítica
SELECT * FROM F1_HISTORICO.GOLD.vw_race_analysis LIMIT 10;
```

---

## 🔍 Validaciones de Calidad de Datos

Ejecutar después de cada carga:

```sql
-- 1. Verificar duplicados en dimensiones
SELECT driver_ref, COUNT(*) 
FROM F1_HISTORICO.GOLD.dim_driver 
GROUP BY driver_ref 
HAVING COUNT(*) > 1;

-- 2. Verificar NULLs en campos críticos
SELECT COUNT(*) 
FROM F1_HISTORICO.GOLD.fact_race_result 
WHERE race_key IS NULL OR driver_key IS NULL;

-- 3. Verificar rangos de fechas
SELECT MIN(race_year), MAX(race_year) 
FROM F1_HISTORICO.SILVER.stg_race_result;

-- 4. Verificar integridad referencial
SELECT COUNT(*) 
FROM F1_HISTORICO.GOLD.fact_race_result f
LEFT JOIN F1_HISTORICO.GOLD.dim_driver d ON f.driver_key = d.driver_key
WHERE d.driver_key IS NULL;
```

---

## 📊 Consumo en Power BI

### **Conexión**

1. Abrir Power BI Desktop
2. Get Data → Snowflake
3. **Server:** `<tu-account>.snowflakecomputing.com`
4. **Database:** `F1_HISTORICO`
5. **Warehouse:** `<tu-warehouse>`
6. **Schema:** `GOLD`

### **Tablas a Importar (Import Mode)**

- ✅ `dim_driver`
- ✅ `dim_constructor`
- ✅ `dim_race`
- ✅ `dim_date`
- ✅ `fact_race_result`
- ✅ `vw_race_analysis` (opcional, para simplificar)

### **Relaciones Recomendadas**

```
dim_driver (driver_key) ---< fact_race_result (driver_key)
dim_constructor (constructor_key) ---< fact_race_result (constructor_key)
dim_race (race_key) ---< fact_race_result (race_key)
dim_date (date_key) ---< fact_race_result (date_key)
```

**Cardinalidad:** Todas las relaciones son 1:N (One-to-Many)

---

## 🛠️ Mantenimiento

### **Carga Incremental (Recomendado)**

```sql
-- Crear tabla de control de carga
CREATE TABLE F1_HISTORICO.BRONZE.etl_control (
    table_name STRING,
    last_loaded_id NUMBER,
    last_loaded_timestamp TIMESTAMP_NTZ,
    load_status STRING
);

-- Script de carga incremental
MERGE INTO F1_HISTORICO.SILVER.stg_race_result AS target
USING (
    SELECT * FROM F1_HISTORICO.BRONZE.raw_resultados 
    WHERE resultId > (SELECT MAX(last_loaded_id) FROM etl_control WHERE table_name = 'raw_resultados')
) AS source
ON target.result_id = source.resultId
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT ...;
```

### **Limpieza de Datos Antiguos (Bronze)**

```sql
-- Eliminar datos Bronze más antiguos de 90 días
DELETE FROM F1_HISTORICO.BRONZE.raw_resultados
WHERE created_at < DATEADD(DAY, -90, CURRENT_TIMESTAMP());
```

---

## 📚 Documentación Adicional

- **ADR (Architecture Decision Record):** `docs/decisions/ADR_F1_Historico_model.md`
- **Snowflake Docs:** https://docs.snowflake.com/
- **Power BI + Snowflake:** https://learn.microsoft.com/en-us/power-bi/connect-data/service-connect-snowflake

---

## 🆘 Troubleshooting

### Problema: "Object does not exist"
**Solución:** Verificar que estés usando el database y schema correcto:
```sql
USE DATABASE F1_HISTORICO;
USE SCHEMA BRONZE;
```

### Problema: "INSERT has more expressions than target columns"
**Solución:** Verificar que el número de columnas en INSERT coincida con SELECT.

### Problema: "Numeric value 'X' is not recognized"
**Solución:** Usar `TRY_CAST()` en lugar de `CAST()` en transformaciones Silver.

---

## 👥 Contacto

**Equipo de Arquitectura de Datos - Aqualia**  
Fecha de última actualización: 2026-05-06
