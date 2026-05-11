# Glosario de Campos - F1 Histórico

## Información del Documento

**Proyecto**: F1 Histórico  
**Archivo**: F1 codigo y objetos.qvw  
**Propósito**: Documentación detallada de todos los campos del modelo de datos  
**Fecha de Generación**: 2024  
**Versión**: 1.0

---

## Tabla de Contenidos

1. [Tabla: constructor](#tabla-constructor)
2. [Tabla: Resultados](#tabla-resultados)
3. [Tabla: Drivers](#tabla-drivers)
4. [Campos Calculados](#campos-calculados)
5. [Grupos Dimensionales](#grupos-dimensionales)

---

## Tabla: constructor

**Descripción**: Tabla dimensional que contiene información de los constructores (escuderías) de Fórmula 1.

**Origen**: Formula1 - Historico.xlsx (hoja: constructor)  
**Registros**: 211  
**Tipo**: Dimensión  
**Rol**: Información maestra de constructores

### Campos de la Tabla constructor

#### 1. constructorId
- **Nombre Interno**: `constructorId`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Clave Primaria (Primary Key)
- **Cardinalidad**: 211 valores únicos
- **Total de Registros**: 211 (no incluye duplicados)
- **Es Clave**: ✅ Sí ($key)
- **Permite Nulos**: No
- **Descripción**: Identificador único del constructor. Este campo sirve como clave primaria de la tabla y se utiliza para relacionar la tabla constructor con la tabla de Resultados.
- **Uso**: Campo de relación principal con tabla de hechos Resultados
- **Etiquetas**: $key, $numeric, $integer
- **Tamaño en Memoria**: 1,688 bytes
- **Ejemplo de Valores**: 1, 2, 3... 211

#### 2. constructorRef
- **Nombre Interno**: `constructorRef`
- **Tipo de Dato**: Texto (ASCII)
- **Rol**: Dimensión de análisis
- **Cardinalidad**: 211 valores únicos
- **Total de Registros**: 211
- **Es Clave**: No
- **Descripción**: Código o referencia corta del constructor. Identificador legible y único usado en análisis y reportes.
- **Uso**: 
  - Campo principal para selección en filtros
  - Utilizado en grupos dimensionales (CiclicoG, JerarquicoG)
  - Mostrar en ejes de gráficos y tablas
- **Etiquetas**: $ascii, $text
- **Tamaño en Memoria**: 2,871 bytes
- **Ejemplo de Valores**: "mercedes", "ferrari", "red_bull", "mclaren"

#### 3. name
- **Nombre Interno**: `name`
- **Tipo de Dato**: Texto (ASCII)
- **Rol**: Descriptivo
- **Cardinalidad**: 211 valores únicos
- **Total de Registros**: 211
- **Es Clave**: No
- **Descripción**: Nombre completo y oficial del constructor/escudería.
- **Uso**: Visualización en reportes y dashboards para mejor comprensión del usuario
- **Etiquetas**: $ascii, $text
- **Tamaño en Memoria**: 2,947 bytes
- **Ejemplo de Valores**: "Mercedes", "Scuderia Ferrari", "Red Bull Racing"

#### 4. nationalityCostructor
- **Nombre Interno**: `nationalityCostructor`
- **Tipo de Dato**: Texto (ASCII)
- **Rol**: Dimensión de análisis geográfico
- **Cardinalidad**: 24 valores únicos
- **Total de Registros**: 211
- **Es Clave**: No
- **Descripción**: Nacionalidad del constructor. Permite análisis por país de origen de las escuderías.
- **Uso**: 
  - Análisis geográfico de constructores
  - Filtros por nacionalidad
  - Agrupaciones geográficas
- **Etiquetas**: $ascii, $text
- **Tamaño en Memoria**: 334 bytes
- **Ejemplo de Valores**: "British", "Italian", "German", "Austrian"

---

## Tabla: Resultados

**Descripción**: Tabla de hechos principal que contiene los resultados detallados de cada carrera de Fórmula 1.

**Origen**: Formula1 - Historico.xlsx (hoja: results)  
**Registros**: 26,080  
**Tipo**: Tabla de Hechos (Fact Table)  
**Rol**: Contiene métricas y medidas de rendimiento por carrera

### Campos de la Tabla Resultados

#### 1. resultId
- **Nombre Interno**: `resultId`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Identificador único de registro
- **Cardinalidad**: 26,080 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No (aunque es único)
- **Descripción**: Identificador único de cada resultado individual. Cada fila representa un piloto en una carrera específica.
- **Uso**: Identificación única de registros en la tabla de hechos
- **Etiquetas**: $numeric, $integer
- **Tamaño en Memoria**: 208,640 bytes

#### 2. raceId
- **Nombre Interno**: `raceId`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Clave foránea potencial
- **Cardinalidad**: 1,091 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No (pero debería tener tabla dimensional)
- **Descripción**: Identificador de la carrera. Agrupa múltiples resultados que pertenecen a la misma carrera.
- **Uso**: 
  - Agrupación de resultados por carrera
  - Análisis de rendimiento por evento
- **Nota**: ⚠️ Falta tabla dimensional de carreras
- **Etiquetas**: $numeric, $integer
- **Tamaño en Memoria**: 8,728 bytes
- **Promedio de resultados por carrera**: ~24 pilotos

#### 3. driverId
- **Nombre Interno**: `driverId`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Clave Foránea (Foreign Key)
- **Cardinalidad**: 857 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: ✅ Sí ($key)
- **Tabla Relacionada**: Drivers
- **Descripción**: Identificador del piloto que participó en la carrera. Relaciona cada resultado con información del piloto en la tabla Drivers.
- **Uso**: 
  - Relación N:1 con tabla Drivers
  - Análisis de rendimiento por piloto
  - Filtrado por piloto
- **Etiquetas**: $key, $numeric, $integer
- **Tamaño en Memoria**: 6,856 bytes

#### 4. constructorId
- **Nombre Interno**: `constructorId`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Clave Foránea (Foreign Key)
- **Cardinalidad**: 211 valores únicos
- **Total de Registros**: No especificado (parte de Resultados)
- **Es Clave**: ✅ Sí ($key - en tabla constructor)
- **Tabla Relacionada**: constructor
- **Descripción**: Identificador del constructor para el cual el piloto participó en esa carrera específica.
- **Uso**: 
  - Relación N:1 con tabla constructor
  - Análisis de rendimiento por escudería
  - Filtrado por constructor
- **Etiquetas**: $key, $numeric, $integer

#### 5. number
- **Nombre Interno**: `number`
- **Tipo de Dato**: Numérico
- **Rol**: Atributo descriptivo
- **Cardinalidad**: 130 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Número del coche del piloto en esa carrera específica. Puede variar según la temporada y el equipo.
- **Uso**: Visualización, identificación del piloto en gráficos de carreras
- **Tamaño en Memoria**: 1,169 bytes
- **Rango de Valores**: Típicamente 1-99

#### 6. grid
- **Nombre Interno**: `grid`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Métrica de posición inicial
- **Cardinalidad**: 35 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Posición de salida del piloto en la parrilla de salida, determinada por la sesión de clasificación.
- **Uso**: 
  - Análisis de rendimiento (comparar posición inicial vs final)
  - KPI: Posiciones ganadas/perdidas
- **Etiquetas**: $numeric, $integer
- **Tamaño en Memoria**: 280 bytes
- **Rango de Valores**: 1-35 (según tamaño de parrilla)

#### 7. position
- **Nombre Interno**: `position`
- **Tipo de Dato**: Numérico
- **Rol**: Métrica de resultado final
- **Cardinalidad**: 34 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Posición final del piloto al terminar la carrera. Puede ser null si el piloto no terminó.
- **Uso**: 
  - Métrica principal de rendimiento
  - Cálculos de promedio de posiciones
  - Análisis de mejora de posiciones
- **Tamaño en Memoria**: 305 bytes
- **Rango de Valores**: 1-34, puede contener nulls para retiros

#### 8. positionText
- **Nombre Interno**: `positionText`
- **Tipo de Dato**: Numérico (con representación textual)
- **Rol**: Atributo descriptivo de posición
- **Cardinalidad**: 39 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Representación textual de la posición final, incluyendo estados como "R" (Retirado), "D" (Descalificado), etc.
- **Uso**: Visualización de estado final en reportes
- **Tamaño en Memoria**: 339 bytes
- **Valores Posibles**: "1", "2", ..., "R", "D", "W"

#### 9. positionOrder
- **Nombre Interno**: `positionOrder`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Campo de ordenamiento
- **Cardinalidad**: 39 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Campo numérico para ordenar correctamente los resultados. Los pilotos retirados reciben valores altos para colocarlos al final.
- **Uso**: 
  - Ordenamiento de tablas y gráficos
  - Usado en expresiones de Set Analysis
- **Etiquetas**: $numeric, $integer
- **Tamaño en Memoria**: 0 bytes (optimizado)

#### 10. points
- **Nombre Interno**: `points`
- **Tipo de Dato**: Numérico
- **Rol**: Métrica de puntuación
- **Cardinalidad**: 39 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Puntos del campeonato otorgados al piloto por su resultado en la carrera, según las reglas de puntuación vigentes.
- **Uso**: 
  - KPI principal de análisis
  - Suma de puntos totales por piloto/constructor
  - Cálculo de campeonatos
- **Tamaño en Memoria**: 357 bytes
- **Rango de Valores**: 0-26 (varía según era de F1)

#### 11. laps
- **Nombre Interno**: `laps`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Métrica de distancia completada
- **Cardinalidad**: 172 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Número de vueltas completadas por el piloto en la carrera.
- **Uso**: 
  - Análisis de finalización de carrera
  - Identificar retiros prematuros
- **Etiquetas**: $numeric, $integer
- **Tamaño en Memoria**: 1,376 bytes
- **Rango de Valores**: 0-78 (según circuito)

#### 12. time
- **Nombre Interno**: `time`
- **Tipo de Dato**: Texto
- **Rol**: Métrica de tiempo total
- **Cardinalidad**: 7,000 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Tiempo total de carrera en formato texto (HH:MM:SS.mmm) o diferencia con el ganador.
- **Uso**: Comparación de tiempos entre pilotos
- **Tamaño en Memoria**: 84,078 bytes
- **Formato**: "1:34:50.616" o "+5.478"

#### 13. milliseconds
- **Nombre Interno**: `milliseconds`
- **Tipo de Dato**: Numérico
- **Rol**: Métrica de tiempo en formato numérico
- **Cardinalidad**: 7,213 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Tiempo total de carrera convertido a milisegundos para cálculos precisos.
- **Uso**: 
  - Cálculos matemáticos de diferencias de tiempo
  - Análisis estadístico de rendimiento
- **Tamaño en Memoria**: 64,916 bytes

#### 14. fastestLap
- **Nombre Interno**: `fastestLap`
- **Tipo de Dato**: Numérico
- **Rol**: Atributo de rendimiento
- **Cardinalidad**: 80 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Número de vuelta en la que el piloto logró su tiempo más rápido.
- **Uso**: Análisis de rendimiento por vuelta
- **Tamaño en Memoria**: 719 bytes

#### 15. rank
- **Nombre Interno**: `rank`
- **Tipo de Dato**: Numérico
- **Rol**: Clasificación de vuelta rápida
- **Cardinalidad**: 26 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Ranking de la vuelta más rápida del piloto en comparación con otros pilotos de la misma carrera.
- **Uso**: Identificar quién tuvo la vuelta más rápida de la carrera
- **Tamaño en Memoria**: 233 bytes
- **Rango**: 1-26 (1 = vuelta más rápida)

#### 16. fastestLapTime
- **Nombre Interno**: `fastestLapTime`
- **Tipo de Dato**: Texto (ASCII)
- **Rol**: Métrica de tiempo de vuelta
- **Cardinalidad**: 6,970 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Tiempo de la vuelta más rápida del piloto en formato texto (MM:SS.mmm).
- **Uso**: Comparación de velocidad en vuelta rápida
- **Etiquetas**: $ascii, $text
- **Tamaño en Memoria**: 97,574 bytes
- **Formato**: "1:32.478"

#### 17. fastestLapSpeed
- **Nombre Interno**: `fastestLapSpeed`
- **Tipo de Dato**: Numérico
- **Rol**: Métrica de velocidad
- **Cardinalidad**: 7,145 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No
- **Descripción**: Velocidad promedio de la vuelta más rápida del piloto, en km/h.
- **Uso**: 
  - Análisis de velocidad por circuito
  - Comparación de rendimiento de coches
- **Tamaño en Memoria**: 64,304 bytes
- **Rango de Valores**: ~180-260 km/h

#### 18. statusId
- **Nombre Interno**: `statusId`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Clave foránea potencial
- **Cardinalidad**: 137 valores únicos
- **Total de Registros**: 26,080
- **Es Clave**: No (pero debería tener tabla dimensional)
- **Descripción**: Identificador del estado final del piloto en la carrera (terminó, retirado, accidente, etc.).
- **Uso**: 
  - Análisis de fiabilidad
  - Estadísticas de retiros
- **Nota**: ⚠️ Falta tabla dimensional de estados
- **Etiquetas**: $numeric, $integer
- **Tamaño en Memoria**: 1,096 bytes

---

## Tabla: Drivers

**Descripción**: Tabla dimensional que contiene información detallada de los pilotos de Fórmula 1.

**Origen**: Formula1 - Historico.xlsx (hoja: drivers)  
**Registros**: 857  
**Tipo**: Dimensión  
**Rol**: Información maestra de pilotos

### Campos de la Tabla Drivers

#### 1. driverId
- **Nombre Interno**: `driverId`
- **Tipo de Dato**: Numérico (Integer)
- **Rol**: Clave Primaria (Primary Key)
- **Cardinalidad**: 857 valores únicos
- **Total de Registros**: 857
- **Es Clave**: ✅ Sí ($key)
- **Permite Nulos**: No
- **Descripción**: Identificador único del piloto. Sirve como clave primaria de la tabla y se relaciona con la tabla Resultados.
- **Uso**: Campo de relación principal con tabla de hechos Resultados
- **Etiquetas**: $key, $numeric, $integer
- **Tamaño en Memoria**: 404 bytes (en Drivers)

#### 2. driverRef
- **Nombre Interno**: `driverRef`
- **Tipo de Dato**: Texto (ASCII)
- **Rol**: Dimensión de análisis
- **Cardinalidad**: 857 valores únicos
- **Total de Registros**: 857
- **Es Clave**: No
- **Descripción**: Código o referencia única del piloto, generalmente basado en su apellido. Identificador legible para uso en URLs y análisis.
- **Uso**: 
  - Campo principal para selección en filtros
  - Utilizado en grupos dimensionales (CiclicoG, JerarquicoG)
  - Visualización en reportes
- **Etiquetas**: $ascii, $text
- **Tamaño en Memoria**: 11,251 bytes
- **Ejemplo de Valores**: "hamilton", "verstappen", "alonso", "vettel"

#### 3. number_driver
- **Nombre Interno**: `number_driver`
- **Tipo de Dato**: Numérico
- **Rol**: Identificador visual
- **Cardinalidad**: 45 valores únicos
- **Total de Registros**: 857
- **Es Clave**: No
- **Descripción**: Número permanente del piloto (introducido en F1 moderna). Algunos pilotos históricos no tienen número permanente.
- **Uso**: Visualización en dashboards, identificación rápida del piloto
- **Tamaño en Memoria**: 404 bytes
- **Rango de Valores**: 1-99 (números históricos pueden ser null)

#### 4. code
- **Nombre Interno**: `code`
- **Tipo de Dato**: Texto (ASCII)
- **Rol**: Identificador corto
- **Cardinalidad**: 95 valores únicos
- **Total de Registros**: 857
- **Es Clave**: No
- **Descripción**: Código de tres letras del piloto usado en gráficos de timing y televisión (ej: HAM, VER, ALO).
- **Uso**: 
  - Visualización compacta en gráficos
  - Identificación rápida en dashboards
- **Etiquetas**: $ascii, $text
- **Tamaño en Memoria**: 854 bytes
- **Formato**: 3 letras mayúsculas

#### 5. forename
- **Nombre Interno**: `forename`
- **Tipo de Dato**: Texto
- **Rol**: Atributo descriptivo
- **Cardinalidad**: 476 valores únicos
- **Total de Registros**: 857
- **Es Clave**: No
- **Descripción**: Nombre de pila del piloto.
- **Uso**: Visualización completa del nombre en reportes detallados
- **Etiquetas**: $text
- **Tamaño en Memoria**: 5,667 bytes
- **Ejemplo de Valores**: "Lewis", "Max", "Fernando"

#### 6. surname
- **Nombre Interno**: `surname`
- **Tipo de Dato**: Texto
- **Rol**: Atributo descriptivo
- **Cardinalidad**: 798 valores únicos
- **Total de Registros**: 857
- **Es Clave**: No
- **Descripción**: Apellido del piloto.
- **Uso**: 
  - Visualización principal en reportes
  - Ordenamiento alfabético
- **Etiquetas**: $text
- **Tamaño en Memoria**: 10,375 bytes
- **Ejemplo de Valores**: "Hamilton", "Verstappen", "Alonso"

#### 7. dob
- **Nombre Interno**: `dob`
- **Tipo de Dato**: Numérico (Date)
- **Rol**: Atributo temporal
- **Cardinalidad**: 839 valores únicos
- **Total de Registros**: 857
- **Es Clave**: No
- **Descripción**: Fecha de nacimiento del piloto (Date of Birth). Almacenado como número serial de fecha.
- **Uso**: 
  - Cálculo de edad del piloto
  - Análisis generacional
  - Estadísticas por rango de edad
- **Tamaño en Memoria**: 7,600 bytes
- **Formato Interno**: Número serial de fecha

#### 8. nationalityDriver
- **Nombre Interno**: `nationalityDriver`
- **Tipo de Dato**: Texto (ASCII)
- **Rol**: Dimensión de análisis geográfico
- **Cardinalidad**: 42 valores únicos
- **Total de Registros**: 857
- **Es Clave**: No
- **Descripción**: Nacionalidad del piloto según su licencia de competición.
- **Uso**: 
  - Análisis geográfico de pilotos
  - Filtros por nacionalidad
  - Estadísticas por país
- **Etiquetas**: $ascii, $text
- **Tamaño en Memoria**: 606 bytes
- **Ejemplo de Valores**: "British", "Dutch", "Spanish", "German"

---

## Campos Calculados

### campo
- **Nombre Interno**: `campo`
- **Tipo de Dato**: Numérico (calculado)
- **Valor**: Constante = 1
- **Rol**: Campo auxiliar para Set Analysis
- **Origen**: Calculado en el script
- **Descripción**: Campo calculado con valor constante usado como condición en expresiones de Set Analysis.
- **Uso**: 
  - Expresiones como: `Count({<campo={1}>} positionOrder)`
  - Filtrado condicional en análisis
- **Nota**: Este campo no tiene propósito aparente fuera de las expresiones mostradas. Podría ser eliminado y reemplazar las expresiones por `Count(positionOrder)` directamente.

---

## Grupos Dimensionales

### CiclicoG (Grupo Cíclico)

**Descripción**: Grupo dimensional cíclico que permite alternar entre diferentes dimensiones en una misma visualización.

**Tipo**: Cíclico (Cyclic Group)

**Campos del Grupo** (en orden de ciclo):
1. **constructorRef** (Texto) - Constructor/Escudería
2. **driverRef** (Texto) - Piloto

**Uso**: 
- Permite al usuario cambiar entre vista por constructor y vista por piloto con un clic
- Usado en tablas pivotantes y gráficos para análisis flexible
- Ideal para comparaciones dinámicas

**Ejemplos de Uso**:
```qlik
// En tabla pivotante con dimensión CiclicoG
Count({<campo={1}>} positionOrder)  // Conteo de resultados
Sum(positionOrder)                   // Suma de posiciones
```

**Objetos que lo Utilizan**:
- CH01 (Tabla Pivotante)
- CH02 (Gráfico Mekko)
- CH03 (Tabla Pivotante)

---

### JerarquicoG (Grupo Jerárquico)

**Descripción**: Grupo dimensional jerárquico que define una estructura de drill-down desde constructor hacia piloto.

**Tipo**: Jerárquico (Hierarchical Group)

**Campos del Grupo** (en orden jerárquico):
1. **constructorRef** (Texto) - Nivel 1: Constructor/Escudería (padre)
2. **driverRef** (Texto) - Nivel 2: Piloto (hijo)

**Jerarquía**:
```
Constructor
    └── Piloto (que corrió para ese constructor)
```

**Uso**: 
- Drill-down estructurado: iniciar con vista de constructores, expandir para ver pilotos
- Análisis de composición de equipos
- Navegación intuitiva en análisis multinivel

**Ejemplos de Uso**:
```qlik
// En tabla pivotante con dimensión JerarquicoG
Sum(points)                          // Puntos por constructor/piloto
Count({<campo={1}>} positionOrder)   // Conteo de participaciones
```

**Objetos que lo Utilizan**:
- CH03 (Tabla Pivotante en algunos QVW)
- CH04, CH06, CH07 (varios gráficos con jerarquía)

---

## Convenciones y Etiquetas

### Etiquetas de Tipo de Dato

| Etiqueta | Significado | Descripción |
|----------|-------------|-------------|
| `$key` | Clave | Campo usado como clave de relación |
| `$numeric` | Numérico | Campo numérico |
| `$integer` | Entero | Campo numérico entero |
| `$text` | Texto | Campo de texto general |
| `$ascii` | ASCII | Texto limitado a caracteres ASCII |

### Nomenclatura de Campos

- **ID al final**: Campos que terminan en "Id" son claves numéricas (ej: `driverId`, `constructorId`)
- **Ref al final**: Campos que terminan en "Ref" son códigos de referencia en texto (ej: `driverRef`, `constructorRef`)
- **Campos con "_"**: Algunos campos usan guión bajo como separador (ej: `number_driver`)
- **CamelCase**: Algunos campos usan notación mixta (ej: `nationalityCostructor`, `nationalityDriver`)

---

## Relaciones entre Campos

### Claves de Relación

```
constructor.constructorId (PK) ←→ Resultados.constructorId (FK)
    Relación: 1:N (Un constructor, muchos resultados)
    
Drivers.driverId (PK) ←→ Resultados.driverId (FK)
    Relación: 1:N (Un piloto, muchos resultados)
```

### Campos sin Tabla Dimensional

Los siguientes campos deberían tener tablas dimensionales pero no las tienen:

1. **raceId** → Debería tener tabla "Races" con:
   - Fecha de carrera
   - Nombre del circuito
   - País/ubicación
   - Condiciones climáticas

2. **statusId** → Debería tener tabla "Status" con:
   - Descripción del estado (Finished, Retired, Accident, etc.)
   - Categoría (Completado, Problema mecánico, Accidente, Descalificación)

---

## Métricas y KPIs Sugeridos

### Basados en Tabla Resultados

1. **Puntos Totales**: `Sum(points)`
2. **Posición Promedio**: `Avg(position)`
3. **Tasa de Finalización**: `Count(position) / Count(resultId) * 100`
4. **Posiciones Ganadas**: `Sum(grid - position)`
5. **Vueltas Completadas**: `Sum(laps)`
6. **Victorias**: `Count({<position={1}>} resultId)`
7. **Podios**: `Count({<position={'<=3'}>} resultId)`
8. **Vueltas Rápidas**: `Count({<rank={1}>} resultId)`

### Basados en Tabla constructor

1. **Campeonatos de Constructores**: Requiere cálculo complejo
2. **Constructores Activos**: `Count(DISTINCT constructorRef)`
3. **Constructores por Nacionalidad**: `Count(DISTINCT constructorRef) by nationalityCostructor`

### Basados en Tabla Drivers

1. **Pilotos Únicos**: `Count(DISTINCT driverId)`
2. **Edad Promedio**: `Avg(Today() - dob) / 365.25`
3. **Pilotos por Nacionalidad**: `Count(DISTINCT driverId) by nationalityDriver`

---

## Notas de Calidad de Datos

### ✅ Datos Completos
- Todos los campos de clave (IDs) están poblados sin nulls
- Referencias (Ref) son únicas y consistentes
- Relaciones están bien formadas

### ⚠️ Posibles Valores Null
- **position**: Puede ser null para pilotos retirados
- **time**: Puede ser null si no completó suficientes vueltas
- **fastestLapTime**: Puede ser null si el piloto no completó una vuelta rápida válida
- **fastestLapSpeed**: Puede ser null en circuitos o épocas sin medición

### 📊 Cardinalidades Esperadas

| Campo | Valores Esperados |
|-------|-------------------|
| constructorId | ~200-250 (constructores históricos) |
| driverId | ~850-900 (pilotos históricos) |
| raceId | ~1000-1100 (carreras desde 1950) |
| statusId | ~30-50 (diferentes estados de finalización) |

---

## Resumen de Tamaños

| Tabla | Registros | Campos | Tamaño (bytes) |
|-------|-----------|--------|----------------|
| constructor | 211 | 4 | 772 |
| Resultados | 26,080 | 18 | 528,211 |
| Drivers | 857 | 8 | 7,340 |
| **TOTAL** | **27,148** | **30** | **536,323** |

---

## Historial de Cambios

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | 2024 | Documento inicial generado |

---

**Fin del Glosario**

Para consultas adicionales sobre campos específicos o relaciones, referirse al documento de Arquitectura del Modelo.
