# Expresiones y Fórmulas - F1 Histórico

## Proyecto: F1 Histórico
**Fecha de Extracción:** 2026-05-05  
**Aplicaciones Analizadas:** F1 codigo y objetos.qvw, 1.qvw, F1 - Prueba01.qvw

---

## 📊 Resumen Ejecutivo

Este documento contiene todas las expresiones, fórmulas y cálculos utilizados en los gráficos, tablas, KPIs y variables de las aplicaciones QlikView del proyecto F1 Histórico.

**Total de Expresiones Documentadas:** 25+  
**Páginas con Visualizaciones:** 4  
**Objetos Visuales:** 33  

---

## 🎯 APLICACIÓN 1: F1 codigo y objetos.qvw

### Página: Principal (SH01)

#### CH01 - Tabla Pivotante "Tabla"
**Tipo:** Tabla Pivotante  
**Dimensión:** CiclicoG (Grupo Cíclico: constructorRef ↔ driverRef)

**Expresión 1: Contar Set Analisis**
```qlik
Count({<campo={1}> positionOrder)
```
- **Propósito:** Cuenta los registros de positionOrder donde el campo "campo" tiene valor 1
- **Uso:** Filtrado condicional mediante Set Analysis
- **⚠️ NOTA:** El campo "campo" NO está documentado en la metadata. Se requiere revisión humana para determinar su origen y definición.

**Expresión 2: Suma**
```qlik
Sum(positionOrder)
```
- **Propósito:** Suma total de los valores de positionOrder
- **Campo Origen:** Resultados.positionOrder (numeric, integer)

---

#### CH02 - Gráfico Mekko "Contar Set Analisis"
**Tipo:** Gráfico Mekko  
**Dimensión:** CiclicoG (Grupo Cíclico: constructorRef ↔ driverRef)

**Expresión 1: Contar Set Analisis**
```qlik
Count({<campo={1}> positionOrder)
```
- **Propósito:** Cuenta condicional con filtro Set Analysis (campo=1)
- **Uso:** Visualización de distribución filtrada

**Expresión 2: Suma**
```qlik
Sum(positionOrder)
```
- **Propósito:** Suma total de posiciones ordenadas
- **Campo:** positionOrder (Tabla: Resultados)

---

#### LB01 - Cuadro de Lista "constructorRef"
**Tipo:** Cuadro de Lista (Filtro)  
**Campo:** constructorRef  
**Origen:** Tabla constructor
- **Cardinal:** 211 valores únicos
- **Uso:** Selector de constructor para filtrado interactivo

---

## 🎯 APLICACIÓN 2: 1.qvw

### Página: Principal (SH01)

#### CH01 - Tabla Pivotante "Tabla"
**Dimensión:** CiclicoG (Grupo Cíclico)

**Expresión 1: Contar Set Analisis**
```qlik
Count({<campo={1}> positionOrder)
```
**Expresión 2: Suma**
```qlik
Sum(positionOrder)
```

---

#### CH02 - Gráfico Mekko "Contar Set Analisis"
**Dimensión:** CiclicoG

**Expresión 1: Contar Set Analisis**
```qlik
Count({<campo={1}> positionOrder)
```
**Expresión 2: Suma**
```qlik
Sum(positionOrder)
```

---

#### CH03 - Tabla Pivotante "Tabla"
**Dimensión:** JerarquicoG (Grupo Jerárquico: constructorRef → driverRef)

**Expresión 1: Contar Set Analisis**
```qlik
Count({<campo={1}> positionOrder)
```
- **Propósito:** Cuenta condicional con jerarquía constructor → driver

**Expresión 2: Suma**
```qlik
Sum(positionOrder)
```
- **Propósito:** Suma agregada por jerarquía

---

## 🎯 APLICACIÓN 3: F1 - Prueba01.qvw

### Página: Pantalla 1 (Panta1)

#### CH02 - Tabla Pivotante "Tabla Pivotante Grupo Ciclico"
**Tipo:** Tabla Simple  
**Dimensión:** Grupo_Ciclico (constructorRef ↔ driverRef)

*Expresiones heredadas de configuración similar a CH01*

---

#### CH03 - Tabla Pivotante "Tabla Pivotante Jerarquico"
**Tipo:** Tabla Pivotante  
**Dimensión:** Grupo_Jerarquico (constructorRef → driverRef)

*Expresiones similares con análisis jerárquico*

---

#### CH04 - Gráfico de Barras "Grafico de barras"
**Tipo:** Gráfico de Barras

*Expresiones no documentadas explícitamente en metadata XML - Requiere revisión manual*

---

#### CH06 - Gráfico Combinado "Grafico combinado"
**Tipo:** Gráfico Combinado  
**Dimensión:** Grupo_Jerarquico

**Expresión:** *Pendiente documentación de archivo source*

---

#### CH07 - Gráfico Indicador "Grafico indicador"
**Tipo:** Gráfico de Indicador  
**Dimensión:** Grupo_Jerarquico

**Expresión 1: Suma**
```qlik
Sum(points)
```
- **Propósito:** Suma total de puntos obtenidos
- **Campo:** points (Tabla: Resultados)
- **Cardinal:** 39 valores distintos

**Expresión 2: Count Set Analisis**
```qlik
Count({<campo={1}> positionOrder)
```
- **Propósito:** Cuenta condicional filtrada

**Expresión 3: % Expression**
```qlik
sum((points-positionOrder)/positionOrder)
```
- **Propósito:** Cálculo de porcentaje basado en diferencia relativa
- **Formula:** ((puntos - posición) / posición) agregado
- **Uso:** Indicador de rendimiento relativo

---

### Página: Pantalla 2 (SH02)

#### CH05 - Gráfico de Líneas "Grafico de lineas"
**Tipo:** Gráfico de líneas

*Expresiones no disponibles en metadata - Se require inspección manual del archivo QVW*

---

#### CH08 - Gráfico de Tarta "Grafico de tarta"
**Tipo:** Gráfico de Tarta  
**Dimensión:** nationalityCostructor

**Expresión: Promedio de Posición**
```qlik
Avg(position)
```
- **Propósito:** Promedio de posiciones por nacionalidad de constructor
- **Campo:** position (Tabla: Resultados)
- **Cardinal:** 34 posiciones distintas
- **Uso:** Comparativa de rendimiento por nacionalidad

---

#### CH09 - Gráfico (Tipo no especificado)
**Dimensión:** nationalityCostructor

**Expresión:**
```qlik
Avg(position)
```
- **Propósito:** Promedio de posiciones

---

#### CH11 - Gráfico (Tipo no especificado)
**Dimensión:** constructorRef

**Expresión 1: position**
```qlik
Avg(position)
```
- **Propósito:** Posición promedio por constructor

**Expresión 2: points**
```qlik
Sum([points])
```
- **Propósito:** Puntos totales por constructor
- **Nota:** Uso de corchetes para evitar conflictos de nombres

---

#### CH13 - Gráfico (Tipo no especificado)
**Dimensiones:** constructorRef, forename

**Expresión 1: position**
```qlik
Avg(position)
```
- **Propósito:** Posición promedio por constructor y piloto

**Expresión 2: points**
```qlik
Sum([points])
```
- **Propósito:** Puntos totales por combinación constructor-piloto
- **Uso:** Análisis de rendimiento específico de pilotos por equipo

---

#### CH14, CH15, CH16 - Gráficos (Tipos no especificados)
**Dimensión:** nationalityCostructor

**Expresión Común:**
```qlik
Avg(position)
```
- **Propósito:** Análisis de posición promedio por nacionalidad
- **Nota:** Múltiples gráficos con la misma métrica sugieren diferentes visualizaciones de la misma información

---

## 📈 Set Analysis - Patrón Detectado

### Patrón Principal: Filtrado por Campo "campo"
```qlik
{<campo={1}>}
```

**Frecuencia de Uso:** Todas las expresiones Count principales  
**Propósito:** Filtrar registros donde campo=1  

**⚠️ PROBLEMA IDENTIFICADO:**
El campo "campo" se utiliza extensivamente en Set Analysis, pero **NO aparece en la metadata de campos** de ninguna de las tablas (constructor, Resultados, Drivers).

**Posibles Explicaciones:**
1. Campo calculado en el script no documentado
2. Campo derivado de una transformación
3. Campo temporal usado para pruebas
4. Error en la extracción de metadata

**Acción Requerida:** Revisar el script de carga para identificar la definición y origen del campo "campo"

---

## 🔢 Campos Utilizados en Expresiones

### Campos Numéricos (Métricas)

| Campo | Tabla | Cardinality | Uso en Expresiones |
|-------|-------|-------------|-------------------|
| **positionOrder** | Resultados | 39 | Count(), Sum() |
| **points** | Resultados | 39 | Sum(), Cálculos % |
| **position** | Resultados | 34 | Avg() |

### Campos Dimensionales

| Campo | Tabla | Cardinality | Uso |
|-------|-------|-------------|-----|
| **constructorRef** | constructor | 211 | Dimensión, Grupos |
| **driverRef** | Drivers / Resultados | 857 / 60 | Dimensión, Grupos |
| **nationalityCostructor** | constructor | 24 | Dimensión en gráficos |
| **forename** | Drivers / Resultados | 476 / 55 | Dimensión combinada |

---

## 🔄 Grupos Dimensionales

### CiclicoG (Grupo Cíclico)
**Campos:** constructorRef ↔ driverRef  
**Tipo:** Cíclico (alternancia)  
**Uso:** Tablas CH01, CH02 (F1 codigo y objetos.qvw, 1.qvw)

### JerarquicoG / Grupo_Jerarquico
**Campos:** constructorRef → driverRef  
**Tipo:** Jerárquico (padre → hijo)  
**Uso:** Tablas CH03, gráficos CH06, CH07

### Grupo_Ciclico (Variante)
**Igual que CiclicoG** - Nomenclatura diferente en F1 - Prueba01.qvw

---

## 🎨 Tipos de Visualización y Sus Expresiones

| Tipo de Gráfico | Cantidad | Expresiones Típicas |
|-----------------|----------|---------------------|
| **Tabla Pivotante** | 5 | Count(), Sum() con Set Analysis |
| **Gráfico Mekko** | 2 | Count(), Sum() |
| **Gráfico de Barras** | 1 | *Por documentar* |
| **Gráfico de Líneas** | 1 | *Por documentar* |
| **Gráfico Combinado** | 1 | *Mixtas* |
| **Gráfico Indicador** | 1 | Sum(), Count(), % calculados |
| **Gráfico de Tarta** | 1 | Avg() |
| **Cuadro de Lista** | 1 | N/A (filtro) |
| **Sin Especificar** | 6 | Avg(), Sum() |

---

## 📝 Variables Detectadas

### Variables del Sistema (Reservadas)

```qlik
// Formato de Números
SET ThousandSep = '.';
SET DecimalSep = ',';
SET MoneyThousandSep = '.';
SET MoneyDecimalSep = ',';
SET MoneyFormat = '#.##0,00 €;-#.##0,00 €';

// Formato de Fechas y Tiempo
SET TimeFormat = 'h:mm:ss';
SET DateFormat = 'D/M/YYYY';
SET TimestampFormat = 'D/M/YYYY h:mm:ss[.fff]';

// Configuración Regional
SET FirstWeekDay = 0;
SET BrokenWeeks = 0;
SET ReferenceDay = 4;
SET FirstMonthOfYear = 1;
SET CollationLocale = 'es-ES';

// Nombres de Meses (Español)
SET MonthNames = 'ene;feb;mar;abr;may;jun;jul;ago;sept;oct;nov;dic';
SET LongMonthNames = 'enero;febrero;marzo;abril;mayo;junio;julio;agosto;septiembre;octubre;noviembre;diciembre';

// Nombres de Días (Español)
SET DayNames = 'lun;mar;mié;jue;vie;sáb;dom';
SET LongDayNames = 'lunes;martes;miércoles;jueves;viernes;sábado;domingo';

// Manejo de Errores
SET ErrorMode = '';
SET ScriptErrorCount = 0;
```

**Nota:** No se detectaron variables personalizadas (LET/SET custom) en la metadata extraída.

---

## ⚠️ Sección: REVISIÓN HUMANA REQUERIDA

### Problemas Identificados

#### 1. 🔴 **CRÍTICO: Campo "campo" no documentado**
- **Severidad:** Alta
- **Impacto:** Todas las expresiones Count con Set Analysis
- **Descripción:** El campo "campo" se usa en `{<campo={1}>}` pero no existe en la metadata de tablas
- **Acción:** Revisar script de carga para encontrar definición
- **Archivos Afectados:** Todos los QVW analizados

#### 2. 🟡 **MEDIO: Expresiones faltantes en CH05**
- **Severidad:** Media
- **Descripción:** El gráfico de líneas CH05 no tiene expresiones documentadas en la metadata XML
- **Acción:** Inspección manual del archivo QVW o screenshot

#### 3. 🟡 **MEDIO: Tipos de gráfico no especificados**
- **Objetos Afectados:** CH09, CH11, CH13, CH14, CH15, CH16
- **Descripción:** La metadata no especifica el tipo exacto de visualización
- **Acción:** Abrir archivo QVW para identificar tipos

#### 4. 🟢 **BAJO: Inconsistencia de nomenclatura**
- **Descripción:** "JerarquicoG" vs "Grupo_Jerarquico"
- **Impacto:** Confusión en documentación
- **Recomendación:** Estandarizar nombres de grupos

#### 5. 🟢 **BAJO: Objetos Button sin acciones documentadas**
- **Objetos:** BU01, BU02, BU03 (Pantalla 2)
- **Descripción:** Metadata no incluye las acciones asignadas a botones
- **Acción:** Revisar propiedades de botones en QVW

---

## 📚 Guía de Migración a Power BI

### Equivalencias de Expresiones

| QlikView | Power BI DAX | Notas |
|----------|--------------|-------|
| `Count({<campo={1}>} positionOrder)` | `CALCULATE(COUNT(Resultados[positionOrder]), campo[campo]=1)` | Requiere tabla/columna campo |
| `Sum(positionOrder)` | `SUM(Resultados[positionOrder])` | Directa |
| `Avg(position)` | `AVERAGE(Resultados[position])` | Directa |
| `Sum([points])` | `SUM(Resultados[points])` | Directa |
| `sum((points-positionOrder)/positionOrder)` | `SUMX(Resultados, (Resultados[points]-Resultados[positionOrder])/Resultados[positionOrder])` | SUMX para cálculo fila a fila |

### Set Analysis → CALCULATE

**Patrón QlikView:**
```qlik
Count({<campo={1}>} positionOrder)
```

**Equivalente Power BI:**
```dax
Cuenta_Filtrada = 
CALCULATE(
    COUNT(Resultados[positionOrder]),
    campo[campo] = 1
)
```

**⚠️ Prerequisito:** Identificar y crear la columna/tabla "campo" en el modelo de datos de Power BI

---

## 🎯 Recomendaciones

### Para la Migración
1. **Resolver campo "campo":** Prioridad máxima antes de migrar
2. **Estandarizar grupos:** Unificar nomenclatura CiclicoG/Grupo_Ciclico
3. **Documentar CH05:** Obtener expresiones faltantes del gráfico de líneas
4. **Crear medidas DAX:** Convertir cada expresión QlikView en medida DAX reutilizable
5. **Validar cálculos %:** Probar la fórmula `(points-positionOrder)/positionOrder` en Power BI

### Para el Modelo de Datos
1. **Mantener jerarquías:** Constructor → Driver es una relación natural
2. **Calendario:** Considerar agregar tabla Calendar (no existe actualmente)
3. **Tabla Status:** Crear dimensión para statusId (actualmente solo FK)
4. **Optimizar campos:** positionOrder tiene ByteSize=0 en algunos casos (revisar)

---

## 📅 Metadata de Documento

**Versión:** 1.0  
**Generado por:** Agente de Extracción de Metadata Qlik  
**Fecha:** 2026-05-05  
**Proyecto:** F1 Histórico - Migración Aqualia QlikView → Power BI  
**Aplicaciones Fuente:**
- F1 codigo y objetos.qvw (688,384 bytes)
- 1.qvw
- F1 - Prueba01.qvw

**Última Ejecución QVW:** 2026-04-21 17:19:52 UTC

---

**FIN DEL DOCUMENTO**
