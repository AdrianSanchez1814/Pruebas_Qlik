# Expresiones y Fórmulas - F1 codigo y objetos

## Información General
- **Aplicación**: F1 codigo y objetos
- **Fecha de análisis**: 2026-05-05
- **Última recarga**: 2026-04-21 17:19:52 UTC

---

## Página: Principal (SH01)

### Objetos en la página:
- CH01 - Tabla Pivotante
- LB01 - Cuadro de Lista (constructorRef)
- CH02 - Gráfico Mekko

---

### CH01 - Tabla Pivotante

#### Dimensiones:
- **CiclicoG** (Grupo Cíclico)
  - Campos: constructorRef, driverRef
  - Tipo: Grupo alternante entre constructorRef y driverRef

#### Expresiones:

**1. Contar Set Analisis**
```qlik
Count({<campo={1}> } positionOrder)
```
- **Propósito**: Cuenta los registros de positionOrder donde campo = 1
- **Tipo**: Set Analysis con filtro
- **Uso**: KPI de conteo condicional

**2. Suma**
```qlik
Sum(positionOrder)
```
- **Propósito**: Suma total del campo positionOrder
- **Tipo**: Agregación simple
- **Uso**: Medida de totales

---

### CH02 - Gráfico Mekko (Contar Set Analisis)

#### Dimensiones:
- **CiclicoG** (Grupo Cíclico)
  - Campos: constructorRef, driverRef

#### Expresiones:

**1. Contar Set Analisis**
```qlik
Count({<campo={1}> } positionOrder)
```
- **Propósito**: Cuenta los registros de positionOrder donde campo = 1
- **Tipo**: Set Analysis con filtro
- **Uso**: Métrica principal del gráfico Mekko

**2. Suma**
```qlik
Sum(positionOrder)
```
- **Propósito**: Suma total del campo positionOrder
- **Tipo**: Agregación simple
- **Uso**: Medida secundaria para comparación

---

## CH03 - Tabla Pivotante Jerarquica (de archivo 1.qvw)

#### Dimensiones:
- **JerarquicoG** (Grupo Jerárquico)
  - Campos: constructorRef, driverRef
  - Tipo: Drill-down jerárquico

#### Expresiones:

**1. Contar Set Analisis**
```qlik
Count({<campo={1}> } positionOrder)
```
- **Propósito**: Cuenta condicional con Set Analysis
- **Uso**: Análisis por nivel jerárquico

**2. Suma**
```qlik
Sum(positionOrder)
```
- **Propósito**: Agregación de posiciones
- **Uso**: Totales por nivel de jerarquía

---

## Expresiones de F1 - Prueba01.qvw

### Gráfico de barras (CH04)

#### Dimensiones:
- Grupo_Ciclico

#### Expresiones:

**1. Suma de points**
```qlik
Sum(points)
```
- **Propósito**: Total de puntos obtenidos
- **Tipo**: Agregación simple

**2. Count Set Analysis**
```qlik
Count({<campo={1}> } positionOrder)
```
- **Propósito**: Conteo condicional de posiciones

**3. Expresión porcentual**
```qlik
sum((points-positionOrder)/positionOrder)
```
- **Propósito**: Cálculo de variación porcentual entre points y positionOrder
- **Tipo**: Fórmula calculada compleja

---

### Gráfico de líneas (CH05)

#### Dimensiones:
- nationalityCostructor

#### Expresiones:

**1. Promedio de position**
```qlik
Avg(position)
```
- **Propósito**: Posición promedio por nacionalidad
- **Tipo**: Agregación de promedio

---

### Gráfico combinado (CH06)

#### Dimensiones:
- Grupo_Jerarquico

#### Expresiones:

**1. Suma de points**
```qlik
Sum(points)
```

**2. Count Set Analysis**
```qlik
Count({<campo={1}> } positionOrder)
```

**3. % Expresión**
```qlik
sum((points-positionOrder)/positionOrder)
```
- **Propósito**: Porcentaje de variación entre métricas

---

### Gráfico indicador (CH07)

#### Dimensiones:
- Grupo_Jerarquico

#### Expresiones:

**1. Suma**
```qlik
Sum(points)
```

**2. Count Set Analysis**
```qlik
Count({<campo={1}> } positionOrder)
```

**3. % Expression**
```qlik
sum((points-positionOrder)/positionOrder)
```

---

### Gráficos de tarta (CH08, CH09, CH14, CH15, CH16)

#### Dimensión común:
- nationalityCostructor

#### Expresión:

**Promedio de position**
```qlik
Avg(position)
```
- **Propósito**: Posición promedio por nacionalidad de constructor
- **Uso**: Comparación de rendimiento por país

---

### Gráficos combinados (CH11, CH13)

#### CH11 - Dimensión:
- constructorRef

#### CH13 - Dimensiones:
- constructorRef
- forename

#### Expresiones:

**1. position**
```qlik
Avg(position)
```
- **Label**: position
- **Propósito**: Posición promedio

**2. points**
```qlik
Sum([points])
```
- **Label**: points
- **Propósito**: Total de puntos

---

## Análisis de Set Analysis

### Patrones identificados:

**1. Filtro condicional básico:**
```qlik
{<campo={1}> }
```
- **Uso**: Filtrar registros donde campo = 1
- **Frecuencia**: Alta (usado en múltiples objetos)
- **Propósito**: Segmentación de datos

**2. Fórmulas de variación:**
```qlik
(points-positionOrder)/positionOrder
```
- **Uso**: Calcular diferencia porcentual
- **Interpretación**: Mide la relación entre puntos obtenidos y posición final

---

## Grupos de Dimensiones

### CiclicoG (Grupo Cíclico)
- **Campos**: constructorRef, driverRef
- **Comportamiento**: Permite alternar entre las dos dimensiones
- **Objetos que lo usan**: CH01, CH02, CH04

### JerarquicoG / Grupo_Jerarquico (Grupo Jerárquico)
- **Campos**: constructorRef, driverRef
- **Comportamiento**: Drill-down de constructor a driver
- **Objetos que lo usan**: CH03, CH06, CH07

### Grupo_Ciclico
- **Similar a**: CiclicoG
- **Uso**: Análisis alternativo en CH04

---

## Campos Calculados y Variables

No se encontraron campos calculados definidos en el script (solo variables de sistema reservadas).

---

## Recomendaciones para Power BI

### 1. Conversión de Set Analysis:
```qlik
Count({<campo={1}> } positionOrder)
```
**En Power BI (DAX):**
```dax
Contar Set Analysis = 
CALCULATE(
    COUNT(Resultados[positionOrder]),
    Resultados[campo] = 1
)
```

### 2. Fórmula de variación porcentual:
```qlik
sum((points-positionOrder)/positionOrder)
```
**En Power BI (DAX):**
```dax
Variación % = 
SUMX(
    Resultados,
    (Resultados[points] - Resultados[positionOrder]) / Resultados[positionOrder]
)
```

### 3. Grupos Cíclicos:
- Los grupos cíclicos de Qlik deben convertirse en **botones de selección** o **segmentadores** en Power BI
- Crear medidas separadas para cada combinación de dimensión

### 4. Grupos Jerárquicos:
- Implementar mediante **jerarquías nativas** en el modelo de datos
- Ejemplo: Constructor > Driver

---

## Resumen de Medidas

| Medida | Fórmula Qlik | Frecuencia | Complejidad |
|--------|--------------|------------|-------------|
| Count Set Analysis | Count({<campo={1}>} positionOrder) | Alta | Media |
| Suma positionOrder | Sum(positionOrder) | Alta | Baja |
| Suma points | Sum(points) | Media | Baja |
| Promedio position | Avg(position) | Media | Baja |
| Variación % | sum((points-positionOrder)/positionOrder) | Baja | Alta |

---

## Human review required

### Preguntas abiertas:
1. **Campo "campo" en Set Analysis**: ¿Cuál es la definición y propósito del campo "campo" usado en `{<campo={1}>}`? No se encuentra en el modelo de datos explícitamente.

2. **Interpretación de la variación porcentual**: La fórmula `(points-positionOrder)/positionOrder` necesita validación de negocio. ¿Es correcta esta interpretación?

3. **Datos faltantes**: Los archivos QVW binarios no permitieron extraer el script completo. Se recomienda acceso al código fuente (.qvs) o a la aplicación abierta en QlikView para validación completa.

4. **Grupos cíclicos en Power BI**: Definir el comportamiento esperado de los grupos cíclicos en la migración (¿botones, segmentadores, o bookmarks?).
