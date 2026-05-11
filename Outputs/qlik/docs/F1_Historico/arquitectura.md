# Arquitectura del Modelo de Datos - F1 Histórico

## Información General del Proyecto

- **Nombre del Proyecto**: F1 Histórico
- **Archivo QVW**: F1 codigo y objetos.qvw
- **Rol**: ETL + Visualización
- **QlikView Build**: 50689
- **Última Ejecución**: 2026-04-21 17:19:52 UTC
- **Ubicación**: Set Pruebas/F1 codigo y objetos.qvw
- **Tamaño**: 688,384 bytes

---

## 1. Fuentes de Datos

### Fuente Principal: Formula1 - Historico.xlsx

**Tipo de Conexión**: Archivo Excel (OOXML)  
**Ubicación**: Local - `c:\users\jorgebolanos\onedrive - epam\bola_qlik\aqualiamigracionqlik_pbi\set pruebas\formula1 - historico.xlsx`

**Hojas utilizadas**:
1. **constructor** - Información de constructores de Fórmula 1
2. **results** - Resultados de carreras
3. **drivers** - Información de pilotos

---

## 2. Estructura del Modelo de Datos

El modelo de datos implementa un esquema de tipo **Estrella/Copo de Nieve** con las siguientes características:

### 2.1 Tabla de Hechos: `Resultados`

**Descripción**: Contiene los resultados detallados de todas las carreras de Fórmula 1.

**Estadísticas**:
- Registros: 26,080
- Campos: 18
- Campos clave: 2 (driverId, constructorId)
- Tamaño: 528,211 bytes

**Campos**:
- `resultId` (Numérico, Integer) - ID único del resultado [26,080 valores únicos]
- `raceId` (Numérico, Integer) - ID de la carrera [1,091 valores únicos]
- `driverId` (Numérico, Integer) - **CLAVE**: ID del piloto [857 valores únicos]
- `constructorId` (Numérico, Integer) - **CLAVE**: ID del constructor [211 valores únicos]
- `number` (Numérico) - Número del piloto en la carrera [130 valores únicos]
- `grid` (Numérico, Integer) - Posición en parrilla de salida [35 valores únicos]
- `position` (Numérico) - Posición final en la carrera [34 valores únicos]
- `positionText` (Numérico) - Texto de la posición final [39 valores únicos]
- `positionOrder` (Numérico, Integer) - Orden de posición para clasificación [39 valores únicos]
- `points` (Numérico) - Puntos obtenidos en la carrera [39 valores únicos]
- `laps` (Numérico, Integer) - Vueltas completadas [172 valores únicos]
- `time` (Texto) - Tiempo total de carrera [7,000 valores únicos]
- `milliseconds` (Numérico) - Tiempo en milisegundos [7,213 valores únicos]
- `fastestLap` (Numérico) - Vuelta más rápida [80 valores únicos]
- `rank` (Numérico) - Ranking de vuelta rápida [26 valores únicos]
- `fastestLapTime` (Texto, ASCII) - Tiempo de vuelta más rápida [6,970 valores únicos]
- `fastestLapSpeed` (Numérico) - Velocidad de vuelta más rápida [7,145 valores únicos]
- `statusId` (Numérico, Integer) - ID de estado final [137 valores únicos]

**Origen de Datos**: 
```
LOAD * FROM Formula1 - Historico.xlsx (hoja: results)
```

**Transformaciones**:
- Carga directa desde Excel sin transformaciones adicionales en el script
- Relación automática establecida con tabla `constructor` vía `constructorId`
- Relación automática establecida con tabla `Drivers` vía `driverId`

---

### 2.2 Tabla Dimensión: `constructor`

**Descripción**: Tabla maestra de constructores (escuderías) de Fórmula 1.

**Estadísticas**:
- Registros: 211
- Campos: 4
- Campos clave: 1 (constructorId)
- Tamaño: 772 bytes

**Campos**:
- `constructorId` (Numérico, Integer) - **CLAVE PRIMARIA**: ID único del constructor [211 valores únicos]
- `constructorRef` (Texto, ASCII) - Referencia/código del constructor [211 valores únicos]
- `name` (Texto, ASCII) - Nombre completo del constructor [211 valores únicos]
- `nationalityCostructor` (Texto, ASCII) - Nacionalidad del constructor [24 valores únicos]

**Origen de Datos**:
```
LOAD * FROM Formula1 - Historico.xlsx (hoja: constructor)
```

**Relaciones**:
- Relacionada con `Resultados` mediante `constructorId`

---

### 2.3 Tabla Dimensión: `Drivers`

**Descripción**: Tabla maestra de pilotos de Fórmula 1.

**Estadísticas**:
- Registros: 857
- Campos: 8
- Campos clave: 1 (driverId)
- Tamaño: 7,340 bytes

**Campos**:
- `driverId` (Numérico, Integer) - **CLAVE PRIMARIA**: ID único del piloto [857 valores únicos]
- `driverRef` (Texto, ASCII) - Referencia/código del piloto [857 valores únicos]
- `number_driver` (Numérico) - Número permanente del piloto [45 valores únicos]
- `code` (Texto, ASCII) - Código de tres letras del piloto [95 valores únicos]
- `forename` (Texto) - Nombre del piloto [476 valores únicos]
- `surname` (Texto) - Apellido del piloto [798 valores únicos]
- `dob` (Numérico) - Fecha de nacimiento [839 valores únicos]
- `nationalityDriver` (Texto, ASCII) - Nacionalidad del piloto [42 valores únicos]

**Origen de Datos**:
```
LOAD * FROM Formula1 - Historico.xlsx (hoja: drivers)
```

**Relaciones**:
- Relacionada con `Resultados` mediante `driverId`

---

## 3. Diagrama del Modelo de Datos

```
┌─────────────────────┐
│    constructor      │
│  (Dimensión)        │
├─────────────────────┤
│ * constructorId (PK)│
│   constructorRef    │
│   name              │
│   nationality...    │
└──────────┬──────────┘
           │
           │ 1:N
           │
┌──────────▼──────────────────────┐
│       Resultados                │
│     (Tabla de Hechos)           │
├─────────────────────────────────┤
│   resultId                      │
│   raceId                        │
│ * driverId (FK)                 │
│ * constructorId (FK)            │
│   number                        │
│   grid                          │
│   position                      │
│   positionOrder                 │
│   points                        │
│   laps                          │
│   time                          │
│   milliseconds                  │
│   fastestLap                    │
│   rank                          │
│   fastestLapTime                │
│   fastestLapSpeed               │
│   statusId                      │
└──────────┬──────────────────────┘
           │
           │ N:1
           │
┌──────────▼──────────┐
│     Drivers         │
│   (Dimensión)       │
├─────────────────────┤
│ * driverId (PK)     │
│   driverRef         │
│   number_driver     │
│   code              │
│   forename          │
│   surname           │
│   dob               │
│   nationalityDriver │
└─────────────────────┘
```

---

## 4. Relaciones entre Tablas

### 4.1 Resultados ↔ constructor
- **Tipo**: Many-to-One (N:1)
- **Campo de unión**: `constructorId`
- **Cardinalidad**: Múltiples resultados pueden pertenecer a un constructor
- **Estado**: ✅ Relación automática establecida por QlikView

### 4.2 Resultados ↔ Drivers
- **Tipo**: Many-to-One (N:1)
- **Campo de unión**: `driverId`
- **Cardinalidad**: Múltiples resultados pueden pertenecer a un piloto
- **Estado**: ✅ Relación automática establecida por QlikView

**Nota**: No se detectaron problemas de circularidad o relaciones muchos-a-muchos problemáticas en el modelo.

---

## 5. Grupos Dimensionales

El modelo incluye dos grupos dimensionales para análisis jerárquico y cíclico:

### 5.1 Grupo Cíclico: `CiclicoG`
**Tipo**: Cíclico  
**Campos**:
1. `constructorRef` - Referencia del constructor
2. `driverRef` - Referencia del piloto

**Propósito**: Permite alternar entre análisis por constructor y por piloto en visualizaciones.

### 5.2 Grupo Jerárquico: `JerarquicoG`
**Tipo**: Jerárquico  
**Campos** (en orden):
1. `constructorRef` - Nivel superior (Constructor)
2. `driverRef` - Nivel inferior (Piloto)

**Propósito**: Permite drill-down desde constructor hacia piloto en análisis jerárquicos.

---

## 6. Campos Calculados y Variables

### Campo Calculado: `campo`
**Uso**: Utilizado en expresiones de Set Analysis  
**Valor**: Campo con valor constante `1`  
**Propósito**: Usado como filtro en expresiones como `Count({<campo={1}>} positionOrder)`

---

## 7. Generación de QVDs

El proceso ETL genera dos archivos QVD para persistencia y reutilización:

### 7.1 constructor.qvd
```qlik
STORE constructor INTO constructor.qvd (qvd);
```
**Contenido**: Tabla completa de constructores  
**Registros**: 211

### 7.2 Resultados.qvd
```qlik
STORE Resultados INTO Resultados.qvd (qvd);
```
**Contenido**: Tabla completa de resultados  
**Registros**: 26,080

---

## 8. Análisis de Calidad del Modelo

### ✅ Fortalezas
1. **Modelo normalizado**: Separación clara entre hechos y dimensiones
2. **Relaciones simples**: Solo relaciones 1:N, sin circularidad
3. **Claves bien definidas**: Uso correcto de IDs numéricos como claves
4. **Documentación implícita**: Nombres de campos descriptivos
5. **Grupos dimensionales**: Facilitan análisis flexible

### ⚠️ Consideraciones
1. **Falta de tabla de fechas**: No existe una tabla calendario para análisis temporal basado en `raceId`
2. **Sin tabla de status**: El campo `statusId` no tiene tabla dimensional de referencia
3. **Redundancia potencial**: El campo `driverRef` aparece tanto en Drivers como podría estar en Resultados
4. **Campo calculado `campo`**: Su propósito en Set Analysis no está claramente documentado en el script

### 🔍 Relaciones sin Problemas Detectados
- No se identificaron JOINs con potencial duplicación de registros
- No existen relaciones many-to-many directas
- Las cardinalidades son apropiadas para el modelo estrella

---

## 9. Carga de Datos - Secuencia ETL

```
1. LOAD constructor FROM Excel → Tabla constructor (211 registros)
2. LOAD results FROM Excel → Tabla Resultados (26,080 registros)
3. LOAD drivers FROM Excel → Tabla Drivers (857 registros)
4. Asociaciones automáticas por campos comunes (constructorId, driverId)
5. STORE constructor → constructor.qvd
6. STORE Resultados → Resultados.qvd
```

**Nota**: No se detectaron transformaciones RESIDENT LOAD, JOIN, CONCATENATE o MAPPING en el script.

---

## 10. Visualizaciones y Uso del Modelo

### Hojas (Sheets)
- **Principal**: Hoja principal con tabla pivotante, gráfico Mekko y cuadro de lista

### Objetos Principales
1. **Tabla Pivotante** (CH01): Análisis con grupos cíclicos
2. **Gráfico Mekko** (CH02): Análisis de conteo con Set Analysis
3. **Cuadro de Lista** (LB01): Selección de `constructorRef`

### Expresiones Comunes
```qlik
// Conteo con Set Analysis
Count({<campo={1}>} positionOrder)

// Suma simple
Sum(positionOrder)

// Suma de puntos
Sum(points)
```

---

## 11. Metadatos Técnicos

- **Tipo de documento**: QlikView Document (.qvw)
- **Modo de seguridad**: Sin Section Access
- **Generación de log**: Desactivada
- **Última recarga**: 2026-04-21 17:19:52 UTC
- **Hash de edición personal**: F9FF1C8ABE2DA28930E3A7B614B0E440...

---

## 12. Recomendaciones

1. **Crear tabla de fechas**: Implementar un calendario basado en fechas de carreras
2. **Añadir tabla de status**: Crear dimensión para `statusId` con descripciones
3. **Documentar campo `campo`**: Clarificar el propósito del campo calculado
4. **Considerar tabla de carreras**: Añadir dimensión para `raceId` con detalles de circuitos y fechas
5. **Optimización QVD**: Considerar cargas incrementales para tablas grandes

---

**Documento generado**: 2024
**Versión**: 1.0
**Estado**: Producción
