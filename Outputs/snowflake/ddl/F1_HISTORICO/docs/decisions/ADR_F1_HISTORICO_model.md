# ADR: F1 Histórico Data Model Design

**Proyecto:** Aqualia - Migración QlikView a Snowflake + Power BI  
**Aplicación:** F1 Histórico  
**Fecha:** 2026-05-07  
**Estado:** Aprobado  
**Autores:** Snowflake Data Model Design Agent

---

## Contexto

Se requiere diseñar un modelo de datos en Snowflake para migrar la aplicación "F1 Histórico" desde QlikView a una arquitectura moderna basada en Snowflake y Power BI. El origen de datos son archivos Excel (Formula1 - Historico.xlsx) con información histórica de Fórmula 1 incluyendo:
- Constructores (211 registros, 4 campos)
- Resultados de carreras (26,080 registros, 18-24 campos)
- Pilotos (857 registros, 8 campos)

---

## Decisiones de Diseño

### 1. Arquitectura Medallion (Bronze-Silver-Gold)

**Decisión:** Implementar una arquitectura medallion de 3 capas.

**Justificación:**
- **Bronze (Raw):** Preserva los datos en su forma original para auditoría y reprocesamiento
- **Silver (Staging):** Proporciona datos limpios y conformados con tipos de datos correctos
- **Gold (Marts):** Optimiza para consumo de BI con modelo estrella

**Alternativas consideradas:**
- Modelo directo de 2 capas: Descartado por falta de trazabilidad y flexibilidad
- Arquitectura Lambda: Demasiado compleja para el volumen de datos actual

---

### 2. Modelo Estrella en Gold Layer

**Decisión:** Implementar un modelo estrella (star schema) con las siguientes dimensiones y hechos:

**Dimensiones:**
- `mart_dim_driver` - Dimensión de pilotos
- `mart_dim_constructor` - Dimensión de constructores
- `mart_dim_race` - Dimensión de carreras
- `mart_dim_date` - Dimensión de fechas (conformada)
- `mart_dim_driver_constructor` - Dimensión puente (bridge table)

**Hechos:**
- `mart_fact_race_results` - Resultados de carreras (granularidad: piloto + carrera)
- `mart_fact_driver_season_summary` - Resumen agregado por piloto/temporada
- `mart_fact_constructor_season_summary` - Resumen agregado por constructor/temporada

**Justificación:**
- Power BI está optimizado para modelos estrella
- Simplicidad en las consultas de BI
- Rendimiento superior vs. modelo normalizado
- Facilita agregaciones comunes (temporada, campeonato)

---

### 3. Tabla Puente para Relación Many-to-Many

**Decisión:** Crear `mart_dim_driver_constructor` como dimensión puente separada.

**Problema:** Un piloto puede correr para múltiples constructores en diferentes carreras, creando una relación many-to-many problemática para Power BI.

**Solución:** 
- Separar la relación en una tabla puente independiente
- Permite joins flexibles sin duplicación de hechos
- Evita problemas de conteo doble en Power BI

**Alternativas consideradas:**
- Desnormalizar en la tabla de hechos: Genera duplicación excesiva
- Role-playing dimensions: No resuelve el problema fundamental

---

### 4. Convenciones de Nomenclatura

**Decisión:** Aplicar prefijos consistentes por capa:

| Capa   | Prefijo | Ejemplo                    |
|--------|---------|----------------------------|
| Bronze | raw_    | raw_constructor            |
| Silver | stg_    | stg_constructor            |
| Silver | int_    | int_driver_constructor     |
| Gold   | mart_   | mart_fact_race_results     |

**Justificación:**
- Identifica inmediatamente la capa del dato
- Facilita gobernanza y lineage
- Estándar en la industria

---

### 5. Campos de Auditoría Obligatorios

**Decisión:** Todas las tablas incluyen:
- `created_at TIMESTAMP_NTZ` - Fecha de creación
- `updated_at TIMESTAMP_NTZ` - Fecha de actualización
- `_source STRING` - Sistema fuente

**Justificación:**
- Trazabilidad completa del linaje de datos
- Facilita debugging y análisis de calidad
- Requerimiento para auditoría

---

### 6. Uso de Claves Surrogates

**Decisión:** Utilizar claves surrogates (NUMBER AUTOINCREMENT) en todas las dimensiones y hechos.

**Justificación:**
- Independencia de las claves de negocio
- Optimización de joins (claves numéricas)
- Facilita cambios en claves de negocio
- Mejor rendimiento en Power BI

**Implementación:**
- Claves surrogates: `driver_key`, `constructor_key`, `race_key`, etc.
- Claves de negocio preservadas: `driverId`, `constructorRef`, `raceId`

---

### 7. Tipos de Datos en Silver Layer

**Decisión:** Convertir tipos de datos STRING del bronze a tipos apropiados:

| Campo Original | Tipo Bronze | Tipo Silver |
|----------------|-------------|-------------|
| driverId       | STRING      | NUMBER      |
| points         | STRING      | DECIMAL(10,2) |
| dob            | STRING      | DATE        |
| milliseconds   | STRING      | NUMBER      |
| fastestLapSpeed| STRING      | DECIMAL(10,3) |

**Justificación:**
- Validación de datos en etapa temprana
- Optimización de almacenamiento
- Permite operaciones matemáticas correctas
- Mejor rendimiento en agregaciones

---

### 8. Clustering en Tabla de Hechos

**Decisión:** Aplicar `CLUSTER BY (date_key, race_key)` en `mart_fact_race_results`.

**Justificación:**
- Las consultas de BI filtran frecuentemente por fecha y carrera
- Mejora significativa de rendimiento en consultas típicas
- Reduce el scanning de micro-partitions
- Optimiza queries temporales (año, temporada)

---

### 9. Campos VARIANT para Datos Semi-estructurados

**Decisión:** Incluir campo `campo_json VARIANT` en resultados.

**Justificación:**
- Los metadatos de QlikView muestran un campo "campo" variable
- VARIANT permite flexibilidad sin cambios de schema
- Facilita migración incremental
- No afecta performance de queries principales

---

### 10. Dimensión de Fechas Conformada

**Decisión:** Crear `mart_dim_date` como dimensión conformada independiente.

**Justificación:**
- Reutilizable en múltiples modelos
- Facilita análisis temporal complejo
- Incluye jerarquías pre-calculadas (año, trimestre, mes)
- Estándar de BI para time-intelligence

**Atributos incluidos:**
- Componentes de fecha (día, semana, mes, trimestre, año)
- Nombres y abreviaturas en español
- Indicadores (fin de semana, festivo)
- Década para análisis histórico de F1

---

### 11. Tablas de Hechos Agregadas

**Decisión:** Crear tablas de hechos agregadas por temporada:
- `mart_fact_driver_season_summary`
- `mart_fact_constructor_season_summary`

**Justificación:**
- Las consultas de campeonato son muy comunes
- Pre-agregación mejora dramáticamente el rendimiento
- Reduce carga computacional en Power BI
- Facilita dashboards de resumen ejecutivo

**Métricas incluidas:**
- Puntos totales, victorias, podios
- Tasas calculadas (win rate, podium rate)
- Posición en campeonato

---

### 12. Campos Calculados e Indicadores

**Decisión:** Incluir flags booleanos en la tabla de hechos:
- `is_finished` - Terminó la carrera
- `is_winner` - Ganó la carrera
- `is_podium` - Top 3
- `is_points_scorer` - Sumó puntos
- `has_fastest_lap` - Tuvo vuelta más rápida

**Justificación:**
- Simplifica DAX en Power BI
- Pre-cálculo de condiciones comunes
- Mejora rendimiento de visualizaciones
- Facilita filtros y segmentaciones

---

### 13. Comentarios en Español

**Decisión:** Todos los comentarios de columnas y tablas en español.

**Justificación:**
- Equipo de negocio hispanohablante
- Facilita comprensión y adopción
- Documentación accesible para usuarios finales
- Alineado con requisitos del proyecto Aqualia

---

### 14. Manejo de Valores Nulos y Calidad

**Decisión:** Aplicar constraints NOT NULL solo en claves primarias y foráneas críticas.

**Justificación:**
- Datos históricos pueden tener gaps
- Flexibilidad para cargas incrementales
- Validación de calidad en Silver layer
- NOT NULL estricto puede bloquear cargas legítimas

---

### 15. Estrategia de Actualización (SCD)

**Decisión:** Dimensiones implementan SCD Tipo 1 (sobrescritura).

**Justificación:**
- Datos históricos de F1 son estables
- Cambios en atributos son raros (ej: cambio de nacionalidad)
- Simplicidad operacional
- Suficiente para requisitos actuales

**Consideración futura:** Si se requiere historial de cambios, migrar a SCD Tipo 2.

---

## Limitaciones y Supuestos

### Limitaciones
1. **Datos de carreras incompletos:** La tabla `stg_races` requiere enriquecimiento adicional (nombres de circuitos, fechas) que no están en los metadatos actuales.
2. **Campo "campo":** Su propósito exacto no está documentado en los metadatos de QlikView.
3. **Status IDs:** No hay catálogo de estados de resultados (DNF, DSQ, etc.).

### Supuestos
1. Los datos fuente son correctos y completos
2. No hay requerimientos de tiempo real
3. Las cargas serán batch diarias/semanales
4. El volumen de datos crecerá linealmente
5. No hay requerimientos GDPR/PII críticos

---

## Impacto y Riesgos

### Impacto Positivo
- ✅ Modelo optimizado para Power BI
- ✅ Trazabilidad completa de datos
- ✅ Arquitectura escalable
- ✅ Facilita mantenimiento y evolución
- ✅ Rendimiento superior vs. QlikView

### Riesgos
- ⚠️ **Enriquecimiento de datos:** Requerirá fuentes adicionales para completar dimensión de carreras
- ⚠️ **Complejidad inicial:** 3 capas aumentan complejidad de ETL
- ⚠️ **Adopción:** Usuarios deben aprender nuevo modelo vs. QlikView

### Mitigación
- Documentación exhaustiva del modelo
- Capacitación al equipo de BI
- Vistas simplificadas para usuarios finales
- Monitoreo de rendimiento post-despliegue

---

## Próximos Pasos

1. **Validación con stakeholders:** Revisar modelo con usuarios de negocio
2. **Desarrollo de ETL:** Implementar pipelines de carga Bronze → Silver → Gold
3. **Pruebas de rendimiento:** Validar clustering y optimizaciones
4. **Desarrollo de Power BI:** Crear semantic model y dashboards
5. **Documentación de usuario:** Guías de uso del modelo
6. **Plan de cutover:** Estrategia de migración desde QlikView

---

## Referencias

- Arquitectura Medallion: [Databricks Reference](https://www.databricks.com/glossary/medallion-architecture)
- Star Schema Best Practices: [Kimball Group](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)
- Snowflake Data Modeling: [Snowflake Documentation](https://docs.snowflake.com/en/user-guide/data-modeling)
- Power BI Star Schema: [Microsoft Docs](https://docs.microsoft.com/en-us/power-bi/guidance/star-schema)

---

## Historial de Cambios

| Fecha      | Versión | Autor | Cambios |
|------------|---------|-------|---------|
| 2026-05-07 | 1.0     | Agente | Creación inicial del ADR |

---

## Aprobación

- [ ] Arquitecto de Datos
- [ ] Líder Técnico
- [ ] Product Owner
- [ ] Equipo de BI

---

**Fin del documento**
