# ADR: Diseño del Modelo de Datos F1 Histórico en Snowflake

**Fecha:** 2026-05-06  
**Estado:** Aceptado  
**Decisores:** Equipo de Arquitectura de Datos Aqualia  
**Proyecto:** F1 Histórico - Migración desde QlikView a Snowflake  

---

## Contexto y Problema

El proyecto F1 Histórico requiere migrar datos históricos de Fórmula 1 desde QlikView (archivo Excel: Formula1 - Historico.xlsx) a Snowflake, implementando una arquitectura Medallion (Bronze-Silver-Gold) que soporte:

1. Carga incremental desde fuentes QlikView/Excel
2. Transformaciones de limpieza y conformación de datos
3. Consumo optimizado desde Power BI
4. Escalabilidad para futuros análisis de Big Data

**Fuentes de Datos Identificadas:**
- **constructor**: 211 registros, 4 campos (constructores de F1)
- **resultados**: 26,080 registros, 24 campos (resultados de carreras)
- **drivers**: Estructura inferida (pilotos de F1)

---

## Decisión

Se ha decidido implementar una arquitectura **Medallion de 3 capas** (Bronze, Silver, Gold) en Snowflake con las siguientes características:

### 1. **Capa Bronze (Raw Data)**

**Decisión:** Todas las tablas en Bronze utilizan tipos de datos `VARCHAR` para aceptar datos crudos sin validación.

**Rationale:**
- **Flexibilidad:** Acepta cualquier dato de la fuente sin errores de tipo
- **Auditoría:** Preserva el dato original exacto para trazabilidad
- **Resiliencia:** Evita fallos de carga por inconsistencias de tipo
- **Reintento:** Permite reprocesar datos sin pérdida de información

**Tablas creadas:**
- `raw_constructor`: Datos crudos de constructores
- `raw_resultados`: Datos crudos de resultados de carreras
- `raw_drivers`: Datos crudos de pilotos

**Campos estándar de auditoría:**
```sql
created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
_source STRING DEFAULT 'QlikView_F1_Historico.xlsx'
```

---

### 2. **Capa Silver (Conformed Data)**

**Decisión:** Implementar limpieza de datos, conversión de tipos, eliminación de duplicados y estandarización de nombres.

**Rationale:**
- **Calidad de Datos:** Conversión de `VARCHAR` → `NUMBER`, `DATE`, `DECIMAL`
- **Consistencia:** Nombres estandarizados (snake_case, en inglés)
- **Deduplicación:** Uso de `ROW_NUMBER() OVER (PARTITION BY ...)` para eliminar duplicados
- **Relaciones:** Establecimiento de claves foráneas lógicas

**Transformaciones clave:**
| Campo Bronze | Transformación | Campo Silver |
|--------------|----------------|--------------|
| `constructorRef` (VARCHAR) | TRIM, UPPER | `constructor_ref` (VARCHAR) |
| `positionOrder` (VARCHAR) | CAST | `position_order` (NUMBER) |
| `points` (VARCHAR) | CAST | `points_earned` (DECIMAL) |
| `milliseconds` (VARCHAR) | CAST | `race_time_milliseconds` (NUMBER) |
| `dob` (VARCHAR) | TO_DATE | `date_of_birth` (DATE) |

**Tablas creadas:**
- `stg_constructor`: Constructores conformados
- `stg_driver`: Pilotos conformados
- `stg_race_result`: Resultados de carreras conformados
- `vw_race_result_enhanced`: Vista enriquecida con JOINs

**Constraint de calidad:**
```sql
CONSTRAINT uk_constructor_ref UNIQUE (constructor_ref)
CONSTRAINT uk_driver_ref UNIQUE (driver_ref)
```

---

### 3. **Capa Gold (Star Schema para Power BI)**

**Decisión:** Implementar un **esquema estrella** con dimensiones conformadas y tablas de hechos granulares y agregadas.

**Rationale:**
- **Optimización Power BI:** Modelo dimensional facilita DAX y queries visuales
- **Rendimiento:** Clustering por `date_key` y `race_key` acelera consultas temporales
- **Simplicidad:** Separación clara entre dimensiones y hechos
- **Escalabilidad:** Permite agregar nuevas dimensiones sin reestructurar hechos

#### **Dimensiones Creadas:**

1. **`dim_driver`** (Dimensión SCD Tipo 1)
   - Clave subrogada: `driver_key`
   - Clave de negocio: `driver_ref`
   - Atributos: nombre completo, nacionalidad, código, edad
   - **Decisión SCD Tipo 1:** Sobrescritura simple (no se requiere historial de cambios en pilotos)

2. **`dim_constructor`** (Dimensión SCD Tipo 1)
   - Clave subrogada: `constructor_key`
   - Clave de negocio: `constructor_ref`
   - Atributos: nombre, nacionalidad, estado (activo/histórico)

3. **`dim_date`** (Dimensión conformada)
   - Clave: `date_key` (formato YYYYMMDD)
   - Atributos: día, semana, mes, trimestre, año, is_weekend, is_holiday
   - **Decisión:** Generación completa de calendario (1950-2050) para análisis temporal completo

4. **`dim_race`** (Dimensión de eventos)
   - Clave subrogada: `race_key`
   - Atributos: año, ronda, circuito, país, fecha
   - **Decisión:** Separar race como dimensión independiente (no como atributo degenerado) para análisis de circuitos y eventos

#### **Tablas de Hechos:**

1. **`fact_race_result`** (Tabla de hechos transaccional)
   - **Granularidad:** Un registro por piloto por carrera
   - **Métricas aditivas:** points_earned, laps_completed, race_time_milliseconds
   - **Métricas no aditivas:** grid_position, finish_position, fastest_lap_rank
   - **Indicadores booleanos:** won_race, finished_on_podium, started_from_pole, scored_points, did_finish
   - **Clustering:** `CLUSTER BY (date_key, race_key)` para optimizar queries temporales
   
   **Decisión de Indicadores Booleanos:**
   - Facilitan filtros en Power BI sin DAX complejo
   - Pre-calculados en ETL para mejor rendimiento
   - Ejemplos: `won_race`, `finished_on_podium`, `started_from_pole`

2. **`fact_championship_standings`** (Tabla de hechos agregada)
   - **Granularidad:** Un registro por piloto/constructor por año
   - **Métricas agregadas:** total_points, total_wins, total_podiums, total_races
   - **Objetivo:** Análisis de campeonatos sin re-agregar hechos transaccionales

#### **Vistas Analíticas:**

1. **`vw_race_analysis`**: Vista desnormalizada con todas las dimensiones para Power BI
2. **`vw_championship_summary`**: Resumen de campeonatos por año con rankings

---

## Decisiones Arquitectónicas Clave

### **Decisión 1: Uso de AUTOINCREMENT para Claves Subrogadas**

**Rationale:**
- Simplicidad en carga de datos (no requiere lookups previos)
- Garantiza unicidad automática
- Snowflake optimiza rendimiento de AUTOINCREMENT

**Alternativa rechazada:** Usar SHA256/MD5 de claves de negocio
- **Razón de rechazo:** Mayor complejidad, mayor tamaño de storage, colisiones potenciales

---

### **Decisión 2: Clustering por `date_key` y `race_key`**

**Rationale:**
- Queries típicas filtran por fecha/temporada (WHERE year = 2023)
- Mejora poda de particiones en Snowflake
- Reduce escaneo de microdatos

**Evidencia:**
```sql
CLUSTER BY (date_key, race_key)
```

**Alternativa rechazada:** Clustering por `driver_key`
- **Razón de rechazo:** Análisis temporal es más frecuente que análisis por piloto individual

---

### **Decisión 3: Separar `dim_race` de Atributos Degenerados**

**Problema:** ¿Debería `race` ser una dimensión o atributos degenerados en la tabla de hechos?

**Decisión:** Crear `dim_race` como dimensión independiente

**Rationale:**
- **Reutilización:** Misma carrera referenciada por múltiples resultados (211 carreras × 20 pilotos = 4,220 resultados)
- **Análisis de circuitos:** Permite análisis por circuito, país, condiciones climáticas (futuro)
- **Normalización:** Reduce duplicación de datos (nombre circuito, país, etc.)

**Impacto en Power BI:**
- Relación 1:N entre `dim_race` y `fact_race_result`
- Facilita drill-down por circuito → carrera → resultado

---

### **Decisión 4: SCD Tipo 1 vs Tipo 2 para Dimensiones**

**Decisión:** Implementar **SCD Tipo 1** (sobrescritura) para todas las dimensiones

**Rationale:**
- **Simplicidad:** No requiere gestión de versiones históricas
- **Contexto de negocio:** Los datos históricos de F1 no cambian (hechos pasados son inmutables)
- **Excepciones:** Cambios en nombres/nacionalidades de pilotos son raros y no críticos para análisis

**Alternativa rechazada:** SCD Tipo 2 (versionado)
- **Razón de rechazo:** Complejidad innecesaria para datos históricos estables
- **Cuándo reconsiderar:** Si se requiere análisis de cambios de equipos por piloto en la misma temporada

---

### **Decisión 5: Campos de Auditoría Estándar**

**Decisión:** Incluir `created_at`, `updated_at`, `_source` en todas las tablas

**Rationale:**
- **Trazabilidad:** Conocer origen y momento de cada dato
- **Debugging:** Facilita investigación de issues de calidad de datos
- **Compliance:** Cumple requisitos de auditoría de datos

**Estándar definido:**
```sql
created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
_source STRING DEFAULT '<origen_layer>'
```

---

### **Decisión 6: START_MODEL (Modelo Estrella)**

**Decisión:** Utilizar un **esquema estrella puro** (no copo de nieve)

**Rationale:**
- **Rendimiento Power BI:** Menos JOINs = mejor rendimiento
- **Simplicidad:** Más fácil de entender para usuarios de negocio
- **Import Mode:** Optimizado para modo Import de Power BI (carga en memoria)

**Alternativa rechazada:** Esquema copo de nieve (snowflake schema)
- **Razón de rechazo:** Mayor complejidad de queries, más JOINs, menor rendimiento en Power BI

**Diagrama conceptual:**
```
         dim_date
             |
         dim_race ----+
                       |
                  fact_race_result
                       |
         dim_driver ---+--- dim_constructor
```

---

### **Decisión 7: Métricas Pre-calculadas vs Calculadas en Power BI**

**Decisión:** Pre-calcular indicadores booleanos en ETL, calcular KPIs en Power BI DAX

**Rationale:**

**Pre-calculados en Snowflake (ETL):**
- `won_race`, `finished_on_podium`, `started_from_pole`: Lógica simple, rendimiento optimizado
- `positions_gained` = grid_position - finish_position: Cálculo directo

**Calculados en Power BI (DAX):**
- Puntos acumulados por temporada: CALCULATE(SUM(points), FILTER(...))
- Rankings dinámicos: RANKX(ALL(Driver), SUM(points))
- % de victorias: DIVIDE(SUM(wins), COUNT(races))

**Trade-off aceptado:** Mayor complejidad en ETL a cambio de menor carga en Power BI

---

## Consideraciones de Rendimiento

### **1. Tamaño de Datos Proyectado**

| Capa | Tabla | Registros | Crecimiento Anual |
|------|-------|-----------|-------------------|
| Bronze | raw_resultados | 26,080 | +400 (20 carreras × 20 pilotos) |
| Silver | stg_race_result | 26,080 | +400 |
| Gold | fact_race_result | 26,080 | +400 |
| Gold | dim_driver | ~850 | +25 |
| Gold | dim_constructor | 211 | +1-2 |

**Proyección 10 años:** ~30,000 resultados (muy manejable en Snowflake)

### **2. Estrategia de Particionamiento**

**No se requiere particionamiento manual** ya que:
- Snowflake gestiona micro-particiones automáticamente
- Clustering por `date_key` proporciona poda eficiente
- Volumen de datos no justifica particionamiento explícito

---

## Consecuencias

### **Positivas:**

✅ **Separación clara de responsabilidades:** Bronze (raw) → Silver (conformed) → Gold (BI)  
✅ **Optimizado para Power BI:** Esquema estrella con métricas pre-calculadas  
✅ **Escalable:** Arquitectura soporta crecimiento de datos y nuevas fuentes  
✅ **Auditable:** Campos de auditoría en todas las tablas  
✅ **Rendimiento:** Clustering optimiza queries temporales (80% de uso esperado)  
✅ **Mantenible:** Convenciones de nombres consistentes, documentación inline  

### **Negativas / Trade-offs:**

⚠️ **Complejidad ETL:** Requiere 3 capas de transformación (vs. 1 capa directa)  
⚠️ **Storage adicional:** Datos replicados en 3 capas (mitigado por compresión Snowflake)  
⚠️ **Latencia de datos:** Proceso ETL añade tiempo vs. consulta directa a fuente  
⚠️ **SCD Tipo 1:** No mantiene historial de cambios en dimensiones (aceptable para este caso de uso)  

### **Riesgos:**

🔴 **Riesgo:** Cambios en estructura de fuente QlikView  
   **Mitigación:** Bronze acepta VARCHAR, validación en Silver  

🔴 **Riesgo:** Datos faltantes en campos críticos (driver_id, race_id)  
   **Mitigación:** Constraints NOT NULL en Silver, logs de validación  

🟡 **Riesgo:** Crecimiento inesperado de volumen (adición de datos históricos pre-1950)  
   **Mitigación:** Arquitectura escala linealmente, revisar clustering si se excede 1M registros  

---

## Decisiones Futuras Requeridas

1. **ETL Tooling:** ¿dbt, Airflow, Snowflake Tasks, o Matillion?
2. **Estrategia de carga:** ¿Full refresh o incremental? (Recomendación: Incremental por `race_id`)
3. **Retención de datos:** ¿Cuánto tiempo mantener datos en Bronze? (Recomendación: 90 días)
4. **Monitoreo:** Implementar alertas de calidad de datos (ej: duplicados en Silver)
5. **Documentación:** Generar catálogo de datos (recomendación: dbt docs o Alation)

---

## Referencias

- **Fuente de datos:** QlikView - Formula1 - Historico.xlsx
- **Arquitectura Medallion:** [Databricks Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- **Snowflake Best Practices:** [Snowflake Data Modeling Guide](https://docs.snowflake.com/en/user-guide/data-modeling)
- **Star Schema:** Kimball, Ralph. "The Data Warehouse Toolkit" (3rd Edition)
- **Power BI Optimization:** [Microsoft Power BI Performance Best Practices](https://docs.microsoft.com/en-us/power-bi/guidance/power-bi-optimization)

---

## Aprobaciones

| Rol | Nombre | Fecha | Firma |
|-----|--------|-------|-------|
| Arquitecto de Datos | [Nombre] | 2026-05-06 | ✓ |
| Analista BI | [Nombre] | 2026-05-06 | Pendiente |
| DBA Snowflake | [Nombre] | 2026-05-06 | Pendiente |

---

**Última actualización:** 2026-05-06  
**Próxima revisión:** 2026-08-06 (trimestral)
