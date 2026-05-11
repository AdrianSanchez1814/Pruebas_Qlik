# Decisiones y Revisión Humana Requerida
## F1 codigo y objetos - QlikView Metadata Extraction

**Fecha de análisis**: 2026-05-05  
**Archivo analizado**: Set Pruebas/F1 codigo y objetos.qvw  
**Analista**: Agente de Extracción de Metadatos Aqualia

---

## 1. ASUNCIONES REALIZADAS

### 1.1 Estructura del Modelo de Datos

**Asunción**: El modelo actual es una estructura de copo de nieve (snowflake) con la tabla `Resultados` como fact table principal.

**Razones**:
- La tabla `Resultados` contiene 26,080 registros (la más grande)
- Tiene múltiples medidas numéricas (points, laps, milliseconds, etc.)
- Contiene claves foráneas a dimensiones (constructorId, driverId, raceId, statusId)
- Las tablas `constructor` y `Drivers` contienen atributos descriptivos

**Requiere validación**: ¿Es correcta esta interpretación o hay tablas de hechos adicionales no visibles en el QVW?

---

### 1.2 Tablas Dimension vs Fact

**Clasificación asumida**:
- **FACT**: Resultados
- **DIMENSION**: constructor, Drivers

**Criterios aplicados**:
- Tablas con muchos registros y medidas → FACT
- Tablas con atributos descriptivos y menor cardinalidad → DIMENSION

**Requiere validación**: ¿Existen otras tablas que no aparecieron en el XML metadata extraído?

---

### 1.3 Campo "campo" en Set Analysis

**Expresión encontrada**:
```qlik
Count({<campo={1}> } positionOrder)
```

**Asunción**: El campo "campo" es un campo calculado o variable no visible en el modelo de datos extraído del XML.

**Alternativas posibles**:
1. Es un campo oculto/calculado en el script
2. Es una variable SET/LET no documentada
3. Es un error de documentación y debería ser otro campo

**❓ PREGUNTA CRÍTICA**: ¿Cuál es la definición real del campo "campo"? ¿Qué representa el valor {1}?

---

### 1.4 Interpretación de Fórmulas

**Fórmula identificada**:
```qlik
sum((points-positionOrder)/positionOrder)
```

**Interpretación asumida**: 
- Calcula la variación porcentual entre puntos obtenidos y posición final
- Valores positivos indican mejor rendimiento que la posición
- Valores negativos indican rendimiento inferior a la posición

**Requiere validación**: ¿Es esta la interpretación correcta del negocio? ¿Hay documentación funcional?

---

## 2. PREGUNTAS ABIERTAS

### 2.1 Dimensiones Faltantes

**⚠️ CRÍTICO - Tabla Race**

El campo `raceId` en la tabla `Resultados` tiene 1,104 valores distintos, pero no hay tabla de dimensión correspondiente.

**Preguntas**:
1. ¿Existe una tabla Race en el origen de datos (Excel)?
2. ¿Se carga esta tabla en otro QVW del flujo?
3. ¿Debería crearse esta dimensión desde otra fuente?

**Impacto**: Alto - Sin esta dimensión, no se puede analizar resultados por carrera, circuito, fecha, etc.

**Campos esperados en tabla Race**:
- raceId (PK)
- raceName
- year
- round
- circuitId
- date
- time
- url

---

**⚠️ MEDIO - Tabla Status**

El campo `statusId` en la tabla `Resultados` tiene 138 valores distintos.

**Preguntas**:
1. ¿Existe una tabla de status en el origen de datos?
2. ¿Qué representan estos estados? (Finished, DNF, Accident, etc.)

**Impacto**: Medio - Afecta la capacidad de análisis de resultados no finalizados

**Campos esperados en tabla Status**:
- statusId (PK)
- status (descripción textual)

---

### 2.2 Script ETL Completo

**Limitación**: Los archivos QVW son binarios y solo se pudo extraer metadata XML parcial.

**Información NO extraída**:
- Script completo de carga (LOAD statements)
- Variables SET/LET definidas por usuario
- Transformaciones MAPPING
- Expresiones JOIN/CONCATENATE completas
- Comentarios del desarrollador

**❓ PREGUNTA**: ¿Existe acceso al archivo fuente .qvs o a la aplicación abierta en QlikView Developer para extracción completa del script?

---

### 2.3 Archivo Excel Fuente

**Ruta encontrada**:
```
c:\users\jorgebolanos\onedrive - epam\bola_qlik\aqualiamigracionqlik_pbi\set pruebas\formula1 - historico.xlsx
```

**Hojas identificadas**: constructor, results, drivers

**Preguntas**:
1. ¿Este archivo Excel contiene más hojas no cargadas en el modelo?
2. ¿Hay otras fuentes de datos además del Excel?
3. ¿Las hojas "results" y "drivers" se cargan directamente o hay transformaciones?

---

### 2.4 Grupos Cíclicos y Jerárquicos

**Grupos identificados**:
- **CiclicoG**: constructorRef, driverRef (cíclico)
- **JerarquicoG**: constructorRef → driverRef (drill-down)

**Preguntas para migración a Power BI**:
1. ¿El grupo cíclico debe convertirse en:
   - Botones de selección?
   - Segmentadores independientes?
   - Bookmarks?
   - Otra solución?

2. ¿El usuario espera poder alternar entre constructor y driver en el mismo visual?

3. ¿La jerarquía debe ser siempre Constructor → Driver o también Driver → Constructor?

**Impacto**: Medio - Afecta el diseño de la interfaz de usuario en Power BI

---

### 2.5 Expresiones y Medidas

**Set Analysis no documentado**:
```qlik
{<campo={1}>}
```

**Preguntas**:
1. ¿Qué campo es "campo"?
2. ¿Qué representa el filtro {1}?
3. ¿Hay más expresiones de Set Analysis no visibles en los objetos analizados?

---

## 3. CALIDAD DE DATOS

### 3.1 Campos de Texto que Deberían Ser Numéricos

**Campo identificado**: `fastestLapSpeed`
- **Actual**: Tipo texto (8,892 valores distintos)
- **Esperado**: Tipo numérico
- **Impacto**: No se pueden realizar agregaciones numéricas

**Pregunta**: ¿Por qué este campo es texto? ¿Contiene valores no numéricos (ej: "N/A")?

---

### 3.2 Cardinalidad Alta en Campos de Tiempo

**Campos identificados**:
- `time`: 17,836 valores distintos en 26,080 registros
- `milliseconds`: 19,599 valores distintos
- `fastestLapTime`: 17,914 valores distintos

**Observación**: Alta cardinalidad normal para tiempos, pero:

**Pregunta**: ¿Hay necesidad de crear rangos o bins para análisis temporal?

---

## 4. DECISIONES DE ARQUITECTURA PARA POWER BI

### 4.1 Modelo Estrella Propuesto

**Estructura sugerida**:
```
       Race -------|
                   |
    Constructor ---+--- Resultados (FACT)
                   |
       Drivers ----|
                   |
       Status -----|
```

**Decisión requerida**:
1. ¿Se acepta esta estructura?
2. ¿Hay otras dimensiones necesarias? (Circuits, Seasons, etc.)

---

### 4.2 Manejo de Grupos

**Opción A - Jerarquía Nativa**:
```
Constructor
  └─ Driver
```
- **Pro**: Nativo en Power BI, fácil drill-down
- **Contra**: Drill-down unidireccional

**Opción B - Slicers Independientes**:
- Slicer de Constructor
- Slicer de Driver
- **Pro**: Filtrado independiente
- **Contra**: Pierde concepto de grupo

**Opción C - Botones con Bookmarks**:
- Botón "Ver por Constructor"
- Botón "Ver por Driver"
- **Pro**: Replica comportamiento cíclico
- **Contra**: Más complejo de mantener

**❓ DECISIÓN REQUERIDA**: ¿Qué opción prefiere el negocio?

---

### 4.3 Conversión de Set Analysis

**Set Analysis Qlik**:
```qlik
Count({<campo={1}> } positionOrder)
```

**Propuesta DAX**:
```dax
Contar Set Analysis = 
CALCULATE(
    COUNT(Resultados[positionOrder]),
    Resultados[campo] = 1  -- ⚠️ Requiere definir "campo"
)
```

**❓ BLOQUEO**: No se puede completar la conversión sin saber qué es "campo"

---

### 4.4 Fórmula de Variación Porcentual

**Qlik**:
```qlik
sum((points-positionOrder)/positionOrder)
```

**Propuesta DAX**:
```dax
Variación % = 
SUMX(
    Resultados,
    DIVIDE(
        Resultados[points] - Resultados[positionOrder],
        Resultados[positionOrder],
        0  -- Evita división por cero
    )
)
```

**Pregunta**: ¿Esta fórmula tiene sentido de negocio? ¿Qué interpretación tiene?

---

## 5. LIMITACIONES TÉCNICAS DEL ANÁLISIS

### 5.1 Archivos Binarios QVW

**Limitación**: Los QVW son archivos binarios comprimidos. Solo se pudo extraer:
- Metadata XML interno
- Estructura de tablas y campos
- Definiciones de objetos visuales
- Algunas expresiones

**NO se pudo extraer**:
- Script ETL completo
- Comentarios de código
- Lógica de transformación detallada
- Variables personalizadas completas

**Recomendación**: Acceder a:
- Archivo .qvw abierto en QlikView Developer
- Archivos .qvs si existen
- Documentación funcional del proyecto

---

### 5.2 Orden de Ejecución

**Archivo analizado según orden_ejecucion.json**:
```json
{
  "orden": 1,
  "archivo": "F1 codigo y objetos.qvw",
  "nivel_indentacion": 0,
  "depende_de": null
}
```

**Observación**: Es el único archivo en el flujo de ejecución.

**Pregunta**: ¿Es un QVW standalone o parte de un flujo ETL mayor no documentado?

---

## 6. TAREAS PENDIENTES

### Tareas Técnicas:
- [ ] Validar existencia de tabla Race en fuente original
- [ ] Validar existencia de tabla Status
- [ ] Identificar el campo "campo" usado en Set Analysis
- [ ] Acceder al script QlikView completo (.qvs o Developer)
- [ ] Validar archivo Excel fuente y todas sus hojas
- [ ] Documentar variables SET/LET personalizadas

### Tareas de Negocio:
- [ ] Validar interpretación de la fórmula de variación porcentual
- [ ] Decidir estrategia de grupos cíclicos para Power BI
- [ ] Confirmar estructura del star schema propuesto
- [ ] Validar si hay dimensiones adicionales necesarias (Circuits, Seasons, etc.)
- [ ] Revisar necesidad de crear bins para campos de tiempo

### Tareas de Calidad de Datos:
- [ ] Investigar por qué fastestLapSpeed es texto
- [ ] Validar valores NULL o vacíos en campos críticos
- [ ] Determinar si hay datos históricos no incluidos en el modelo actual

---

## 7. RECOMENDACIONES

### 7.1 Inmediatas
1. **CRÍTICO**: Obtener definición del campo "campo" en Set Analysis
2. **CRÍTICO**: Localizar o crear tabla Race dimension
3. **ALTO**: Acceder al script QlikView completo para validación

### 7.2 Corto Plazo
1. Crear tabla Status dimension
2. Convertir fastestLapSpeed a numérico
3. Definir estrategia de grupos para Power BI
4. Documentar lógica de negocio de fórmulas complejas

### 7.3 Medio Plazo
1. Validar modelo estrella con usuarios clave
2. Crear documentación funcional completa
3. Establecer pruebas de validación de datos
4. Definir estrategia de manejo de datos históricos

---

## 8. RIESGOS IDENTIFICADOS

| Riesgo | Severidad | Impacto | Mitigación |
|--------|-----------|---------|------------|
| Campo "campo" no definido | ALTA | Bloqueo de migración de expresiones | Urgente: validar con desarrollador original |
| Tabla Race faltante | ALTA | Análisis incompleto | Identificar fuente y agregar al modelo |
| Script incompleto | MEDIA | Posibles transformaciones no replicadas | Acceder a .qvs o Developer |
| Grupos cíclicos sin equivalente | MEDIA | UX diferente en Power BI | Decidir estrategia alternativa |
| Calidad de datos (texto vs numérico) | BAJA | Agregaciones incorrectas | Limpieza en ETL |

---

## 9. CONTACTOS NECESARIOS

**Personas a consultar**:
1. **Desarrollador QlikView original**: Jorge Bolanos (según ruta del archivo)
2. **Usuario clave de negocio**: Para validar fórmulas y lógica
3. **Administrador de datos**: Para acceso a fuentes originales
4. **Arquitecto de datos**: Para validar modelo estrella propuesto

---

## 10. PRÓXIMOS PASOS

### Paso 1: Validación Técnica (Urgente)
- Reunión con desarrollador QlikView
- Acceso al código fuente completo
- Identificación del campo "campo"
- Validación de fuentes de datos

### Paso 2: Validación de Negocio (Alta prioridad)
- Reunión con usuarios clave
- Validación de fórmulas y lógica
- Confirmación de estructura de modelo
- Definición de requerimientos Power BI

### Paso 3: Diseño Detallado (Media prioridad)
- Diseño final de star schema
- Estrategia de grupos y jerarquías
- Conversión completa de expresiones DAX
- Plan de testing

---

## CONCLUSIÓN

Este análisis ha extraído la **estructura base del modelo de datos** y las **expresiones principales**, pero requiere **validación humana crítica** en varios puntos antes de proceder con la migración a Power BI.

**Estado**: ⚠️ **BLOQUEADO** para migración completa hasta resolver preguntas críticas.

**Siguiente acción recomendada**: Reunión de validación con desarrollador original y usuarios clave.

---

**Documento generado por**: Agente de Extracción de Metadatos Aqualia  
**Fecha**: 2026-05-05  
**Versión**: 1.0
