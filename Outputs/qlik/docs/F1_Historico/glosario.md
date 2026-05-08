# Glosario de Datos - F1 Histórico

## Índice
1. [Tabla: constructor](#tabla-constructor)
2. [Tabla: Resultados](#tabla-resultados)
3. [Tabla: Drivers](#tabla-drivers)
4. [Grupos Dimensionales](#grupos-dimensionales)
5. [Campos del Sistema](#campos-del-sistema)

---

## Tabla: constructor

**Descripción**: Tabla dimensional que contiene información de los constructores/equipos de Fórmula 1 a lo largo de la historia.

**Características**:
- **Número de registros**: 211
- **Número de campos**: 4
- **Tamaño**: 844 bytes
- **Tipo**: Dimensión
- **Clave primaria**: constructorId

### Campos de la Tabla constructor

| # | Nombre del Campo | Tipo de Dato | Cardinalidad | Descripción | Es Clave | Tags | Valores Nulos |
|---|------------------|--------------|--------------|-------------|----------|------|---------------|
| 1 | **constructorId** | Numeric (Integer) | 211 | Identificador único del constructor. Clave primaria de la tabla. | ✅ PK | $key, $numeric, $integer | No |
| 2 | **constructorRef** | Text (ASCII) | 211 | Referencia corta o código del constructor (ej: "ferrari", "mclaren"). Usado para identificación legible. | No | $ascii, $text | No |
| 3 | **name** | Text (ASCII) | 211 | Nombre completo del constructor/equipo (ej: "Scuderia Ferrari", "McLaren"). | No | $ascii, $text | No |
| 4 | **nationalityCostructor** | Text (ASCII) | 24 | Nacionalidad del constructor (ej: "Italian", "British"). Solo 24 nacionalidades diferentes. | No | $ascii, $text | No |

### Detalle de Campos - constructor

#### constructorId
- **Propósito**: Identificador único numérico para cada constructor
- **Uso**: Campo clave para relacionar con la tabla Resultados
- **Rango de valores**: 1 - 211
- **Observaciones**: Todos los valores son únicos (211 valores distintos)

#### constructorRef
- **Propósito**: Código de referencia textual del constructor
- **Uso**: Facilita la identificación humana del equipo
- **Ejemplos de valores**: "ferrari", "mclaren", "mercedes", "red_bull"
- **Formato**: Texto en minúsculas, palabras separadas por guion bajo
- **Observaciones**: Más legible que el ID numérico, útil en visualizaciones

#### name
- **Propósito**: Nombre oficial completo del constructor
- **Uso**: Etiquetas en reportes y visualizaciones
- **Ejemplos de valores**: "Scuderia Ferrari", "McLaren Racing", "Mercedes-AMG Petronas"
- **Formato**: Texto con mayúsculas y caracteres especiales
- **Observaciones**: 211 nombres únicos, algunos equipos históricos ya no existen

#### nationalityCostructor
- **Propósito**: País de origen o nacionalidad del constructor
- **Uso**: Análisis geográfico, segmentación por país
- **Ejemplos de valores**: "Italian", "British", "German", "French"
- **Cardinalidad**: 24 nacionalidades únicas
- **Distribución**: Reino Unido e Italia tienen la mayor cantidad de constructores
- **Observaciones**: Campo renombrado de "nationality" para evitar conflicto con Drivers

---

## Tabla: Resultados

**Descripción**: Tabla de hechos principal que contiene todos los resultados de las carreras de Fórmula 1, incluyendo estadísticas detalladas de rendimiento de cada piloto en cada carrera.

**Características**:
- **Número de registros**: 26,080
- **Número de campos**: 24
- **Tamaño**: 652,126 bytes
- **Tipo**: Hechos (Fact Table)
- **Claves foráneas**: constructorId, driverId

### Campos de la Tabla Resultados

| # | Nombre del Campo | Tipo de Dato | Cardinalidad | Descripción | Es Clave | Tags | Valores Nulos |
|---|------------------|--------------|--------------|-------------|----------|------|---------------|
| 1 | **resultId** | Numeric (Integer) | 26,080 | Identificador único del resultado | No | $numeric, $integer | No |
| 2 | **raceId** | Numeric (Integer) | 1,091 | Identificador de la carrera | No | $numeric, $integer | No |
| 3 | **driverId** | Numeric (Integer) | 857 | Identificador del piloto | ✅ FK | $key, $numeric, $integer | No |
| 4 | **constructorId** | Numeric (Integer) | 211 | Identificador del constructor | ✅ FK | $key, $numeric, $integer | No |
| 5 | **number** | Numeric | 130 | Número del auto en la carrera | No | - | Posible |
| 6 | **grid** | Numeric (Integer) | 35 | Posición de salida en la parrilla | No | $numeric, $integer | Posible |
| 7 | **position** | Numeric | 34 | Posición final de llegada | No | - | Sí (DNF) |
| 8 | **positionText** | Numeric | 39 | Posición como texto | No | - | Posible |
| 9 | **positionOrder** | Numeric (Integer) | 39 | Orden de posición para clasificación | No | $numeric, $integer | No |
| 10 | **points** | Numeric | 39 | Puntos obtenidos en la carrera | No | - | No |
| 11 | **laps** | Numeric (Integer) | 172 | Número de vueltas completadas | No | $numeric, $integer | No |
| 12 | **time** | Text | 7,000 | Tiempo total de carrera | No | - | Sí (DNF) |
| 13 | **milliseconds** | Numeric | 7,213 | Tiempo en milisegundos | No | - | Sí (DNF) |
| 14 | **fastestLap** | Numeric | 80 | Número de vuelta más rápida | No | - | Posible |
| 15 | **rank** | Numeric | 26 | Ranking de vuelta rápida | No | - | Posible |
| 16 | **fastestLapTime** | Text (ASCII) | 6,970 | Tiempo de vuelta más rápida | No | $ascii, $text | Sí |
| 17 | **fastestLapSpeed** | Numeric | 7,145 | Velocidad de vuelta más rápida | No | - | Sí |
| 18 | **statusId** | Numeric (Integer) | 137 | Estado de finalización | No | $numeric, $integer | No |

### Detalle de Campos - Resultados

#### resultId
- **Propósito**: Identificador único de cada registro de resultado
- **Uso**: Clave técnica para identificación única de cada participación
- **Rango**: 1 - 26,080
- **Observaciones**: Cada fila representa la participación de un piloto en una carrera específica

#### raceId
- **Propósito**: Identificador de la carrera
- **Uso**: Agrupa todos los resultados de una misma carrera
- **Cardinalidad**: 1,091 carreras únicas en el histórico
- **Observaciones**: Múltiples resultados (pilotos) por cada carrera

#### driverId
- **Propósito**: Identificador del piloto que participó
- **Uso**: Clave foránea hacia tabla Drivers
- **Cardinalidad**: 857 pilotos únicos
- **Observaciones**: Un piloto puede aparecer en múltiples carreras
- **Relación**: N:1 con tabla Drivers

#### constructorId
- **Propósito**: Identificador del constructor/equipo
- **Uso**: Clave foránea hacia tabla constructor
- **Cardinalidad**: 211 constructores únicos
- **Observaciones**: Un constructor puede tener múltiples resultados
- **Relación**: N:1 con tabla constructor

#### number
- **Propósito**: Número del auto asignado al piloto en esa carrera
- **Uso**: Identificación visual del vehículo
- **Cardinalidad**: 130 números diferentes
- **Rango típico**: 1-99
- **Observaciones**: Los números pueden reutilizarse en diferentes carreras/épocas

#### grid
- **Propósito**: Posición de salida en la parrilla de salida
- **Uso**: Análisis de rendimiento (comparar posición inicial vs final)
- **Cardinalidad**: 35 posiciones diferentes
- **Rango**: 1-35 (varía según época y número de participantes)
- **Valores especiales**: 0 puede indicar pit lane start
- **Observaciones**: Determinada por resultados de clasificación

#### position
- **Propósito**: Posición final al terminar la carrera
- **Uso**: Métricas de rendimiento, clasificación final
- **Cardinalidad**: 34 posiciones diferentes
- **Valores NULL**: Indica que el piloto no terminó (DNF - Did Not Finish)
- **Rango**: 1-34 (primer lugar a última posición)
- **Observaciones**: Campo crítico para análisis de rendimiento

#### positionText
- **Propósito**: Representación textual de la posición final
- **Uso**: Manejo de casos especiales (DNF, DSQ, etc.)
- **Cardinalidad**: 39 valores únicos
- **Valores especiales**: "R" (Retired), "D" (Disqualified), "W" (Withdrawn)
- **Observaciones**: Más descriptivo que position para casos de no finalización

#### positionOrder
- **Propósito**: Orden numérico para clasificación consistente
- **Uso**: Ordenamiento en visualizaciones, cálculos
- **Cardinalidad**: 39 valores
- **Observaciones**: Siempre tiene valor, incluso cuando position es NULL

#### points
- **Propósito**: Puntos de campeonato obtenidos
- **Uso**: Cálculos de standings, análisis de campeonato
- **Cardinalidad**: 39 valores diferentes
- **Sistema de puntos**: Varía según época (actual: 25-18-15-12-10-8-6-4-2-1)
- **Observaciones**: 0 puntos para posiciones fuera del top 10 (sistema actual)

#### laps
- **Propósito**: Número total de vueltas completadas
- **Uso**: Análisis de confiabilidad, comparación con total de carrera
- **Cardinalidad**: 172 valores diferentes
- **Rango**: 0 - ~78 vueltas (varía por circuito)
- **Observaciones**: Menos vueltas que el líder indica retiro o vuelta doblada

#### time
- **Propósito**: Tiempo total de carrera en formato legible
- **Uso**: Visualización de tiempos, análisis de ritmo
- **Cardinalidad**: ~7,000 valores únicos
- **Formato**: "HH:MM:SS.mmm" (ej: "1:34:50.616")
- **Valores NULL**: Pilotos que no terminaron la carrera
- **Observaciones**: Solo el ganador tiene tiempo absoluto, otros tienen diferencia

#### milliseconds
- **Propósito**: Tiempo total en milisegundos
- **Uso**: Cálculos precisos, comparaciones numéricas
- **Cardinalidad**: 7,213 valores únicos
- **Tipo**: Numeric (permite cálculos matemáticos)
- **Valores NULL**: DNF o sin tiempo registrado
- **Observaciones**: Más preciso que el campo "time" para análisis

#### fastestLap
- **Propósito**: Número de la vuelta en que se logró el mejor tiempo
- **Uso**: Análisis de ritmo de carrera
- **Cardinalidad**: 80 valores diferentes
- **Rango**: 1 - 78 (varía por longitud de carrera)
- **Valores NULL**: No todos los pilotos tienen vuelta rápida registrada

#### rank
- **Propósito**: Ranking/posición de la vuelta más rápida
- **Uso**: Punto adicional para vuelta rápida más rápida (regla reciente)
- **Cardinalidad**: 26 valores
- **Rango**: 1-26
- **Observaciones**: 1 = vuelta más rápida de la carrera

#### fastestLapTime
- **Propósito**: Tiempo de la vuelta más rápida
- **Uso**: Análisis de ritmo, comparaciones
- **Cardinalidad**: 6,970 valores únicos
- **Formato**: "M:SS.mmm" (ej: "1:23.456")
- **Tipo**: Text (ASCII)
- **Valores NULL**: Pilotos sin vuelta rápida válida

#### fastestLapSpeed
- **Propósito**: Velocidad promedio en la vuelta más rápida
- **Uso**: Comparación de rendimiento entre circuitos/épocas
- **Cardinalidad**: 7,145 valores únicos
- **Unidad**: Km/h
- **Rango típico**: 150 - 260 km/h (varía por circuito)
- **Valores NULL**: Datos no disponibles para algunas carreras históricas

#### statusId
- **Propósito**: Código de estado de finalización
- **Uso**: Clasificación del resultado (terminó, retirado, descalificado, etc.)
- **Cardinalidad**: 137 códigos diferentes
- **Valores comunes**:
  - 1: Finished (terminó normalmente)
  - 2-137: Diversas razones de retiro (motor, accidente, etc.)
- **Observaciones**: Útil para análisis de confiabilidad

---

## Tabla: Drivers

**Descripción**: Tabla dimensional con información biográfica y de identificación de todos los pilotos de Fórmula 1 en el histórico.

**Características**:
- **Número de registros**: 857
- **Número de campos**: 8
- **Tamaño**: 7,340 bytes
- **Tipo**: Dimensión
- **Clave primaria**: driverId

### Campos de la Tabla Drivers

| # | Nombre del Campo | Tipo de Dato | Cardinalidad | Descripción | Es Clave | Tags | Valores Nulos |
|---|------------------|--------------|--------------|-------------|----------|------|---------------|
| 1 | **driverId** | Numeric (Integer) | 857 | Identificador único del piloto | ✅ PK | $key, $numeric, $integer | No |
| 2 | **driverRef** | Text (ASCII) | 857 | Referencia corta del piloto | No | $ascii, $text | No |
| 3 | **number_driver** | Numeric | 45 | Número permanente del piloto | No | - | Posible |
| 4 | **code** | Text (ASCII) | 95 | Código de tres letras del piloto | No | $ascii, $text | Posible |
| 5 | **forename** | Text | 476 | Nombre del piloto | No | $text | No |
| 6 | **surname** | Text | 798 | Apellido del piloto | No | $text | No |
| 7 | **dob** | Numeric (Date) | 839 | Fecha de nacimiento | No | - | Posible |
| 8 | **nationalityDriver** | Text (ASCII) | 42 | Nacionalidad del piloto | No | $ascii, $text | No |

### Detalle de Campos - Drivers

#### driverId
- **Propósito**: Identificador único numérico para cada piloto
- **Uso**: Clave primaria, relación con tabla Resultados
- **Rango**: 1 - 857
- **Observaciones**: Cada piloto tiene un ID único e inmutable

#### driverRef
- **Propósito**: Código de referencia textual del piloto
- **Uso**: Identificación legible en URLs, referencias
- **Cardinalidad**: 857 (uno por piloto)
- **Formato**: Texto en minúsculas, formato "apellido" o "nombre_apellido"
- **Ejemplos**: "hamilton", "alonso", "michael_schumacher"
- **Observaciones**: Útil para búsquedas y referencias externas

#### number_driver
- **Propósito**: Número permanente del piloto (sistema post-2014)
- **Uso**: Identificación visual del piloto
- **Cardinalidad**: 45 números únicos
- **Rango**: 1-99 (algunos números reservados)
- **Valores NULL**: Pilotos de épocas anteriores al sistema de números permanentes
- **Observaciones**: 
  - Campo renombrado de "number" para evitar conflicto con Resultados.number
  - Sistema implementado desde 2014
  - Algunos números icónicos: 44 (Hamilton), 5 (Vettel), 33 (Verstappen)

#### code
- **Propósito**: Código de tres letras del piloto
- **Uso**: Identificación en gráficos oficiales de F1
- **Cardinalidad**: 95 códigos únicos
- **Formato**: 3 letras mayúsculas (ej: "HAM", "ALO", "VER")
- **Valores NULL**: Pilotos históricos previos a este sistema
- **Observaciones**: Sistema relativamente reciente (post-2000)

#### forename
- **Propósito**: Primer nombre del piloto
- **Uso**: Presentación en reportes, análisis
- **Cardinalidad**: 476 nombres diferentes
- **Formato**: Texto con mayúsculas y caracteres internacionales
- **Ejemplos**: "Lewis", "Fernando", "Michael"
- **Observaciones**: Soporta caracteres especiales de diferentes idiomas

#### surname
- **Propósito**: Apellido del piloto
- **Uso**: Identificación principal, ordenamiento
- **Cardinalidad**: 798 apellidos únicos
- **Formato**: Texto con mayúsculas y caracteres internacionales
- **Ejemplos**: "Hamilton", "Alonso", "Schumacher"
- **Observaciones**: Mayor cardinalidad que forename (apellidos más diversos)

#### dob
- **Propósito**: Fecha de nacimiento del piloto
- **Uso**: Cálculo de edad, análisis demográfico
- **Cardinalidad**: 839 fechas únicas
- **Formato**: Fecha (probablemente en formato numérico QlikView)
- **Tipo**: Numeric (representación interna de fecha)
- **Valores NULL**: Posibles para pilotos históricos sin datos
- **Observaciones**: Útil para análisis de edad en debut, longevidad de carrera

#### nationalityDriver
- **Propósito**: País de nacionalidad del piloto
- **Uso**: Análisis geográfico, estadísticas por país
- **Cardinalidad**: 42 nacionalidades únicas
- **Formato**: Texto en inglés (ej: "British", "Spanish", "German")
- **Distribución**: Reino Unido, Italia y Francia tienen más pilotos históricamente
- **Observaciones**: 
  - Campo renombrado de "nationality" para evitar conflicto con constructor
  - Refleja diversidad global del deporte

---

## Grupos Dimensionales

### Grupo 1: CiclicoG (Grupo Cíclico)

**Descripción**: Grupo dimensional que permite alternar entre las dimensiones de constructor y piloto.

**Tipo**: Cíclico (Cyclic Group)

**Campos del grupo**:
1. constructorRef
2. driverRef

**Propósito y Uso**:
- Permite al usuario cambiar dinámicamente entre ver datos por constructor o por piloto
- Útil en gráficos donde se quiere analizar desde diferentes perspectivas
- El usuario puede hacer clic en el título de la dimensión para alternar

**Ejemplo de aplicación**:
- Un gráfico de puntos que puede mostrar:
  - Opción 1: Puntos por constructor (ej: Ferrari, Mercedes)
  - Opción 2: Puntos por piloto (ej: Hamilton, Alonso)

### Grupo 2: JerarquicoG (Grupo Jerárquico)

**Descripción**: Grupo dimensional que proporciona navegación drill-down de constructor a piloto.

**Tipo**: Jerárquico (Hierarchical Group)

**Jerarquía** (en orden):
1. **Nivel 1**: constructorRef (nivel superior)
2. **Nivel 2**: driverRef (nivel detalle)

**Propósito y Uso**:
- Navegación drill-down: empezar viendo por constructor, luego expandir para ver pilotos
- Ideal para tablas pivotantes y gráficos de árbol
- Permite análisis de varios niveles de granularidad

**Ejemplo de aplicación**:
- Tabla pivotante que muestra:
  - Nivel 1: Resultados agregados por constructor (ej: Ferrari: 500 puntos)
  - Nivel 2 (expandido): Desglose por piloto (ej: Leclerc: 300 puntos, Sainz: 200 puntos)

---

## Campos del Sistema

### Campos de Metadatos QlikView

Estos son campos del sistema generados automáticamente por QlikView para gestionar la metadata del modelo:

| Campo | Descripción | Uso |
|-------|-------------|-----|
| **$Field** | Lista todos los nombres de campos en el modelo | Metadata interna |
| **$Table** | Lista todos los nombres de tablas en el modelo | Metadata interna |
| **$Rows** | Número de filas por tabla | Estadísticas |
| **$Fields** | Número de campos por tabla | Estadísticas |
| **$FieldNo** | Número interno de cada campo | Referencia técnica |
| **$Info** | Información adicional del campo | Metadata |

**Observaciones**: Estos campos están ocultos y marcados como $system, no aparecen en listas de selección normales.

---

## Variables del Sistema

### Variables de Configuración

Estas variables controlan el comportamiento del script y formato de datos:

| Variable | Valor | Descripción |
|----------|-------|-------------|
| **ThousandSep** | . (punto) | Separador de miles |
| **DecimalSep** | , (coma) | Separador decimal |
| **MoneyFormat** | #.##0,00 € | Formato de moneda |
| **DateFormat** | D/M/YYYY | Formato de fecha |
| **TimeFormat** | h:mm:ss | Formato de hora |
| **TimestampFormat** | D/M/YYYY h:mm:ss[.fff] | Formato de fecha-hora |
| **FirstWeekDay** | 0 | Primer día de la semana (0=lunes) |
| **FirstMonthOfYear** | 1 | Primer mes del año (enero) |
| **CollationLocale** | es-ES | Configuración regional (español) |

### Variables de Control

| Variable | Descripción |
|----------|-------------|
| **ErrorMode** | Controla cómo se manejan errores en el script |
| **StripComments** | Elimina comentarios del código |
| **OpenUrlTimeout** | Timeout para conexiones URL |
| **ScriptError** | Almacena mensaje de último error |
| **ScriptErrorCount** | Contador de errores en script |
| **ScriptErrorList** | Lista de errores encontrados |

---

## Nomenclatura y Convenciones

### Convenciones de Nombres

1. **Identificadores**: 
   - Formato: `[entidad]Id` (ej: constructorId, driverId, raceId)
   - Tipo: Siempre numérico entero

2. **Referencias**: 
   - Formato: `[entidad]Ref` (ej: constructorRef, driverRef)
   - Tipo: Texto legible
   - Uso: Identificación humana

3. **Nombres de campos con sufijos**:
   - `_driver`: Indica que es específico de la entidad Driver (ej: number_driver)
   - `Driver` / `Constructor`: Sufijo para desambiguar campos similares (ej: nationalityDriver vs nationalityCostructor)

4. **Campos de nacionalidad**:
   - `nationalityCostructor`: Nacionalidad del constructor
   - `nationalityDriver`: Nacionalidad del piloto
   - Nota: Desambiguación necesaria para evitar conflictos

### Estándares de Calidad

1. **Integridad Referencial**:
   - Todos los `constructorId` en Resultados deben existir en constructor
   - Todos los `driverId` en Resultados deben existir en Drivers
   - ⚠️ No hay validaciones explícitas en el script

2. **Valores Nulos**:
   - Aceptables en campos opcionales (time, fastestLapTime, code, number_driver)
   - Indican datos no disponibles o no aplicables (ej: DNF)
   - Deben manejarse apropiadamente en cálculos

3. **Cardinalidad**:
   - Campos de alta cardinalidad (>1000): resultId, time, milliseconds
   - Campos de baja cardinalidad (<50): position, grid, nationality
   - Útil para optimización de memoria

---

## Resumen de Métricas

### Estadísticas Globales del Modelo

| Métrica | Valor |
|---------|-------|
| **Total de tablas** | 3 (+ 3 tablas de sistema) |
| **Total de campos** | 36 campos únicos |
| **Total de registros** | 27,148 |
| **Tamaño del modelo** | ~660 KB |
| **Constructores únicos** | 211 |
| **Pilotos únicos** | 857 |
| **Carreras en histórico** | 1,091 |
| **Resultados de carreras** | 26,080 |
| **Rango temporal estimado** | 1950 - 2026 |

### Distribución de Cardinalidad

| Rango de Cardinalidad | Número de Campos | Tipo de Campos |
|-----------------------|------------------|----------------|
| 1 - 50 | 12 | Dimensiones de baja cardinalidad (nacionalidad, position, grid) |
| 51 - 500 | 8 | Dimensiones medianas (forename, code, number) |
| 501 - 5,000 | 6 | Dimensiones altas (surname, driverRef, constructorRef) |
| 5,001+ | 10 | Hechos y medidas (resultId, time, milliseconds, raceId) |

---

## Notas Adicionales

### Consideraciones Técnicas

1. **Codificación de caracteres**: 
   - Soporta UTF-8 para nombres internacionales
   - Campos con tag $ascii solo contienen caracteres ASCII

2. **Tipos de datos**:
   - Numeric: Permite cálculos matemáticos
   - Numeric (Integer): Optimizado para enteros
   - Text (ASCII): Solo caracteres básicos
   - Text: Soporta Unicode

3. **Tags de QlikView**:
   - `$key`: Indica que es campo clave
   - `$numeric`: Valor numérico
   - `$integer`: Número entero
   - `$text`: Texto general
   - `$ascii`: Solo ASCII
   - `$system`: Campo del sistema
   - `$hidden`: No visible en interfaz

### Recomendaciones de Uso

1. **Para análisis de rendimiento**:
   - Usar: position, positionOrder, points, laps
   - Considerar: grid para comparar inicio vs final

2. **Para análisis temporal**:
   - Usar: time, milliseconds
   - Nota: Valores NULL indican DNF

3. **Para análisis de velocidad**:
   - Usar: fastestLap, fastestLapTime, fastestLapSpeed
   - Filtrar valores NULL

4. **Para segmentación**:
   - Por equipo: constructorRef, name, nationalityCostructor
   - Por piloto: driverRef, forename, surname, nationalityDriver
   - Por carrera: raceId

---

**Documento generado**: 2024  
**Última actualización**: 2024  
**Versión del modelo**: F1 Histórico v1.0  
**QlikView Build**: 50689

