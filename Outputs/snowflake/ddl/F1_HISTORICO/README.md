# F1 Histórico - Snowflake Data Model

**Proyecto:** Aqualia - Migración QlikView a Snowflake + Power BI  
**Aplicación:** F1 Histórico  
**Versión:** 1.0  
**Fecha:** 2026-05-07  

---

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Arquitectura](#arquitectura)
3. [Estructura de Archivos](#estructura-de-archivos)
4. [Modelo de Datos](#modelo-de-datos)
5. [Guía de Despliegue](#guía-de-despliegue)
6. [Linaje de Datos](#linaje-de-datos)
7. [Mantenimiento](#mantenimiento)
8. [Referencias](#referencias)

---

## 📖 Descripción General

Este proyecto contiene el modelo de datos completo en Snowflake para la aplicación "F1 Histórico", que migra desde QlikView a una arquitectura moderna basada en:
- **Almacenamiento:** Snowflake Data Warehouse
- **Visualización:** Microsoft Power BI
- **Arquitectura:** Medallion (Bronze-Silver-Gold)

### Fuente de Datos
- **Origen:** Excel - Formula1 - Historico.xlsx
- **Hojas:** constructor, results, drivers
- **Volumen:** ~27,000 registros históricos de Fórmula 1

### Alcance Funcional
- Gestión de pilotos y constructores
- Resultados históricos de carreras
- Análisis de campeonatos por temporada
- Métricas de rendimiento (victorias, podios, puntos)
- Análisis temporal y tendencias

---

## 🏗️ Arquitectura

### Arquitectura Medallion de 3 Capas

```
┌─────────────────────────────────────────────────────────────────┐
│                        GOLD LAYER                                │
│              (Business-Ready Data Marts)                         │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │   Dimensiones    │  │  Hechos Base     │  │Hechos Agregados│ │
│  │  - Driver        │  │  - Race Results  │  │- Driver Season │ │
│  │  - Constructor   │  └──────────────────┘  │- Const. Season │ │
│  │  - Race          │                        └────────────────┘ │
│  │  - Date          │                                            │
│  │  - Driver/Const. │                                            │
│  └──────────────────┘                                            │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Transformación + Modelado
                              │
┌─────────────────────────────────────────────────────────────────┐
│                       SILVER LAYER                               │
│              (Cleaned & Conformed Data)                          │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │  stg_constructor │  │  stg_drivers     │  │ stg_races     │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│  ┌──────────────────┐  ┌──────────────────────────────────────┐ │
│  │stg_race_results  │  │  int_driver_constructor              │ │
│  └──────────────────┘  └──────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Limpieza + Tipado + Deduplicación
                              │
┌─────────────────────────────────────────────────────────────────┐
│                       BRONZE LAYER                               │
│                   (Raw Data Mirror)                              │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │  raw_constructor │  │  raw_drivers     │  │raw_resultados │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Ingesta
                              │
                  ┌───────────────────────┐
                  │  Formula1 - Historico │
                  │     Excel File        │
                  └───────────────────────┘
```

---

## 📁 Estructura de Archivos

```
Outputs/snowflake/ddl/F1_HISTORICO/
│
├── database.sql                          # Creación de DB y schemas
│
├── bronze/
│   └── F1_HISTORICO_raw.sql             # Tablas raw (3 tablas)
│
├── silver/
│   └── F1_HISTORICO_staging.sql         # Tablas staging (5 tablas)
│
├── gold/
│   └── F1_HISTORICO_marts.sql           # Data marts (5 dims + 3 facts)
│
├── docs/
│   └── decisions/
│       └── ADR_F1_HISTORICO_model.md    # Architecture Decision Record
│
└── README.md                            # Este archivo
```

---

## 📊 Modelo de Datos

### Bronze Layer - Tablas Raw

| Tabla            | Descripción                          | Registros | Campos |
|------------------|--------------------------------------|-----------|--------|
| raw_constructor  | Constructores de F1                  | 211       | 4      |
| raw_drivers      | Pilotos de F1                        | 857       | 8      |
| raw_resultados   | Resultados de carreras               | 26,080    | 18-24  |

### Silver Layer - Tablas Staging

| Tabla                    | Descripción                              | Tipo        |
|--------------------------|------------------------------------------|-------------|
| stg_constructor          | Constructores limpios                    | Dimensión   |
| stg_drivers              | Pilotos limpios                          | Dimensión   |
| stg_races                | Carreras (extraídas de resultados)       | Dimensión   |
| stg_race_results         | Resultados limpios de carreras           | Fact        |
| int_driver_constructor   | Relación piloto-constructor-carrera      | Intermedia  |

### Gold Layer - Data Marts

#### Dimensiones (5)

| Dimensión                    | Descripción                              | Clave         |
|------------------------------|------------------------------------------|---------------|
| mart_dim_driver              | Dimensión de pilotos                     | driver_key    |
| mart_dim_constructor         | Dimensión de constructores               | constructor_key|
| mart_dim_race                | Dimensión de carreras                    | race_key      |
| mart_dim_date                | Dimensión de fechas (conformada)         | date_key      |
| mart_dim_driver_constructor  | Dimensión puente (many-to-many)          | driver_constructor_key |

#### Hechos (3)

| Hecho                               | Granularidad           | Tipo         |
|-------------------------------------|------------------------|--------------|
| mart_fact_race_results              | Piloto + Carrera       | Transaccional|
| mart_fact_driver_season_summary     | Piloto + Temporada     | Agregada     |
| mart_fact_constructor_season_summary| Constructor + Temporada| Agregada     |

### Modelo Estrella (Conceptual)

```
                    ┌─────────────────┐
                    │   dim_date      │
                    └────────┬────────┘
                             │
                             │
       ┌─────────────────────┼─────────────────────┐
       │                     │                     │
       │                     ▼                     │
┌──────▼──────┐    ┌──────────────────┐    ┌──────▼──────┐
│ dim_driver  │◄───┤ FACT_RACE_       │───►│dim_constructor
└─────────────┘    │    RESULTS       │    └─────────────┘
                   │  (Grain: Driver  │
                   │   + Race)        │
                   └────────┬─────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │    dim_race     │
                   └─────────────────┘
```

---

## 🚀 Guía de Despliegue

### Prerequisitos

1. Cuenta de Snowflake activa
2. Rol con permisos `CREATE DATABASE`, `CREATE SCHEMA`, `CREATE TABLE`
3. Warehouse activo
4. Cliente Snowflake (SnowSQL, Web UI, o IDE con conector)

### Paso 1: Crear Database y Schemas

```sql
-- Conectar a Snowflake
USE ROLE SYSADMIN;  -- O el rol apropiado
USE WAREHOUSE <YOUR_WAREHOUSE>;

-- Ejecutar script de database
@Outputs/snowflake/ddl/F1_HISTORICO/database.sql
```

### Paso 2: Crear Tablas Bronze

```sql
-- Ejecutar DDL de bronze layer
@Outputs/snowflake/ddl/F1_HISTORICO/bronze/F1_HISTORICO_raw.sql
```

### Paso 3: Crear Tablas Silver

```sql
-- Ejecutar DDL de silver layer
@Outputs/snowflake/ddl/F1_HISTORICO/silver/F1_HISTORICO_staging.sql
```

### Paso 4: Crear Tablas Gold

```sql
-- Ejecutar DDL de gold layer
@Outputs/snowflake/ddl/F1_HISTORICO/gold/F1_HISTORICO_marts.sql
```

### Paso 5: Verificar Despliegue

```sql
-- Verificar objetos creados
USE DATABASE F1_HISTORICO;

-- Listar tablas bronze
SHOW TABLES IN SCHEMA BRONZE;

-- Listar tablas silver
SHOW TABLES IN SCHEMA SILVER;

-- Listar tablas gold
SHOW TABLES IN SCHEMA GOLD;
```

### Orden de Ejecución (Resumen)

```bash
# Si usas SnowSQL desde línea de comandos
snowsql -f database.sql
snowsql -f bronze/F1_HISTORICO_raw.sql
snowsql -f silver/F1_HISTORICO_staging.sql
snowsql -f gold/F1_HISTORICO_marts.sql
```

---

## 🔄 Linaje de Datos

### Flujo de Datos Completo

```
Excel Source
    │
    ├─► raw_constructor ─► stg_constructor ─► mart_dim_constructor
    │                                                    │
    ├─► raw_drivers ────► stg_drivers ────► mart_dim_driver
    │                                                    │
    └─► raw_resultados ─► stg_race_results ─┬─► mart_fact_race_results
                              │              │            │
                              └─► stg_races ─┴─► mart_dim_race
                                                          │
                              ┌─────────────────┬─────────┴──────────┐
                              │                 │                    │
                         mart_dim_date   mart_fact_driver_  mart_fact_constructor_
                                         season_summary     season_summary
```

### Transformaciones por Capa

#### Bronze → Silver
- ✅ Conversión de tipos de datos (STRING → NUMBER, DATE, DECIMAL)
- ✅ Limpieza de claves primarias y foráneas
- ✅ Estandarización de nombres de campos
- ✅ Eliminación de duplicados
- ✅ Manejo de valores nulos
- ✅ Generación de claves surrogates

#### Silver → Gold
- ✅ Modelado dimensional (star schema)
- ✅ Creación de dimensiones conformadas
- ✅ Generación de métricas calculadas
- ✅ Pre-agregaciones (tablas de resumen)
- ✅ Creación de indicadores (flags)
- ✅ Aplicación de clustering

---

## 🔧 Mantenimiento

### Cargas Incrementales

```sql
-- Ejemplo: Cargar nuevos resultados en bronze
INSERT INTO F1_HISTORICO.BRONZE.raw_resultados
SELECT 
    *,
    CURRENT_TIMESTAMP() as created_at,
    CURRENT_TIMESTAMP() as updated_at,
    'Formula1 - Historico.xlsx' as _source
FROM @stage_name/new_results.csv;

-- Propagar a silver
MERGE INTO F1_HISTORICO.SILVER.stg_race_results AS target
USING (
    SELECT 
        TRY_CAST(resultId AS NUMBER) as resultId,
        TRY_CAST(raceId AS NUMBER) as raceId,
        -- ... más transformaciones
    FROM F1_HISTORICO.BRONZE.raw_resultados
    WHERE updated_at > (SELECT MAX(updated_at) FROM F1_HISTORICO.SILVER.stg_race_results)
) AS source
ON target.resultId = source.resultId
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT ...;
```

### Actualización de Dimensiones

```sql
-- Actualizar dimensión de pilotos (SCD Tipo 1)
MERGE INTO F1_HISTORICO.GOLD.mart_dim_driver AS target
USING F1_HISTORICO.SILVER.stg_drivers AS source
ON target.driver_id = source.driverId
WHEN MATCHED AND (
    target.driver_name != source.full_name OR
    target.nationality != source.nationality
) THEN UPDATE SET
    target.driver_name = source.full_name,
    target.nationality = source.nationality,
    target.updated_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT ...;
```

### Refresh de Tablas Agregadas

```sql
-- Recalcular resumen de temporada
TRUNCATE TABLE F1_HISTORICO.GOLD.mart_fact_driver_season_summary;

INSERT INTO F1_HISTORICO.GOLD.mart_fact_driver_season_summary
SELECT 
    driver_key,
    YEAR(r.race_date) as season_year,
    SUM(f.points_scored) as total_points,
    COUNT(DISTINCT f.race_key) as total_races,
    SUM(CASE WHEN f.is_winner THEN 1 ELSE 0 END) as total_wins,
    -- ... más agregaciones
FROM F1_HISTORICO.GOLD.mart_fact_race_results f
JOIN F1_HISTORICO.GOLD.mart_dim_race r ON f.race_key = r.race_key
GROUP BY driver_key, YEAR(r.race_date);
```

### Monitoreo de Calidad

```sql
-- Verificar integridad referencial
SELECT 
    COUNT(*) as orphan_records
FROM F1_HISTORICO.GOLD.mart_fact_race_results f
LEFT JOIN F1_HISTORICO.GOLD.mart_dim_driver d ON f.driver_key = d.driver_key
WHERE d.driver_key IS NULL;

-- Verificar duplicados
SELECT 
    result_id,
    COUNT(*) as duplicates
FROM F1_HISTORICO.GOLD.mart_fact_race_results
GROUP BY result_id
HAVING COUNT(*) > 1;

-- Verificar valores nulos en claves
SELECT 
    COUNT(*) as null_driver_keys
FROM F1_HISTORICO.GOLD.mart_fact_race_results
WHERE driver_key IS NULL;
```

---

## 📚 Referencias

### Documentación Técnica
- [Architecture Decision Record (ADR)](./docs/decisions/ADR_F1_HISTORICO_model.md)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [Power BI Star Schema Best Practices](https://docs.microsoft.com/en-us/power-bi/guidance/star-schema)

### Metodologías
- **Medallion Architecture:** [Databricks Reference](https://www.databricks.com/glossary/medallion-architecture)
- **Kimball Dimensional Modeling:** [Kimball Group](https://www.kimballgroup.com/)
- **Data Vault 2.0:** (Para consideración futura)

### Herramientas
- **Snowflake:** Data Warehouse
- **Power BI:** Visualización y BI
- **dbt (futuro):** Transformaciones y testing
- **GitHub:** Control de versiones

---

## 👥 Equipo y Contacto

**Proyecto:** Aqualia - Migración QlikView a Snowflake  
**Cliente:** Aqualia  
**Proveedor:** [Tu organización]

### Roles
- **Arquitecto de Datos:** [Nombre]
- **Ingeniero de Datos:** [Nombre]
- **Analista de BI:** [Nombre]
- **Product Owner:** [Nombre]

---

## 📝 Notas de Versión

### v1.0 - 2026-05-07
- ✅ Creación inicial del modelo
- ✅ Implementación de arquitectura medallion (3 capas)
- ✅ Modelo estrella en gold layer
- ✅ 3 tablas bronze, 5 tablas silver, 8 tablas gold
- ✅ Documentación completa (ADR + README)

### Próximas Versiones
- [ ] v1.1 - Implementación de dbt para transformaciones
- [ ] v1.2 - Añadir dimensión de circuitos
- [ ] v1.3 - Integración con orquestador (Airflow/Dagster)
- [ ] v2.0 - Implementación SCD Tipo 2 en dimensiones

---

## 📄 Licencia

[Especificar licencia según políticas de la organización]

---

**Última actualización:** 2026-05-07  
**Mantenido por:** Equipo de Data Engineering - Proyecto Aqualia
