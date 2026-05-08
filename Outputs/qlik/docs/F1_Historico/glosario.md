# Glosario de Datos - F1 Histórico

## Tabla de Contenidos
1. [Tabla: constructor](#tabla-constructor)
2. [Tabla: Resultados](#tabla-resultados)
3. [Tabla: Drivers](#tabla-drivers)
4. [Grupos de Campos](#grupos-de-campos)
5. [Variables del Sistema](#variables-del-sistema)

---

## Tabla: constructor

**Descripción:** Contiene información sobre los constructores (escuderías) de Fórmula 1 a lo largo de la historia.

**Estadísticas:**
- Número de Filas: 211
- Número de Campos: 4
- Campos Clave: 1
- Tamaño en Bytes: 772

### Campos de la Tabla constructor

| Campo | Tipo | Valores Únicos | Total Registros | Es Clave | Descripción |
|-------|------|----------------|-----------------|----------|-------------|
| **constructorId** | INTEGER | 211 | 0 (distinct only) | ✓ | Identificador único numérico del constructor. Campo clave para relación con Resultados. |
| **constructorRef** | TEXT | 211 | 211 | ✗ | Referencia textual única del constructor (ej: "ferrari", "mclaren", "red_bull"). |
| **name** | TEXT | 211 | 211 | ✗ | Nombre completo del constructor tal como aparece oficialmente. |
| **nationalityCostructor** | TEXT | 24 | 211 | ✗ | Nacionalidad del constructor. Existen 24 nacionalidades diferentes entre los 211 constructores. |

**Detalles de Campos:**

#### constructorId
- **Tamaño:** 1,688 bytes
- **Tipo de Dato:** Numérico Entero ($numeric, $integer)
- **Uso:** Campo clave para establecer relaciones con la tabla Resultados
- **Valores:** 211 identificadores únicos (uno por cada constructor histórico)

#### constructorRef
- **Tamaño:** 2,871 bytes
- **Tipo de Dato:** Texto ASCII ($ascii, $text)
- **Uso:** Referencia amigable para identificar constructores en análisis
- **Valores:** 211 referencias únicas
- **Ejemplo:** "ferrari", "mclaren", "williams"

#### name
- **Tamaño:** 2,947 bytes
- **Tipo de Dato:** Texto ASCII ($ascii, $text)
- **Uso:** Nombre oficial completo del constructor para visualizaciones
- **Valores:** 211 nombres únicos
- **Ejemplo:** "Scuderia Ferrari", "McLaren Racing", "Red Bull Racing"

#### nationalityCostructor
- **Tamaño:** 334 bytes
- **Tipo de Dato:** Texto ASCII ($ascii, $text)
- **Uso:** Análisis geográfico de constructores
- **Valores:** 24 nacionalidades diferentes
- **Distribución:** Múltiples constructores pueden compartir la misma nacionalidad

---

## Tabla: Resultados

**Descripción:** Tabla de hechos que contiene todos los resultados de carreras de Fórmula 1. Incluye información detallada sobre el rendimiento de cada piloto en cada carrera.

**Estadísticas:**
- Número de Filas: 26,080
- Número de Campos: 18
- Campos Clave: 2 (constructorId, driverId)
- Tamaño en Bytes: 528,211

### Campos de la Tabla Resultados

| Campo | Tipo | Valores Únicos | Total Registros | Es Clave | Descripción |
|-------|------|----------------|-----------------|----------|-------------|
| **resultId** | INTEGER | 26,080 | 26,080 | ✗ | Identificador único de cada resultado de carrera. |
| **raceId** | INTEGER | 1,091 | 26,080 | ✗ | Identificador de la carrera. |
| **driverId** | INTEGER | 857 | 26,080 | ✓ | Identificador del piloto (FK a Drivers). |
| **constructorId** | INTEGER | 211 | 26,080 | ✓ | Identificador del constructor (FK a constructor). |
| **number** | INTEGER | 130 | 26,080 | ✗ | Número del coche del piloto en la carrera. |
| **grid** | INTEGER | 35 | 26,080 | ✗ | Posición de salida en la parrilla. |
| **position** | NUMERIC | 34 | 26,080 | ✗ | Posición final en la carrera. |
| **positionText** | NUMERIC | 39 | 26,080 | ✗ | Representación textual de la posición. |
| **positionOrder** | INTEGER | 39 | 26,080 | ✗ | Orden de posición para ordenamiento. |
| **points** | NUMERIC | 39 | 26,080 | ✗ | Puntos obtenidos en la carrera. |
| **laps** | INTEGER | 172 | 26,080 | ✗ | Número de vueltas completadas. |
| **time** | TEXT | 7,000 | 26,080 | ✗ | Tiempo total de carrera. |
| **milliseconds** | NUMERIC | 7,213 | 26,080 | ✗ | Tiempo de carrera en milisegundos. |
| **fastestLap** | NUMERIC | 80 | 26,080 | ✗ | Número de vuelta más rápida. |
| **rank** | NUMERIC | 26 | 26,080 | ✗ | Ranking de la vuelta más rápida. |
| **fastestLapTime** | TEXT | 6,970 | 26,080 | ✗ | Tiempo de la vuelta más rápida. |
| **fastestLapSpeed** | NUMERIC | 7,145 | 26,080 | ✗ | Velocidad de la vuelta más rápida. |
| **statusId** | INTEGER | 137 | 26,080 | ✗ | Estado final del resultado (terminado, retirado, etc.). |

**Detalles de Campos:**

#### resultId
- **Tamaño:** 208,640 bytes
- **Tipo de Dato:** Numérico Entero ($numeric, $integer)
- **Uso:** Identificador único de cada registro de resultado
- **Valores:** 26,080 identificadores únicos (uno por cada resultado)
- **Observación:** Cada fila representa un resultado individual de un piloto en una carrera

#### raceId
- **Tamaño:** 8,728 bytes
- **Tipo de Dato:** Numérico Entero ($numeric, $integer)
- **Uso:** Identifica la carrera específica
- **Valores:** 1,091 carreras únicas
- **Relación:** Múltiples resultados (pilotos) por cada carrera

#### driverId
- **Tamaño:** 6,856 bytes
- **Tipo de Dato:** Numérico Entero ($numeric, $integer, $key)
- **Uso:** Clave foránea para relacionar con la tabla Drivers
- **Valores:** 857 pilotos diferentes han participado
- **Relación:** Cada piloto puede tener múltiples resultados

#### constructorId
- **Tamaño:** 1,688 bytes (shared con tabla constructor)
- **Tipo de Dato:** Numérico Entero ($numeric, $integer, $key)
- **Uso:** Clave foránea para relacionar con la tabla constructor
- **Valores:** 211 constructores diferentes
- **Relación:** Cada constructor tiene múltiples resultados

#### number
- **Tamaño:** 1,169 bytes
- **Tipo de Dato:** Numérico Entero
- **Uso:** Número del coche en la carrera específica
- **Valores:** 130 números diferentes utilizados históricamente
- **Observación:** Los números de coche pueden variar entre temporadas y pilotos

#### grid
- **Tamaño:** 280 bytes
- **Tipo de Dato:** Numérico Entero ($numeric, $integer)
- **Uso:** Posición inicial en la parrilla de salida
- **Valores:** 35 posiciones diferentes (de 1 a 35)
- **Importancia:** Permite analizar el avance/retroceso durante la carrera

#### position
- **Tamaño:** 305 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Posición final al terminar la carrera
- **Valores:** 34 posiciones diferentes
- **Observación:** Valores null pueden indicar no clasificado

#### positionText
- **Tamaño:** 339 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Representación alternativa de la posición (puede incluir "R" para retirado, "D" para descalificado)
- **Valores:** 39 valores diferentes

#### positionOrder
- **Tamaño:** 0 bytes (optimizado)
- **Tipo de Dato:** Numérico Entero ($numeric, $integer)
- **Uso:** Campo para ordenamiento correcto de posiciones
- **Valores:** 39 valores de orden

#### points
- **Tamaño:** 357 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Puntos del campeonato obtenidos en la carrera
- **Valores:** 39 valores diferentes de puntos
- **Sistema:** Varía según la temporada (10-8-6..., 25-18-15..., etc.)

#### laps
- **Tamaño:** 1,376 bytes
- **Tipo de Dato:** Numérico Entero ($numeric, $integer)
- **Uso:** Número total de vueltas completadas
- **Valores:** 172 valores diferentes
- **Análisis:** Permite identificar abandones tempranos vs. finalizaciones

#### time
- **Tamaño:** 84,078 bytes
- **Tipo de Dato:** Texto
- **Uso:** Tiempo total de carrera en formato texto
- **Valores:** 7,000 tiempos únicos
- **Formato:** Típicamente "HH:MM:SS.mmm" o diferencias con el ganador

#### milliseconds
- **Tamaño:** 64,916 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Tiempo de carrera en milisegundos para cálculos precisos
- **Valores:** 7,213 valores únicos
- **Precisión:** Permite comparaciones exactas de tiempos

#### fastestLap
- **Tamaño:** 719 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Número de vuelta en la que se logró el tiempo más rápido
- **Valores:** 80 valores diferentes

#### rank
- **Tamaño:** 233 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Posición en el ranking de vuelta más rápida
- **Valores:** 26 posiciones de ranking

#### fastestLapTime
- **Tamaño:** 97,574 bytes
- **Tipo de Dato:** Texto ASCII ($ascii, $text)
- **Uso:** Tiempo de la vuelta más rápida en formato texto
- **Valores:** 6,970 tiempos únicos
- **Formato:** "MM:SS.mmm"

#### fastestLapSpeed
- **Tamaño:** 64,304 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Velocidad promedio de la vuelta más rápida
- **Valores:** 7,145 velocidades únicas
- **Unidad:** Típicamente km/h

#### statusId
- **Tamaño:** 1,096 bytes
- **Tipo de Dato:** Numérico Entero ($numeric, $integer)
- **Uso:** Código de estado final (terminado, accidente, problema mecánico, etc.)
- **Valores:** 137 estados diferentes registrados

---

## Tabla: Drivers

**Descripción:** Tabla de dimensión que contiene información detallada sobre todos los pilotos que han participado en la Fórmula 1.

**Estadísticas:**
- Número de Filas: 857
- Número de Campos: 8
- Campos Clave: 1
- Tamaño en Bytes: 7,340

### Campos de la Tabla Drivers

| Campo | Tipo | Valores Únicos | Total Registros | Es Clave | Descripción |
|-------|------|----------------|-----------------|----------|-------------|
| **driverId** | INTEGER | 857 | 857 | ✓ | Identificador único del piloto. |
| **driverRef** | TEXT | 857 | 857 | ✗ | Referencia textual única del piloto. |
| **number_driver** | NUMERIC | 45 | 857 | ✗ | Número permanente del piloto (introducido en años recientes). |
| **code** | TEXT | 95 | 857 | ✗ | Código de tres letras del piloto (ej: HAM, VET, ALO). |
| **forename** | TEXT | 476 | 857 | ✗ | Nombre de pila del piloto. |
| **surname** | TEXT | 798 | 857 | ✗ | Apellido del piloto. |
| **dob** | NUMERIC | 839 | 857 | ✗ | Fecha de nacimiento del piloto. |
| **nationalityDriver** | TEXT | 42 | 857 | ✗ | Nacionalidad del piloto. |

**Detalles de Campos:**

#### driverId
- **Tamaño:** 6,856 bytes (shared)
- **Tipo de Dato:** Numérico Entero ($numeric, $integer, $key)
- **Uso:** Identificador único para cada piloto
- **Valores:** 857 pilotos en la historia de F1
- **Relación:** Clave primaria para relacionar con Resultados

#### driverRef
- **Tamaño:** 11,251 bytes
- **Tipo de Dato:** Texto ASCII ($ascii, $text)
- **Uso:** Referencia amigable del piloto
- **Valores:** 857 referencias únicas
- **Ejemplo:** "hamilton", "vettel", "alonso", "schumacher"

#### number_driver
- **Tamaño:** 404 bytes
- **Tipo de Dato:** Numérico
- **Uso:** Número permanente del piloto (sistema moderno desde ~2014)
- **Valores:** 45 números asignados
- **Observación:** No todos los pilotos históricos tienen número permanente

#### code
- **Tamaño:** 854 bytes
- **Tipo de Dato:** Texto ASCII ($ascii, $text)
- **Uso:** Código de identificación de tres letras
- **Valores:** 95 códigos únicos
- **Ejemplo:** "HAM" (Hamilton), "VET" (Vettel), "ALO" (Alonso)
- **Observación:** Sistema introducido en años recientes

#### forename
- **Tamaño:** 5,667 bytes
- **Tipo de Dato:** Texto ($text)
- **Uso:** Nombre de pila del piloto
- **Valores:** 476 nombres diferentes
- **Observación:** Múltiples pilotos pueden compartir el mismo nombre

#### surname
- **Tamaño:** 10,375 bytes
- **Tipo de Dato:** Texto ($text)
- **Uso:** Apellido del piloto
- **Valores:** 798 apellidos diferentes
- **Observación:** Campo principal para identificación visual

#### dob
- **Tamaño:** 7,600 bytes
- **Tipo de Dato:** Numérico (fecha)
- **Uso:** Fecha de nacimiento para cálculos de edad
- **Valores:** 839 fechas únicas
- **Formato:** Formato numérico de fecha de QlikView

#### nationalityDriver
- **Tamaño:** 606 bytes
- **Tipo de Dato:** Texto ASCII ($ascii, $text)
- **Uso:** Análisis demográfico y geográfico
- **Valores:** 42 nacionalidades diferentes
- **Observación:** Permite análisis de diversidad en el deporte

---

## Grupos de Campos

El modelo incluye dos grupos de campos que facilitan la navegación y análisis en las visualizaciones:

### Grupo: CiclicoG (Cíclico)

**Descripción:** Grupo cíclico que permite alternar entre dos dimensiones en las visualizaciones.

**Tipo:** Cíclico (IsCyclic: true)

**Campos del Grupo:**
1. **constructorRef** (Constructor)
2. **driverRef** (Piloto)

**Uso:** Permite al usuario cambiar dinámicamente entre ver datos por constructor o por piloto con un solo clic.

**Casos de Uso:**
- Análisis comparativo alternando entre perspectiva de escudería y piloto
- Dashboards interactivos con cambio rápido de contexto
- Visualizaciones que necesitan diferentes niveles de agregación

---

### Grupo: JerarquicoG (Jerárquico)

**Descripción:** Grupo jerárquico que establece una relación de drill-down de constructor a piloto.

**Tipo:** Jerárquico (IsCyclic: false)

**Jerarquía de Campos:**
1. **constructorRef** (Nivel superior - Constructor)
2. **driverRef** (Nivel inferior - Piloto)

**Uso:** Permite hacer drill-down desde el nivel de constructor hacia el nivel de piloto.

**Casos de Uso:**
- Navegación jerárquica: ver primero resultados por escudería, luego expandir a pilotos específicos
- Análisis top-down: desde la perspectiva del equipo hacia el rendimiento individual
- Reportes con niveles de detalle progresivos

---

## Variables del Sistema

El modelo incluye variables reservadas de QlikView para configuración:

### Variables de Configuración

| Variable | Descripción | Uso |
|----------|-------------|-----|
| **ErrorMode** | Modo de manejo de errores | Controla cómo se manejan errores durante la carga |
| **StripComments** | Eliminar comentarios | Configuración para procesamiento de scripts |
| **OpenUrlTimeout** | Timeout de URLs | Tiempo de espera para conexiones web |
| **ScriptError** | Error de script | Almacena el último error de script |
| **ScriptErrorCount** | Contador de errores | Número de errores durante la última ejecución (Valor: 0) |
| **ScriptErrorList** | Lista de errores | Lista detallada de errores de script |

### Variables de Formato Regional

| Variable | Valor | Descripción |
|----------|-------|-------------|
| **ThousandSep** | . | Separador de miles |
| **DecimalSep** | , | Separador decimal |
| **MoneyThousandSep** | . | Separador de miles para moneda |
| **MoneyDecimalSep** | , | Separador decimal para moneda |
| **MoneyFormat** | #.##0,00 €;-#.##0,00 € | Formato de moneda |
| **TimeFormat** | h:mm:ss | Formato de tiempo |
| **DateFormat** | D/M/YYYY | Formato de fecha |
| **TimestampFormat** | D/M/YYYY h:mm:ss[.fff] | Formato de fecha y hora |
| **FirstWeekDay** | 0 | Primer día de la semana (0 = Lunes) |
| **BrokenWeeks** | 0 | Configuración de semanas |
| **ReferenceDay** | 4 | Día de referencia |
| **FirstMonthOfYear** | 1 | Primer mes del año |
| **CollationLocale** | es-ES | Configuración regional (Español) |

### Variables de Nombres de Meses y Días

| Variable | Valor |
|----------|-------|
| **MonthNames** | ene;feb;mar;abr;may;jun;jul;ago;sept;oct;nov;dic |
| **LongMonthNames** | enero;febrero;marzo;abril;mayo;junio;julio;agosto;septiembre;octubre;noviembre;diciembre |
| **DayNames** | lun;mar;mié;jue;vie;sáb;dom |
| **LongDayNames** | lunes;martes;miércoles;jueves;viernes;sábado;domingo |

---

## Resumen de Cardinalidades

### Por Tabla

| Tabla | Filas | Campos | Tamaño (bytes) | Campos Clave |
|-------|-------|--------|----------------|--------------|
| constructor | 211 | 4 | 772 | 1 |
| Resultados | 26,080 | 18 | 528,211 | 2 |
| Drivers | 857 | 8 | 7,340 | 1 |
| **TOTAL** | **27,148** | **30** | **536,323** | **4** |

### Distribución de Valores Únicos

- **Pilotos únicos:** 857
- **Constructores únicos:** 211
- **Carreras únicas:** 1,091
- **Resultados totales:** 26,080
- **Promedio de pilotos por carrera:** ~24 (26,080 / 1,091)

---

## Notas de Uso

1. **Integridad Referencial:** Todos los valores de `constructorId` y `driverId` en la tabla Resultados tienen correspondencia en las tablas dimensionales.

2. **Valores Nulos:** Algunos campos pueden contener valores nulos, especialmente en:
   - `fastestLapTime` y `fastestLapSpeed` (cuando el piloto no completa la carrera)
   - `time` (cuando el piloto no termina)
   - `number_driver` y `code` (pilotos históricos anteriores a estos sistemas)

3. **Campos Calculados:** No se identifican campos calculados en el modelo; todos los campos provienen directamente de la fuente de datos.

4. **Optimización:** El modelo utiliza QVDs (Resultados.qvd y constructor.qvd) para optimizar el rendimiento de carga.

5. **Configuración Regional:** El modelo está configurado para formato español (es-ES) con separador decimal coma y separador de miles punto.
