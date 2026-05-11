# ADR: Diseño del Modelo de Datos F1 Histórico en Snowflake

**Fecha**: 2025-01-XX  
**Estado**: Aprobado  
**Autor**: Agente de Diseño de Modelo de Datos Snowflake  
**Proyecto**: Aqualia - F1 Histórico  

---

## Contexto

El proyecto F1 Histórico requiere la migración de datos desde un archivo Excel (Formula1 - Historico.xlsx) que contiene información histórica de carreras de Fórmula 1 a una arquitectura de datos en Snowflake con tres capas (Bronze, Silver, Gold) para análisis y visualización en Power BI.

### Datos de Origen
- **Fuente**: Formula1 - Historico.xlsx
- **Tablas origen**:
  1. **constructor**: 211 registros, 4 campos (constructorId, constructorRef, name, nationality)
  2. **Resultados**: 26,080 registros, 24 campos (resultados de carreras)
  3. **Drivers**: 857 registros, 8 campos (información de pilotos)

---

## Decisión

Se ha diseñado un modelo de datos en Snowflake con arquitectura medallion (Bronze-Silver-Gold) siguiendo el principio de Star Schema en la capa Gold para optimizar el consumo desde Power BI.

### Arquitectura de Capas

#### **1. Capa Bronze (Raw)**
**Propósito**: Almacenar datos sin transformar, tal como vienen del origen.

**Tablas**:
- `raw_constructor`: Datos de constructores sin transformación
- `raw_resultados`: Resultados de carreras sin transformación
- `raw_drivers`: Datos de pilotos sin transformación

**Características**:
- Todos los campos como VARCHAR o tipos básicos
- Columnas de auditoría: `created_at`, `updated_at`, `_source`
- Sin constraints ni validaciones
- Comentarios en español describiendo cada campo

**Justificación**:
- Preserva los datos originales para trazabilidad
- Permite re-procesamiento si hay errores en capas superiores
- Facilita debugging y análisis de calidad de datos

---

#### **2. Capa Silver (Staging)**
**Propósito**: Datos limpios, conformados y validados.

**Tablas**:
- `stg_constructor`: Constructores limpios con tipos corregidos
- `stg_drivers`: Pilotos con nombres normalizados y edad calculada
- `stg_race_results`: Resultados con campos calculados y flags de calidad

**Transformaciones Aplicadas**:
1. **Corrección de tipos de datos**:
   - Campos numéricos a NUMBER(38,0)
   - Fechas a DATE
   - Textos a VARCHAR con tamaños apropiados
   
2. **Limpieza de claves**:
   - Eliminación de duplicados
   - Constraints de Primary Key
   - Indexes para mejorar performance

3. **Estandarización de nombres**:
   - Snake_case para nombres de columnas
   - Nombres descriptivos en inglés
   - Aliases para campos compuestos

4. **Campos calculados agregados**:
   - `grid_gain`: Posiciones ganadas desde la parrilla
   - `is_finished`: Flag de carrera completada
   - `is_podium`: Flag de podium (top 3)
   - `is_points`: Flag de obtención de puntos
   - `age_years`: Edad del piloto en años
   - `full_name`: Nombre completo del piloto

**Justificación**:
- Proporciona datos confiables para análisis
- Reduce complejidad en capa Gold
- Facilita mantenimiento y validación de calidad

---

#### **3. Capa Gold (Marts)**
**Propósito**: Modelo dimensional tipo Star Schema optimizado para Power BI.

**Diseño Star Schema**:

**Dimensiones**:
1. **dim_constructor**:
   - Surrogate key: `constructor_key` (AUTOINCREMENT)
   - Natural key: `constructor_id`
   - Atributos: nombre, nacionalidad, estado activo

2. **dim_driver**:
   - Surrogate key: `driver_key` (AUTOINCREMENT)
   - Natural key: `driver_id`
   - Atributos: nombre, código, nacionalidad, fecha nacimiento, edad

3. **dim_race**:
   - Surrogate key: `race_key` (AUTOINCREMENT)
   - Natural key: `race_id`
   - Atributos: nombre carrera, circuito, fecha, año, ronda, país

4. **dim_status**:
   - Surrogate key: `status_key` (AUTOINCREMENT)
   - Natural key: `status_id`
   - Atributos: nombre estado, categoría

**Tabla de Hechos**:
1. **mart_race_results** (Fact Table):
   - Grain: Un registro por resultado (driver x race x constructor)
   - Foreign Keys: race_key, driver_key, constructor_key, status_key
   - Measures: posiciones, puntos, tiempos, vueltas, velocidades
   - Flags: is_finished, is_podium, is_winner, is_points
   - Clustering: CLUSTER BY (race_key) para optimizar queries temporales

**Vistas de Consumo para Power BI**:
1. `vw_constructor_performance`: Agregación por constructor
2. `vw_driver_performance`: Agregación por piloto
3. `vw_race_results_detail`: Detalle completo de resultados

**Justificación del Star Schema**:
- Optimizado para queries analíticas de Power BI
- Relaciones 1:N simples entre dimensiones y fact
- Facilita cálculos de medidas en DAX
- Mejora performance con clustering
- Simplifica modelo semántico en Power BI

---

## Decisiones de Diseño Específicas

### 1. **Uso de Surrogate Keys**
**Decisión**: Usar claves subrogadas (AUTOINCREMENT) en dimensiones Gold.

**Razones**:
- Independencia de cambios en claves naturales
- Mejor performance en joins
- Facilita SCD Type 2 en futuro si es necesario
- Tamaño más pequeño que claves naturales

### 2. **Separación de Dimensión Race**
**Decisión**: Crear dimensión `dim_race` separada aunque no esté explícita en origen.

**Razones**:
- Evita joins problemáticos en fact table
- Permite análisis temporal independiente
- Facilita agregaciones por año, circuito, ronda
- Sigue mejores prácticas de modelado dimensional

### 3. **No Agregar Tablas Nuevas**
**Decisión**: No crear tablas de hechos agregadas ni dimensiones adicionales.

**Razones**:
- Seguir instrucciones del proyecto: "No crear tablas nuevas sin referencia en metadata"
- Mantener simplicidad del modelo
- Power BI puede hacer agregaciones dinámicas
- Evitar complejidad innecesaria

### 4. **Columnas de Auditoría en Todas las Capas**
**Decisión**: Incluir `created_at`, `updated_at`, `_source` en todas las tablas.

**Razones**:
- Trazabilidad completa de datos
- Facilita debugging y troubleshooting
- Permite análisis de data lineage
- Cumple con requisitos de auditoría

### 5. **Comentarios en Español**
**Decisión**: Todos los comentarios de columnas y tablas en español.

**Razones**:
- Proyecto para cliente hispanohablante (Aqualia)
- Facilita comprensión de usuarios de negocio
- Mejora documentación y mantenimiento
- Requisito explícito del proyecto

### 6. **Clustering por race_key**
**Decisión**: CLUSTER BY (race_key) en tabla de hechos.

**Razones**:
- La mayoría de análisis son por fecha/carrera
- Mejora performance de queries temporales
- Reduce costos de escaneo en Snowflake
- Optimiza filtros comunes en Power BI

### 7. **Flags Booleanos para Análisis**
**Decisión**: Incluir flags (is_finished, is_podium, is_winner, is_points).

**Razones**:
- Simplifica filtros en Power BI
- Mejora legibilidad de queries
- Evita cálculos repetitivos en DAX
- Mejor performance en visualizaciones

---

## Convenciones de Nomenclatura

### Prefijos de Tablas
- **Bronze**: `raw_` (ej: raw_constructor)
- **Silver**: `stg_` (ej: stg_constructor)
- **Gold Dimensions**: `dim_` (ej: dim_driver)
- **Gold Facts**: `mart_` (ej: mart_race_results)
- **Views**: `vw_` (ej: vw_driver_performance)

### Nombres de Columnas
- **Snake_case** para todos los nombres
- Claves subrogadas: `[tabla]_key`
- Claves naturales: `[tabla]_id`
- Nombres descriptivos en inglés
- Columnas de auditoría estándar

---

## Mapeo de Datos

### Bronze → Silver
| Bronze (Raw) | Silver (Staging) | Transformación |
|-------------|------------------|----------------|
| constructorId | constructor_id | Tipo: NUMBER(38,0) |
| constructorRef | constructor_ref | Limpieza, VARCHAR(100) |
| name | name | Normalización |
| nationality | nationality | Estandarización |
| driverRef | driver_ref | Limpieza, VARCHAR(100) |
| forename | first_name | Normalización |
| surname | last_name | Normalización |
| - | full_name | Calculado: first_name + ' ' + last_name |
| dob | date_of_birth | Validación DATE |
| - | age_years | Calculado: YEAR(CURRENT_DATE) - YEAR(dob) |
| positionOrder | position_order | Tipo corregido |
| points | points_earned | Renombrado + validación FLOAT |
| - | grid_gain | Calculado: final_position - grid_position |
| - | is_finished | Calculado basado en status |
| - | is_podium | Calculado: final_position <= 3 |
| - | is_points | Calculado: points_earned > 0 |

### Silver → Gold
| Silver (Staging) | Gold (Mart/Dim) | Transformación |
|-----------------|-----------------|----------------|
| stg_constructor.* | dim_constructor | + surrogate key |
| stg_drivers.* | dim_driver | + surrogate key |
| stg_race_results.race_id | dim_race | Extracción dimensión |
| stg_race_results.status_id | dim_status | Extracción dimensión |
| stg_race_results.* | mart_race_results | + foreign keys, + is_winner flag |

---

## Consideraciones de Performance

### Indexes Creados
**Silver Layer**:
- idx_stg_constructor_ref
- idx_stg_drivers_ref
- idx_stg_drivers_code
- idx_stg_results_race
- idx_stg_results_driver
- idx_stg_results_constructor

**Gold Layer**:
- idx_dim_constructor_ref
- idx_dim_driver_ref
- idx_dim_driver_code
- idx_dim_race_date
- idx_dim_race_year
- idx_mart_race
- idx_mart_driver
- idx_mart_constructor
- idx_mart_points

### Clustering
- `mart_race_results` clustered por `race_key`
- Optimiza queries filtradas por fecha/carrera

---

## Modelo para START_MODEL

Siguiendo la decisión de diseño de usar START_MODEL, el esquema Gold implementa un Star Schema clásico con:
- **1 Fact Table** central: `mart_race_results`
- **4 Dimension Tables**: `dim_constructor`, `dim_driver`, `dim_race`, `dim_status`
- Relaciones 1:N desde dimensiones hacia fact
- Sin tablas de hechos agregadas (se harán en Power BI)

---

## Impacto y Consecuencias

### Positivos
✅ Modelo optimizado para Power BI  
✅ Separación clara de responsabilidades por capa  
✅ Trazabilidad completa de datos  
✅ Performance mejorada con clustering e indexes  
✅ Fácil mantenimiento y extensión  
✅ Documentación completa en español  
✅ Cumple con mejores prácticas de Data Warehouse  

### Negativos
⚠️ Complejidad adicional por tres capas (necesita ETL)  
⚠️ Almacenamiento triplicado (Bronze + Silver + Gold)  
⚠️ Requiere proceso de carga incremental para mantener actualizado  

### Riesgos
🔴 Si los datos de origen cambian estructura, hay que actualizar las tres capas  
🔴 Performance puede degradarse sin mantenimiento de indexes  
🔴 Clustering requiere créditos de Snowflake para mantenimiento automático  

---

## Alternativas Consideradas

### Alternativa 1: Modelo Plano (Single Layer)
**Descartada**: No cumple con requisitos de arquitectura medallion del proyecto.

### Alternativa 2: Snowflake Schema en Gold
**Descartada**: Star Schema es más simple y mejor para Power BI según mejores prácticas.

### Alternativa 3: Tablas Agregadas en Gold
**Descartada**: Instrucciones explícitas de no crear tablas agregadas, Power BI puede hacerlo.

---

## Referencias

- Documentación Snowflake: [Data Warehouse Design](https://docs.snowflake.com)
- Mejores prácticas Power BI: [Star Schema Design](https://docs.microsoft.com/power-bi/guidance/star-schema)
- Arquitectura Medallion: [Databricks Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- Metadata origen: `Orden_Script/orden_ejecucion.json`
- Archivo QVW: `Set_Pruebas/F1 codigo y objetos.qvw`

---

## Siguiente Pasos

1. Ejecutar scripts de creación de database y schemas
2. Implementar procesos ETL para cargar datos Bronze → Silver → Gold
3. Crear jobs de Snowflake para carga incremental
4. Configurar tasks de mantenimiento de clustering
5. Conectar Power BI y validar modelo semántico
6. Implementar data quality checks
7. Configurar alertas de monitoreo

---

**Fin del ADR**
