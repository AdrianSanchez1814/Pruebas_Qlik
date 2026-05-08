# Arquitectura del Modelo de Datos - F1 Histórico

## Información General

- **Proyecto:** F1 Histórico
- **QlikView Build:** 50689
- **Última Ejecución:** 2026-04-21 17:19:52 UTC
- **Archivo Principal:** F1 codigo y objetos.qvw
- **Rol:** ETL + visualización
- **Fuente de Datos:** Formula1 - Historico.xlsx (hojas: constructor, results, drivers)

## Estructura del Modelo de Datos

### Tablas del Modelo

El modelo de datos está compuesto por **3 tablas principales**:

#### 1. Tabla: `constructor`
- **Número de Filas:** 211
- **Número de Campos:** 4
- **Campos Clave:** 1 (constructorId)
- **Tamaño:** 772 bytes

**Campos:**
- `constructorId` (INTEGER, KEY) - Identificador único del constructor
- `constructorRef` (TEXT) - Referencia del constructor
- `name` (TEXT) - Nombre del constructor
- `nationalityCostructor` (TEXT) - Nacionalidad del constructor (24 valores distintos)

**Cardinalidades:**
- constructorId: 211 valores únicos
- constructorRef: 211 valores únicos
- name: 211 valores únicos
- nationalityCostructor: 24 valores únicos

---

#### 2. Tabla: `Resultados`
- **Número de Filas:** 26,080
- **Número de Campos:** 18
- **Campos Clave:** 2 (constructorId, driverId)
- **Tamaño:** 528,211 bytes

**Campos:**
- `resultId` (INTEGER) - Identificador único del resultado (26,080 valores)
- `raceId` (INTEGER) - Identificador de la carrera (1,091 valores únicos)
- `driverId` (INTEGER, KEY) - Identificador del piloto (857 valores únicos)
- `constructorId` (INTEGER, KEY) - Identificador del constructor (211 valores únicos)
- `number` (INTEGER) - Número del piloto (130 valores únicos)
- `grid` (INTEGER) - Posición en parrilla (35 valores únicos)
- `position` (NUMERIC) - Posición final (34 valores únicos)
- `positionText` (NUMERIC) - Texto de posición (39 valores únicos)
- `positionOrder` (INTEGER) - Orden de posición (39 valores únicos)
- `points` (NUMERIC) - Puntos obtenidos (39 valores únicos)
- `laps` (INTEGER) - Vueltas completadas (172 valores únicos)
- `time` (TEXT) - Tiempo de carrera (7,000 valores únicos)
- `milliseconds` (NUMERIC) - Tiempo en milisegundos (7,213 valores únicos)
- `fastestLap` (NUMERIC) - Vuelta más rápida (80 valores únicos)
- `rank` (NUMERIC) - Ranking (26 valores únicos)
- `fastestLapTime` (TEXT) - Tiempo de vuelta más rápida (6,970 valores únicos)
- `fastestLapSpeed` (NUMERIC) - Velocidad de vuelta más rápida (7,145 valores únicos)
- `statusId` (INTEGER) - Estado del resultado (137 valores únicos)

**Cardinalidades:**
- Total de registros: 26,080 resultados de carreras

---

#### 3. Tabla: `Drivers`
- **Número de Filas:** 857
- **Número de Campos:** 8
- **Campos Clave:** 1 (driverId)
- **Tamaño:** 7,340 bytes

**Campos:**
- `driverId` (INTEGER, KEY) - Identificador único del piloto
- `driverRef` (TEXT) - Referencia del piloto (857 valores únicos)
- `number_driver` (NUMERIC) - Número del piloto (45 valores únicos)
- `code` (TEXT) - Código del piloto (95 valores únicos)
- `forename` (TEXT) - Nombre del piloto (476 valores únicos)
- `surname` (TEXT) - Apellido del piloto (798 valores únicos)
- `dob` (NUMERIC) - Fecha de nacimiento (839 valores únicos)
- `nationalityDriver` (TEXT) - Nacionalidad del piloto (42 valores distintos)

**Cardinalidades:**
- driverId: 857 valores únicos (todos los pilotos históricos)

---

## Diagrama de Relaciones del Modelo

```
┌─────────────────┐
│   constructor   │
│                 │
│ constructorId*  │─────┐
│ constructorRef  │     │
│ name            │     │
│ nationality...  │     │
└─────────────────┘     │
                        │ (1:N)
                        │
                        ▼
                 ┌─────────────────┐
                 │   Resultados    │◄─────┐
                 │                 │      │
                 │ resultId        │      │ (1:N)
                 │ raceId          │      │
                 │ driverId*       │──────┤
                 │ constructorId*  │      │
                 │ number          │      │
                 │ grid            │      │
                 │ position        │      │
                 │ points          │      │
                 │ laps            │      │
                 │ time            │      │
                 │ ...             │      │
                 └─────────────────┘      │
                                          │
                                          │
┌─────────────────┐                      │
│    Drivers      │                      │
│                 │                      │
│ driverId*       │──────────────────────┘
│ driverRef       │
│ number_driver   │
│ code            │
│ forename        │
│ surname         │
│ dob             │
│ nationality...  │
└─────────────────┘

* = Campo clave
```

## Relaciones entre Tablas

### 1. Relación: constructor ↔ Resultados
- **Tipo:** 1:N (Uno a muchos)
- **Campo de Unión:** `constructorId`
- **Descripción:** Un constructor puede tener múltiples resultados de carreras
- **Validación:** ✓ Relación correcta

### 2. Relación: Drivers ↔ Resultados
- **Tipo:** 1:N (Uno a muchos)
- **Campo de Unión:** `driverId`
- **Descripción:** Un piloto puede tener múltiples resultados de carreras
- **Validación:** ✓ Relación correcta

### ⚠️ Análisis de Joins Problemáticos

**No se han identificado joins problemáticos** en el modelo actual. Las relaciones 1:N están correctamente diseñadas:

- La tabla `Resultados` actúa como tabla de hechos (fact table)
- Las tablas `constructor` y `Drivers` actúan como tablas de dimensiones
- Las claves foráneas en `Resultados` garantizan la integridad referencial
- No existen joins many-to-many que puedan causar duplicación de filas

## Origen de los Datos

### Fuente Principal
- **Archivo:** Formula1 - Historico.xlsx
- **Ubicación:** c:\users\jorgebolanos\onedrive - epam\bola_qlik\aqualiamigracionqlik_pbi\set pruebas\
- **Hojas Excel:**
  - `constructor` → Tabla constructor
  - `results` → Tabla Resultados
  - `drivers` → Tabla Drivers

### Proceso de Carga (ETL)

#### 1. Carga de Datos desde Excel
```qlik
// La carga se realiza desde el archivo Excel con hojas específicas
// Origen: Formula1 - Historico.xlsx
```

#### 2. Transformaciones Aplicadas

**Tabla constructor:**
- Carga directa desde hoja Excel
- Campos: constructorId, constructorRef, name, nationalityCostructor
- No se aplican transformaciones complejas

**Tabla Resultados:**
- Carga desde hoja Excel "results"
- Campos numéricos y de texto sin transformaciones adicionales
- Incluye métricas de rendimiento: points, position, laps, time, etc.

**Tabla Drivers:**
- Carga desde hoja Excel "drivers"
- Renombrado de campo: `number` → `number_driver` (para evitar conflicto con Resultados)
- Campos de identificación: driverRef, code, forename, surname
- Información adicional: dob, nationalityDriver

#### 3. Generación de QVDs
El proceso genera los siguientes archivos QVD para optimización:

```qlik
STORE Resultados INTO Resultados.qvd (qvd);
STORE constructor INTO constructor.qvd (qvd);
```

## Grupos de Campos (Field Groups)

El modelo incluye dos grupos de campos para navegación jerárquica:

### 1. Grupo Cíclico: `CiclicoG`
- **Tipo:** Cíclico (permite navegar circularmente entre campos)
- **Campos:**
  - `constructorRef`
  - `driverRef`

### 2. Grupo Jerárquico: `JerarquicoG`
- **Tipo:** Jerárquico (permite drill-down ordenado)
- **Campos:**
  - `constructorRef` (nivel superior)
  - `driverRef` (nivel inferior)

## Métricas y Cálculos Principales

### Expresiones Utilizadas en Visualizaciones

1. **Suma de Puntos:**
   ```qlik
   Sum(points)
   ```

2. **Promedio de Posición:**
   ```qlik
   Avg(position)
   ```

3. **Conteo con Set Analysis:**
   ```qlik
   Count({<campo={1}>} positionOrder)
   ```

4. **Cálculo de Porcentaje:**
   ```qlik
   sum((points-positionOrder)/positionOrder)
   ```

5. **Suma de Posiciones:**
   ```qlik
   Sum(positionOrder)
   ```

## Consideraciones de Performance

- **Tamaño Total del Modelo:** ~536 KB (sin contar tablas del sistema)
- **Total de Registros:** 27,148 filas (26,080 en Resultados + 857 en Drivers + 211 en constructor)
- **Optimización:** El modelo utiliza QVDs para carga incremental y optimización de rendimiento

## Pantallas y Objetos Visuales

### Pantalla Principal
- **ID:** Document\SH01
- **Título:** Principal

**Objetos:**
- `CH01` - Tabla Pivotante (con grupo cíclico)
- `CH02` - Gráfico Mekko (Contar Set Analisis)
- `LB01` - Lista de selección de constructorRef

## Notas Adicionales

- El modelo está diseñado para análisis histórico de Fórmula 1
- Las relaciones están bien establecidas sin riesgo de duplicación
- La estructura permite análisis por constructor, piloto, y resultados de carreras
- Se utiliza una arquitectura dimensional clásica (Star Schema simplificado)
