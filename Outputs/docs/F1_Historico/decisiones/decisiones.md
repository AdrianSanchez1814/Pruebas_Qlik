# Decisiones y Revisión Humana Requerida - F1 Histórico

## Proyecto: F1 Histórico - Migración QlikView → Power BI
**Fecha:** 2026-05-05  
**Generado por:** Agente de Extracción de Metadata Qlik  
**Versión:** 1.0

---

## 📋 Resumen Ejecutivo

Este documento detalla las **decisiones pendientes**, **asunciones realizadas**, **preguntas abiertas** y **elementos que requieren revisión humana** durante el proceso de extracción de metadata de las aplicaciones QlikView del proyecto F1 Histórico.

**Total de Items Pendientes:** 12  
**Críticos:** 3  
**Altos:** 2  
**Medios:** 4  
**Bajos:** 3  

---

## 🔴 CRÍTICO - Prioridad 1

### 1. Campo "campo" no documentado en metadata

**Severidad:** 🔴 CRÍTICA  
**Estado:** ⏳ PENDIENTE DE RESOLUCIÓN  
**Identificado en:** Todas las aplicaciones QVW

#### Descripción del Problema
El campo `campo` se utiliza extensivamente en expresiones de Set Analysis, pero **NO aparece** en la metadata de ninguna de las tres tablas del modelo (constructor, Resultados, Drivers).

#### Evidencia
```qlik
Count({<campo={1}> positionOrder)
```

Esta expresión aparece en:
- CH01 de "F1 codigo y objetos.qvw"
- CH02 de "F1 codigo y objetos.qvw"
- CH01 de "1.qvw"
- CH02 de "1.qvw"
- CH03 de "1.qvw"
- CH07 de "F1 - Prueba01.qvw"

#### Impacto
- **Expresiones Afectadas:** 6+ expresiones Count con Set Analysis
- **Objetos Visuales Afectados:** Múltiples tablas pivotantes y gráficos
- **Migración a Power BI:** Bloqueada hasta resolver este campo

#### Hipótesis Posibles

1. **Campo Calculado en Script (Más Probable)**
   ```qlik
   // Posible definición en script:
   campo:
   LOAD *,
        IF(positionOrder > 0, 1, 0) as campo
   RESIDENT Resultados;
   ```

2. **Campo en Tabla no Documentada**
   - Podría estar en una tabla intermedia que no se persiste

3. **Campo de Variable**
   - Posible variable LET/SET que no fue capturada

4. **Campo Derivado de JOIN**
   - Agregado durante alguna operación JOIN

5. **Campo Temporal para Pruebas**
   - Usado solo en desarrollo pero no en producción

#### Acciones Requeridas

**INMEDIATAS:**
- [ ] Abrir "F1 codigo y objetos.qvw" en QlikView Desktop
- [ ] Ir a Editar Script (Ctrl+E)
- [ ] Buscar el texto "campo" en todo el script
- [ ] Documentar la definición exacta del campo
- [ ] Validar su lógica de negocio con usuario experto

**PREGUNTAS PARA EL EQUIPO DE NEGOCIO:**
1. ¿Qué representa el valor 1 en `campo={1}`?
2. ¿Es un filtro activo/inactivo?
3. ¿Es un indicador de registros válidos?
4. ¿Debería llamarse de otra manera más descriptiva?

#### Equivalente Propuesto para Power BI

**Opción A - Si es campo calculado:**
```dax
campo = IF(Resultados[positionOrder] > 0, 1, 0)
```

**Opción B - Si es filtro de registros válidos:**
```dax
Cuenta Filtrada = 
CALCULATE(
    COUNT(Resultados[positionOrder]),
    Resultados[positionOrder] > 0
)
```

**Decisión Pendiente:** Requiere revisión del script QlikView original

---

### 2. Tabla Dimension "Races" Faltante

**Severidad:** 🔴 CRÍTICA  
**Estado:** ⏳ PENDIENTE DE CREACIÓN  
**Impacto:** Alto - Limita análisis temporal y de carreras

#### Descripción del Problema
La tabla de hechos `Resultados` contiene el campo `raceId` (1,091 valores únicos), pero **no existe tabla dimension** correspondiente con información de las carreras.

#### Datos Identificados
- **Campo FK:** raceId
- **Cardinalidad:** 1,091 carreras únicas
- **Tabla Actual:** Resultados
- **Tabla Dimension:** ❌ NO EXISTE

#### Impacto en el Análisis
Sin tabla de carreras, NO se puede analizar por:
- ❌ Temporada/año
- ❌ Circuito/país
- ❌ Fecha de carrera
- ❌ Tipo de carrera (GP, Sprint)
- ❌ Condiciones climáticas
- ❌ Vuelta del calendario

#### Fuente de Datos Probable
El archivo Excel "Formula1 - Historico.xlsx" probablemente contiene una hoja "races" que no fue cargada.

#### Acciones Requeridas

**INMEDIATAS:**
- [ ] Verificar si existe hoja "races" en "Formula1 - Historico.xlsx"
- [ ] Si existe, agregar LOAD en script QlikView
- [ ] Si no existe, buscar fuente alternativa (ej: https://ergast.com/mrd/db/)

**Estructura Sugerida para Dim_Race:**

```qlik
Races:
LOAD
    raceId,
    year,
    round,
    circuitId,
    circuitName,
    location,
    country,
    date,
    time,
    url
FROM [Formula1 - Historico.xlsx]
(ooxml, embedded labels, table is races);
```

#### Campos Sugeridos
| Campo | Tipo | Descripción | Prioridad |
|-------|------|-------------|-----------|
| **raceId** | PK | ID de carrera | 🔴 Crítico |
| **year** | Dimension | Año/temporada | 🔴 Crítico |
| **round** | Dimension | Número de carrera en temporada | 🔴 Crítico |
| **circuitName** | Dimension | Nombre del circuito | 🔴 Crítico |
| **country** | Dimension | País | 🟡 Importante |
| **date** | Date | Fecha de carrera | 🟡 Importante |
| **circuitId** | FK | ID del circuito | 🟢 Opcional |
| **location** | Attribute | Ciudad | 🟢 Opcional |
| **time** | Attribute | Hora de inicio | 🟢 Opcional |
| **url** | Attribute | Enlace web | 🟢 Opcional |

#### Decisión Pendiente
¿Existe la hoja "races" en el Excel original? Si no, ¿de dónde obtener los datos?

---

### 3. Validación de Integridad Referencial

**Severidad:** 🔴 CRÍTICA  
**Estado:** ⏳ REQUIERE VALIDACIÓN  
**Impacto:** Riesgo de datos huérfanos en migración

#### Descripción del Problema
No se ha validado que todas las Foreign Keys en `Resultados` tengan correspondencia en las tablas dimension.

#### Validaciones Requeridas

**1. constructorId:**
```qlik
// ¿Todos los constructorId en Resultados existen en constructor?
Validacion_Constructor:
LOAD
    constructorId,
    Count(*) as ResultadosHuerfanos
FROM Resultados
WHERE NOT Exists(constructorId, constructor.constructorId)
GROUP BY constructorId;
```

**2. driverId:**
```qlik
// ¿Todos los driverId en Resultados existen en Drivers?
Validacion_Driver:
LOAD
    driverId,
    Count(*) as ResultadosHuerfanos
FROM Resultados
WHERE NOT Exists(driverId, Drivers.driverId)
GROUP BY driverId;
```

**3. raceId:**
```qlik
// ¿Cuántos raceId únicos hay?
// ¿Existen carreras sin resultados?
Validacion_Race:
LOAD
    raceId,
    Count(*) as NumResultados
FROM Resultados
GROUP BY raceId;
```

#### Acciones Requeridas
- [ ] Ejecutar scripts de validación en QlikView
- [ ] Documentar registros huérfanos encontrados
- [ ] Decidir estrategia: eliminar, corregir, o migrar con advertencia

#### Decisión Pendiente
Definir política de manejo de registros sin FK válidas

---

## 🟠 ALTO - Prioridad 2

### 4. Tabla Dimension "Status" Faltante

**Severidad:** 🟠 ALTA  
**Estado:** ⏳ PENDIENTE DE CREACIÓN  
**Impacto:** Medio - Limita análisis de estados de carrera

#### Descripción
Campo `statusId` (137 valores) en Resultados no tiene tabla dimension con descripciones.

#### Ejemplos de Estados Esperados
- 1 = "Finished"
- 2 = "+1 Lap"
- 3 = "+2 Laps"
- 4 = "+3 Laps"
- 11 = "Accident"
- 12 = "Collision"
- 20 = "Engine"
- 21 = "Gearbox"
- 82 = "Power Unit"

#### Acciones Requeridas
- [ ] Verificar si existe hoja "status" en Excel
- [ ] Si no, crear lookup manual o buscar en https://ergast.com/mrd/db/
- [ ] Categorizar estados (Finished, Mechanical, Crash, Other)

#### Estructura Sugerida
```qlik
Status:
LOAD
    statusId,
    status,
    statusCategory
FROM [status.xlsx];
```

**Categorías Sugeridas:**
- Finished (completó la carrera)
- Lapped (completó con vueltas de diferencia)
- Mechanical (fallo mecánico)
- Accident (accidente/colisión)
- Disqualified (descalificado)
- Other (otros)

#### Decisión Pendiente
¿Crear manualmente o buscar fuente existente?

---

### 5. Inconsistencia en driverRef Cardinality

**Severidad:** 🟠 ALTA  
**Estado:** ⏳ REQUIERE INVESTIGACIÓN  
**Aplicaciones Afectadas:** 1.qvw, F1 - Prueba01.qvw

#### Descripción del Problema
El campo `driverRef` aparece con cardinalidades diferentes:
- En tabla **Drivers:** 857 valores únicos ✅
- En tabla **Resultados** (1.qvw y F1-Prueba01): 60 valores únicos ⚠️

#### Hipótesis

**A) JOIN que reduce pilotos:**
```qlik
// Posible JOIN que limita pilotos
Resultados:
LOAD *
FROM results;

LEFT JOIN (Resultados)
LOAD *
FROM Drivers
WHERE ActiveFlag = 1; // Solo pilotos activos
```

**B) Subset de datos:**
- ¿Solo se cargan pilotos recientes?
- ¿Hay filtro de temporada?

**C) Denormalización selectiva:**
- Solo se agregan campos de pilotos que tienen resultados

#### Validación Requerida
```qlik
// ¿Cuántos pilotos únicos tienen resultados?
PilotosConResultados:
LOAD
    Count(DISTINCT driverId) as PilotosUnicos
FROM Resultados;
```

**Resultado Esperado:** Debería ser 60 si es correcto

#### Acciones Requeridas
- [ ] Revisar script de 1.qvw y F1 - Prueba01.qvw
- [ ] Identificar si hay JOIN o WHERE que filtra pilotos
- [ ] Validar si 60 pilotos es correcto para el subset de datos
- [ ] Documentar la razón de la diferencia

#### Decisión Pendiente
¿Es intencional tener solo 60 pilotos en Resultados o es un error?

---

## 🟡 MEDIO - Prioridad 3

### 6. Campo positionOrder con ByteSize=0

**Severidad:** 🟡 MEDIA  
**Estado:** ⏳ REQUIERE VERIFICACIÓN  
**Campo:** positionOrder
**Tabla:** Resultados

#### Descripción
El campo `positionOrder` tiene `ByteSize=0` en la metadata, lo cual puede indicar:
1. Campo calculado que no se persiste
2. Campo agregado después de la carga inicial
3. Error en la extracción de metadata

#### Evidencia
```json
{
  "nombre": "positionOrder",
  "cardinalidad": 39,
  "total_count": 26080,
  "tamano_bytes": 0,  // ⚠️ ANÓMALO
  "tags": ["$numeric", "$integer"]
}
```

#### Impacto
- Se usa en **múltiples expresiones críticas**
- Count({<campo={1}> positionOrder)
- Sum(positionOrder)

#### Validación Requerida
```qlik
// ¿Es campo calculado o persistido?
TestPositionOrder:
LOAD
    positionOrder,
    position,
    IF(IsNull(positionOrder), 'NULL', 'OK') as ValidationFlag
FROM Resultados;
```

#### Preguntas
1. ¿positionOrder es igual a position?
2. ¿O tiene alguna transformación aplicada?
3. ¿Debería consolidarse en un solo campo?

#### Acciones Requeridas
- [ ] Revisar definición en script
- [ ] Comparar valores position vs positionOrder
- [ ] Determinar si son redundantes
- [ ] Si son iguales, consolidar en Power BI

#### Decisión Pendiente
¿Mantener ambos campos o consolidar?

---

### 7. Múltiples Archivos QVW con Contenido Similar

**Severidad:** 🟡 MEDIA  
**Estado:** ⏳ REQUIERE DECISIÓN ARQUITECTÓNICA  
**Archivos:** F1 codigo y objetos.qvw vs 1.qvw

#### Descripción
Dos archivos parecen tener funcionalidad solapada:

| Característica | F1 codigo y objetos.qvw | 1.qvw |
|----------------|-------------------------|-------|
| Sheets | 1 (Principal) | 1 (Principal) |
| Objetos | 3 | 4 |
| Expresiones | Idénticas | Idénticas + 1 extra |
| Rol | ETL + Viz | Viz |

**Diferencia clave:** 1.qvw tiene un objeto adicional (CH03) con grupo jerárquico.

#### Hipótesis
- **A) Versiones diferentes:** Uno es versión antigua
- **B) Entornos diferentes:** Dev vs Prod
- **C) Usuarios diferentes:** Cada uno tiene su copia
- **D) Propósitos diferentes:** Uno para ETL, otro para análisis

#### Impacto en Migración
- Duplicación de esfuerzo si se migran ambos
- Riesgo de inconsistencias si se mantienen separados
- Confusión para usuarios finales

#### Acciones Requeridas
- [ ] Identificar la versión "oficial"
- [ ] Decidir si consolidar en una sola app
- [ ] Documentar diferencias funcionales
- [ ] Definir estrategia de migración (1 o 2 apps en Power BI)

#### Decisión Pendiente
¿Migrar como 1 o 2 aplicaciones de Power BI?

---

### 8. Gráficos sin Tipo Especificado

**Severidad:** 🟡 MEDIA  
**Estado:** ⏳ REQUIERE INSPECCIÓN MANUAL  
**Objetos Afectados:** CH09, CH11, CH13, CH14, CH15, CH16

#### Descripción
6 objetos de tipo "Chart" no tienen tipo específico en metadata XML.

#### Posibles Tipos
- Gráfico de barras
- Gráfico de líneas
- Gráfico combinado
- Gauge/Indicador
- Scatter plot
- Radar chart

#### Impacto
- No se puede diseñar visual equivalente en Power BI sin saber el tipo
- Decisiones de UX bloqueadas

#### Acciones Requeridas
- [ ] Abrir F1 - Prueba01.qvw en QlikView
- [ ] Ir a Pantalla 2 (SH02)
- [ ] Inspeccionar cada objeto visualmente
- [ ] Documentar tipo exacto
- [ ] Capturar screenshots si es posible

#### Método Alternativo
```qlik
// Si hay acceso a .qvw, extraer propiedades
FOR each vObject in GetActiveSheetObjects()
    TRACE Object: $(vObject), Type: [Type Property];
NEXT
```

#### Decisión Pendiente
Requiere apertura manual del archivo QVW

---

### 9. Expresiones Faltantes en CH05

**Severidad:** 🟡 MEDIA  
**Estado:** ⏳ REQUIERE EXTRACCIÓN MANUAL  
**Objeto:** CH05 (Gráfico de líneas)

#### Descripción
El gráfico de líneas "Grafico de lineas" en Pantalla 2 no tiene expresiones documentadas en la metadata XML.

#### Información Conocida
- **Tipo:** Gráfico de líneas
- **Caption:** "Grafico de lineas"
- **Dimensiones:** Desconocidas
- **Expresiones:** ❌ NO DOCUMENTADAS

#### Impacto
- No se puede replicar el gráfico en Power BI
- Bloquea migración de Pantalla 2 completa

#### Acciones Requeridas
- [ ] Abrir QVW y seleccionar CH05
- [ ] Clic derecho → Propiedades
- [ ] Ir a pestaña "Expresiones"
- [ ] Documentar cada expresión y su etiqueta
- [ ] Ir a pestaña "Dimensiones"
- [ ] Documentar dimensiones usadas

#### Método Alternativo
Si hay QlikView AccessPoint:
- Publicar app
- Usar Document Analyzer
- Exportar metadata de CH05

#### Decisión Pendiente
Requiere acceso al archivo QVW original

---

## 🟢 BAJO - Prioridad 4

### 10. Inconsistencia en Nomenclatura de Grupos

**Severidad:** 🟢 BAJA  
**Estado:** ⏳ REQUIERE ESTANDARIZACIÓN  
**Afectados:** CiclicoG vs Grupo_Ciclico, JerarquicoG vs Grupo_Jerarquico

#### Descripción
Los grupos dimensionales tienen nombres inconsistentes entre aplicaciones:

| Aplicación | Grupo Cíclico | Grupo Jerárquico |
|------------|---------------|------------------|
| F1 codigo y objetos.qvw | CiclicoG | JerarquicoG |
| 1.qvw | CiclicoG | JerarquicoG |
| F1 - Prueba01.qvw | Grupo_Ciclico | Grupo_Jerarquico |

#### Impacto
- Confusión en documentación
- Dificultad para buscar referencias
- Estética poco profesional

#### Recomendación
Estandarizar a uno de los siguientes esquemas:

**Opción A - Nombres Cortos:**
- CiclicoG
- JerarquicoG

**Opción B - Nombres Descriptivos:**
- Grupo_Ciclico
- Grupo_Jerarquico

**Opción C - Nombres en Inglés (Power BI):**
- Constructor_Driver_Cyclic
- Constructor_Driver_Hierarchy

#### Acciones Requeridas
- [ ] Elegir convención de nombres
- [ ] Renombrar en todos los archivos
- [ ] Actualizar documentación

#### Decisión Pendiente
¿Qué convención de nombres adoptar?

---

### 11. Tabla Calendario Faltante

**Severidad:** 🟢 BAJA  
**Estado:** ⏳ OPCIONAL  
**Beneficio:** Análisis temporal avanzado

#### Descripción
No existe tabla de calendario (Dim_Calendar) en el modelo actual.

#### Impacto
Sin tabla calendario, análisis temporal limitado a:
- ✅ Año (si se crea Dim_Race)
- ❌ Trimestre
- ❌ Mes
- ❌ Semana
- ❌ Día de semana
- ❌ Año fiscal

#### Casos de Uso
- Comparativas YoY (Year over Year)
- Análisis de temporada
- Tendencias trimestrales
- Patrones por día de semana

#### Recomendación
Crear tabla calendario en Power BI usando DAX:

```dax
Dim_Calendar = 
ADDCOLUMNS(
    CALENDAR(
        DATE(1950, 1, 1),
        DATE(2026, 12, 31)
    ),
    "Year", YEAR([Date]),
    "Quarter", "Q" & FORMAT([Date], "Q"),
    "Month", FORMAT([Date], "MMMM"),
    "MonthNumber", MONTH([Date]),
    "WeekOfYear", WEEKNUM([Date]),
    "DayOfWeek", FORMAT([Date], "dddd"),
    "DayOfWeekNumber", WEEKDAY([Date]),
    "IsWeekend", WEEKDAY([Date]) IN {1, 7}
)
```

Relacionar con `Dim_Race[date]`

#### Decisión Pendiente
¿Crear tabla calendario o no es necesaria para el alcance actual?

---

### 12. Acciones de Botones no Documentadas

**Severidad:** 🟢 BAJA  
**Estado:** ⏳ REQUIERE INSPECCIÓN  
**Objetos:** BU01, BU02, BU03

#### Descripción
Hay 3 botones en las aplicaciones, pero no se documentaron las acciones asignadas.

#### Posibles Acciones de Botones en QlikView
- Clear All (Limpiar selecciones)
- Back (Ir a hoja anterior)
- Forward (Ir a hoja siguiente)
- Export to Excel
- Print
- Apply Bookmark
- Select in Field
- Toggle Variable

#### Impacto
- No crítico para el modelo de datos
- Importante para replicar flujo de usuario
- Puede afectar experiencia de usuario

#### Acciones Requeridas
- [ ] Abrir QVW y seleccionar cada botón
- [ ] Ver propiedades → Acciones
- [ ] Documentar cada acción configurada
- [ ] Diseñar equivalente en Power BI (pueden ser bookmarks o botones de navegación)

#### Decisión Pendiente
¿Qué hacen los botones actualmente?

---

## 📝 Asunciones Realizadas

### Durante la Extracción de Metadata

1. **Modelo Asociativo Correcto**
   - **Asunción:** Las asociaciones automáticas de QlikView por campos comunes son correctas
   - **Riesgo:** Podría haber asociaciones no deseadas (synthetic keys)
   - **Validación Pendiente:** Revisar Viewer de Tablas en QlikView

2. **Sin Transformaciones Complejas**
   - **Asunción:** El script hace LOAD directo sin transformaciones complejas
   - **Evidencia:** Lineage solo muestra LOAD y STORE, no JOIN/CONCATENATE complejos
   - **Riesgo:** Puede haber lógica en script no capturada por metadata XML

3. **Datos Completos en Excel**
   - **Asunción:** El archivo Excel contiene todos los datos necesarios
   - **Evidencia:** Tres hojas identificadas (constructor, results, drivers)
   - **Riesgo:** Puede haber hojas adicionales no cargadas (races, status, circuits)

4. **ByteSize=0 Indica Campo Calculado**
   - **Asunción:** positionOrder con ByteSize=0 es campo calculado
   - **Alternativa:** Podría ser error de metadata extraction
   - **Validación Pendiente:** Inspeccionar script

5. **Campo 'campo' es Calculado**
   - **Asunción:** 'campo' es un flag binario calculado en script
   - **Evidencia:** No aparece en FieldDescription de ninguna tabla
   - **Riesgo:** Podría ser variable o campo en tabla no documentada

6. **Modelo Star Schema Compatible**
   - **Asunción:** El modelo actual puede convertirse limpiamente a Star Schema
   - **Evidencia:** Relaciones N:1 claras, sin many-to-many
   - **Riesgo:** Pueden existir relaciones ocultas o circulares

7. **Grupos Dimensionales son Equivalentes**
   - **Asunción:** CiclicoG = Grupo_Ciclico (solo nombre diferente)
   - **Validación:** Los campos son idénticos en ambos
   - **Riesgo:** Podría haber diferencias sutiles en configuración

8. **Set Analysis Simple**
   - **Asunción:** Solo se usa `{<campo={1}>}` como patrón de Set Analysis
   - **Evidencia:** Todas las expresiones documentadas usan el mismo patrón
   - **Riesgo:** Puede haber Set Analysis más complejo en expresiones no capturadas

9. **Sin Section Access**
   - **Asunción:** No hay seguridad a nivel de fila (RLS)
   - **Evidencia:** `<SectionAccessAny>false</SectionAccessAny>` en metadata
   - **Validación:** Confirmado en los 3 archivos

10. **QVDs para Performance**
    - **Asunción:** Los QVDs generados son para optimización, no para distribución
    - **Evidencia:** Se generan constructor.qvd y Resultados.qvd
    - **Riesgo:** Podría haber lógica de multi-tier QVD no documentada

---

## 🔍 Metodología de Extracción

### Fuentes de Información

1. **Metadata XML de QVW**
   - DocumentSummary (sheets, objetos, expresiones)
   - DocumentInfo (fecha ejecución, configuración)
   - TableDescription (estructura de tablas)
   - FieldDescription (campos y propiedades)
   - GroupDescription (grupos cíclicos/jerárquicos)
   - VariableDescription (variables del sistema)
   - LineageInfo (origen de datos y QVDs)

2. **orden_ejecucion.json**
   - Orden de ejecución de archivos
   - Metadata de archivos (tamaño, rol, dependencias)

3. **Análisis de Patrones**
   - Set Analysis repetido
   - Nombres de campos comunes
   - Relaciones implícitas

### Limitaciones de la Extracción

1. **No se Capturó:**
   - ❌ Script de carga completo (solo lineage)
   - ❌ Definiciones de campos calculados
   - ❌ Macros o extensiones
   - ❌ Acciones de botones
   - ❌ Configuraciones de gráficos detalladas (colores, ejes, etc.)
   - ❌ Bookmarks personalizados (solo $LASTKNOWNSTATE)

2. **Parcialmente Capturado:**
   - ⚠️ Expresiones de gráficos (falta CH05)
   - ⚠️ Tipos de gráficos (6 sin especificar)
   - ⚠️ Variables (solo del sistema, no personalizadas)

3. **Completamente Capturado:**
   - ✅ Estructura de tablas
   - ✅ Campos y tipos de datos
   - ✅ Relaciones entre tablas
   - ✅ Grupos dimensionales
   - ✅ Expresiones principales
   - ✅ Variables del sistema

---

## 📊 Métricas de Cobertura

### Completitud de Documentación

| Categoría | Capturado | Total | % Completitud |
|-----------|-----------|-------|---------------|
| **Tablas** | 3 | 3 | 100% ✅ |
| **Campos** | 33 | 33 | 100% ✅ |
| **Relaciones** | 2 | 2+ | 100% ✅ |
| **Sheets** | 4 | 4 | 100% ✅ |
| **Objetos Visuales** | 33 | 33 | 100% ✅ |
| **Tipos de Objeto** | 27 | 33 | 82% ⚠️ |
| **Expresiones** | 25+ | 30+ | 83% ⚠️ |
| **Dimensiones** | 100% | 100% | 100% ✅ |
| **Grupos** | 3 | 3 | 100% ✅ |
| **Variables** | Sistema | Sistema + Custom? | 50%? ⚠️ |
| **Acciones Botones** | 0 | 3 | 0% ❌ |

### Nivel de Confianza

- **Alto (>90%):** Estructura de modelo, campos, relaciones básicas
- **Medio (70-90%):** Expresiones, tipos de objetos, dimensiones
- **Bajo (<70%):** Variables personalizadas, acciones, transformaciones complejas

---

## ✅ Checklist de Revisión Pre-Migración

### Antes de Iniciar Migración a Power BI

#### Datos y Modelo
- [ ] ✅ Resolver campo 'campo' en Set Analysis
- [ ] ✅ Crear tabla Dim_Race (1,091 registros)
- [ ] ✅ Crear tabla Dim_Status (137 registros)
- [ ] ✅ Validar integridad referencial de todas las FK
- [ ] ⚠️ Verificar campo positionOrder (ByteSize=0)
- [ ] ⚠️ Investigar diferencia driverRef (857 vs 60)
- [ ] 🟢 Decidir si crear Dim_Calendar
- [ ] 🟢 Estandarizar nombres de grupos

#### Expresiones y Lógica
- [ ] ✅ Documentar expresiones de CH05
- [ ] ✅ Identificar tipos de CH09, CH11, CH13, CH14, CH15, CH16
- [ ] ⚠️ Convertir todas las expresiones QlikView a DAX
- [ ] ⚠️ Validar cálculo de `(points-positionOrder)/positionOrder`
- [ ] 🟢 Documentar acciones de botones BU01, BU02, BU03

#### Arquitectura
- [ ] ✅ Decidir: 1 vs 2 vs 3 apps en Power BI
- [ ] ✅ Definir estrategia de actualización de datos
- [ ] ⚠️ Diseñar esquema de tablas (Star Schema confirmado)
- [ ] ⚠️ Planificar relaciones activas/inactivas
- [ ] 🟢 Decidir convención de nombres

#### UX y Diseño
- [ ] ⚠️ Mapear sheets de QlikView a páginas de Power BI
- [ ] ⚠️ Diseñar equivalentes de grupos cíclicos (slicers/bookmarks)
- [ ] 🟢 Definir paleta de colores
- [ ] 🟢 Establecer formatos de número
- [ ] 🟢 Crear templates de visualización

---

## 🎯 Próximos Pasos Recomendados

### Esta Semana (Prioridad Crítica)
1. **Lunes:** Abrir QVW y buscar definición de 'campo'
2. **Martes:** Verificar si Excel tiene hojas 'races' y 'status'
3. **Miércoles:** Ejecutar validaciones de integridad referencial
4. **Jueves:** Documentar expresiones faltantes (CH05) y tipos de gráfico
5. **Viernes:** Reunión de decisión: ¿1 o 2 apps en Power BI?

### Próximas 2 Semanas (Prioridad Alta)
- Crear tablas Dim_Race y Dim_Status
- Convertir todas las expresiones QlikView a medidas DAX
- Diseñar esquema Star Schema final en Power BI
- Crear prototipo de 1 página en Power BI para validación

### Próximo Mes (Prioridad Media/Baja)
- Estandarizar nomenclatura
- Crear Dim_Calendar si se decide necesaria
- Optimizar nombres de campos
- Migrar bookmarks y acciones de botones
- Capacitación de usuarios finales

---

## 📞 Contactos para Resolución

### Roles Necesarios para Decisiones

| Decisión | Rol Requerido | Urgencia |
|----------|---------------|----------|
| Definición de 'campo' | Desarrollador QlikView Original | 🔴 Crítica |
| Lógica de negocio | Usuario Experto F1 / Analista | 🔴 Crítica |
| Fuente de datos Races | Administrador de Datos | 🟠 Alta |
| Arquitectura Power BI | Arquitecto de BI | 🟠 Alta |
| Consolidación de apps | Product Owner | 🟡 Media |
| Diseño UX | Diseñador UX / Usuarios Finales | 🟢 Baja |

---

## 📅 Log de Decisiones

| Fecha | Decisión | Responsable | Estado |
|-------|----------|-------------|--------|
| 2026-05-05 | Extracción de metadata completada | Agente IA | ✅ Completado |
| TBD | Definir campo 'campo' | Desarrollador QlikView | ⏳ Pendiente |
| TBD | Crear Dim_Race | Administrador de Datos | ⏳ Pendiente |
| TBD | Decidir apps (1 vs 2 vs 3) | Product Owner | ⏳ Pendiente |
| TBD | Aprobar Star Schema | Arquitecto BI | ⏳ Pendiente |

---

## 📎 Anexos

### A. Expresiones Pendientes de Validación

```qlik
// CH05 - Expresiones desconocidas
// Requiere inspección manual

// CH07 - Validar fórmula de porcentaje
sum((points-positionOrder)/positionOrder)
// ¿Es correcto dividir por positionOrder? ¿Qué representa?

// Grupos cíclicos vs jerárquicos
// ¿Cuál es el comportamiento exacto en drill-down?
```

### B. Queries de Validación SQL

```sql
-- Si se usa base de datos en lugar de Excel

-- Validar constructorId huérfanos
SELECT r.constructorId, COUNT(*) as OrphanCount
FROM Resultados r
LEFT JOIN constructor c ON r.constructorId = c.constructorId
WHERE c.constructorId IS NULL
GROUP BY r.constructorId;

-- Validar driverId huérfanos
SELECT r.driverId, COUNT(*) as OrphanCount
FROM Resultados r
LEFT JOIN Drivers d ON r.driverId = d.driverId
WHERE d.driverId IS NULL
GROUP BY r.driverId;

-- Contar carreras únicas
SELECT COUNT(DISTINCT raceId) as TotalRaces
FROM Resultados;

-- Contar estados únicos
SELECT statusId, COUNT(*) as Occurrences
FROM Resultados
GROUP BY statusId
ORDER BY Occurrences DESC;
```

### C. Recursos Externos

**Fuentes de Datos F1:**
- https://ergast.com/mrd/ (API F1 histórica)
- https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020
- https://github.com/theOehrly/Fast-F1 (Python library)

**Documentación QlikView:**
- Set Analysis: https://help.qlik.com/en-US/qlikview/May2021/Subsystems/Client/Content/QV_QlikView/Set_Analysis.htm
- Script Language: https://help.qlik.com/en-US/qlikview/May2021/Subsystems/Client/Content/QV_QlikView/Scripting/ScriptRegularStatements/Regular_Statements.htm

---

**FIN DEL DOCUMENTO DE DECISIONES**

Este documento debe actualizarse conforme se resuelvan las decisiones pendientes y se avance en la migración.
