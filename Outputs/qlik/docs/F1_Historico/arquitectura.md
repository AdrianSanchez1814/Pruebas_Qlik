# Arquitectura del Modelo - F1 Histórico

## Información General del Proyecto

- **Proyecto**: F1 Histórico
- **Archivo Principal**: F1 codigo y objetos.qvw
- **Rol**: ETL + Visualización
- **QlikView Build**: 50689
- **Última Ejecución**: 2026-04-21 17:19:52 (UTC)
- **Ubicación**: Set Pruebas/F1 codigo y objetos.qvw
- **Tamaño**: 688,384 bytes

## Fuentes de Datos

### Origen Principal
**Archivo Excel**: `Formula1 - Historico.xlsx`

El modelo carga datos desde un archivo Excel con las siguientes hojas:

1. **constructor** - Información de constructores de Fórmula 1
2. **results** - Resultados de carreras
3. **drivers** - Información de pilotos

**Ruta del archivo fuente**: 
- `c:\users\jorgebolanos\onedrive - epam\bola_qlik\aqualiamigracionqlik_pbi\set pruebas\formula1 - historico.xlsx`
- `c:\users\albertogonzalez1\desktop\set de pruebas\formula1 - historico.xlsx`

*(Nota: El archivo se encuentra en diferentes rutas según el entorno de desarrollo)*

## Estructura del Modelo de Datos

### Tablas del Modelo

El modelo consta de **3 tablas principales**:

#### 1. Tabla: `constructor`
- **Registros**: 211 filas
- **Campos**: 4 campos
- **Campos Clave**: 1 (constructorId)
- **Tamaño**: 844 bytes

**Descripción**: Contiene información de los constructores/equipos de Fórmula 1.

#### 2. Tabla: `Resultados`
- **Registros**: 26,080 filas
- **Campos**: 24 campos
- **Campos Clave**: 1 (constructorId como FK)
- **Tamaño**: 652,126 bytes

**Descripción**: Tabla de hechos principal que contiene los resultados detallados de todas las carreras, incluyendo estadísticas de rendimiento.

#### 3. Tabla: `Drivers`
- **Registros**: 857 filas
- **Campos**: 8 campos
- **Campos Clave**: 1 (driverId)
- **Tamaño**: 7,340 bytes

**Descripción**: Tabla dimensional con información de los pilotos.

### Modelo de Relaciones

```
constructor (Dimension)
    |
    | (1:N) - Relación por constructorId
    |
    ↓
Resultados (Hechos)
    |
    | (N:1) - Relación por driverId  
    |
    ↓
Drivers (Dimension)
```

**Tipo de Modelo**: Estrella con tabla de hechos central (Resultados)

### Campos Clave y Relaciones

#### Relación 1: constructor ← → Resultados
- **Campo de unión**: `constructorId`
- **Tipo**: 1:N (Un constructor puede tener muchos resultados)
- **Cardinalidad**: 211 constructores únicos

#### Relación 2: Resultados ← → Drivers
- **Campo de unión**: `driverId`
- **Tipo**: N:1 (Muchos resultados por piloto)
- **Cardinalidad**: 857 pilotos únicos

⚠️ **NOTA IMPORTANTE**: Existe una posible relación implícita entre las tablas que podría generar duplicación de registros si no se gestiona adecuadamente. El campo `driverId` actúa como clave de unión entre `Resultados` y `Drivers`, pero ambas tablas también se relacionan con `constructor` a través de `constructorId`. Esto crea un esquema de constelación de hechos que debe ser manejado correctamente en las visualizaciones para evitar conteos incorrectos.

## Transformaciones de Datos

### Cargas desde Excel

#### Carga 1: Tabla constructor
```qlik
LOAD
    constructorId,
    constructorRef,
    name,
    nationality as nationalityCostructor
FROM [Formula1 - Historico.xlsx]
(ooxml, embedded labels, table is constructor);
```

**Transformaciones aplicadas**:
- Renombre del campo: `nationality` → `nationalityCostructor`

#### Carga 2: Tabla Resultados
```qlik
LOAD
    resultId,
    raceId,
    driverId,
    constructorId,
    number,
    grid,
    position,
    positionText,
    positionOrder,
    points,
    laps,
    time,
    milliseconds,
    fastestLap,
    rank,
    fastestLapTime,
    fastestLapSpeed,
    statusId,
    [... campos adicionales ...]
FROM [Formula1 - Historico.xlsx]
(ooxml, embedded labels, table is results);
```

**Transformaciones aplicadas**:
- Carga directa de todos los campos
- Sin transformaciones adicionales en la carga inicial

#### Carga 3: Tabla Drivers
```qlik
LOAD
    driverId,
    driverRef,
    number as number_driver,
    code,
    forename,
    surname,
    dob,
    nationality as nationalityDriver
FROM [Formula1 - Historico.xlsx]
(ooxml, embedded labels, table is drivers);
```

**Transformaciones aplicadas**:
- Renombre del campo: `number` → `number_driver` (para evitar conflicto con campo number de Resultados)
- Renombre del campo: `nationality` → `nationalityDriver`

### Grupos Dimensionales

El modelo incluye dos grupos dimensionales configurados:

#### Grupo 1: CiclicoG (Grupo Cíclico)
**Tipo**: Grupo Cíclico
**Campos**:
- constructorRef
- driverRef

**Propósito**: Permite a los usuarios alternar entre las dimensiones de constructor y piloto en visualizaciones.

#### Grupo 2: JerarquicoG (Grupo Jerárquico)
**Tipo**: Grupo Jerárquico
**Campos** (en orden):
1. constructorRef
2. driverRef

**Propósito**: Proporciona una jerarquía de navegación drill-down desde constructor hasta piloto.

### Operaciones STORE (Generación de QVDs)

El script genera 2 archivos QVD para persistencia de datos:

#### QVD 1: constructor.qvd
```qlik
STORE constructor
INTO constructor.qvd (qvd);
```

#### QVD 2: Resultados.qvd
```qlik
STORE Resultados
INTO Resultados.qvd (qvd);
```

**Propósito de los QVDs**: Almacenar datos procesados para recarga incremental y mejora de rendimiento en futuros accesos.

## Campos Calculados y Expresiones

El modelo no incluye campos calculados en el script, pero las visualizaciones utilizan expresiones complejas:

### Expresiones de Visualización Principales

1. **Count con Set Analysis**:
   ```qlik
   Count({<campo={1}> positionOrder)
   ```

2. **Suma de posiciones**:
   ```qlik
   Sum(positionOrder)
   ```

3. **Suma de puntos**:
   ```qlik
   Sum(points)
   ```

4. **Promedio de posición**:
   ```qlik
   Avg(position)
   ```

5. **Cálculo de porcentaje**:
   ```qlik
   sum((points-positionOrder)/positionOrder)
   ```

## Consideraciones de Rendimiento y Calidad

### Tamaño del Modelo
- **Total de registros**: 27,148 (211 + 26,080 + 857)
- **Tamaño total**: ~660 KB (muy eficiente)
- **Campos totales**: 36 campos únicos en el modelo

### Calidad de Datos

#### Campos con Alta Cardinalidad:
- `resultId`: 26,080 valores únicos (100% de los registros en Resultados)
- `driverId`: 857 valores únicos
- `driverRef`: 857 valores únicos
- `raceId`: 1,091 valores únicos

#### Campos con Baja Cardinalidad (buenos para filtros):
- `nationalityCostructor`: 24 valores únicos
- `nationalityDriver`: 42 valores únicos
- `grid`: 35 valores únicos
- `position`: 34 valores únicos

### ⚠️ Advertencias y Consideraciones

1. **Duplicación Potencial**: 
   - El modelo tiene relaciones múltiples que pueden causar duplicación en agregaciones si no se usa Set Analysis apropiadamente
   - Recomendación: Usar DISTINCT en conteos o Set Analysis para controlar el contexto

2. **Campos con Valores Nulos**:
   - Varios campos numéricos pueden contener valores NULL (ej: `time`, `fastestLapTime`)
   - Esto es esperado cuando un piloto no termina la carrera

3. **Integridad Referencial**:
   - No hay restricciones explícitas de integridad referencial
   - Se asume que todos los `constructorId` en Resultados existen en constructor
   - Se asume que todos los `driverId` en Resultados existen en Drivers

## Hojas y Visualizaciones

### Hoja 1: "Principal" (F1 codigo y objetos.qvw)
**Objetos**:
- CH01: Tabla Pivotante con grupo cíclico
- CH02: Gráfico Mekko con Set Analysis
- LB01: Lista de filtro por constructorRef

### Hoja 2: "Pantalla 1" (F1 - Prueba01.qvw)
**Objetos**:
- Tablas pivotantes con grupos jerárquicos
- Gráficos de barras
- Indicadores y gráficos combinados

### Hoja 3: "Pantalla 2" (F1 - Prueba01.qvw)
**Objetos**:
- Gráficos de líneas y tarta
- Visualizaciones de nacionalidad
- Análisis de posición y puntos

## Flujo de Datos ETL

```
┌─────────────────────────────────────┐
│  Formula1 - Historico.xlsx          │
│  (Fuente de Datos Excel)            │
└──────────────┬──────────────────────┘
               │
               │ LOAD de 3 hojas
               │
    ┌──────────┴──────────┬──────────────────┐
    │                     │                   │
    ▼                     ▼                   ▼
┌─────────┐         ┌──────────┐        ┌─────────┐
│constructor│         │Resultados│        │ Drivers │
│  (211)   │         │ (26,080) │        │  (857)  │
└─────┬────┘         └────┬─────┘        └────┬────┘
      │                   │                    │
      │                   │                    │
      └───────────┬───────┴────────────────────┘
                  │
                  │ Relaciones por IDs
                  │
                  ▼
          ┌───────────────┐
          │ Modelo Estrella│
          │   en Memoria   │
          └───────┬────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
┌──────────────┐    ┌─────────────┐
│constructor.qvd│    │Resultados.qvd│
└──────────────┘    └─────────────┘
```

## Variables del Sistema

El modelo utiliza variables reservadas de QlikView para configuración:
- `ErrorMode`: Control de errores en script
- `StripComments`: Manejo de comentarios
- `OpenUrlTimeout`: Timeout de conexiones
- `ThousandSep`: Separador de miles (.)
- `DecimalSep`: Separador decimal (,)
- `MoneyFormat`: Formato monetario (#.##0,00 €)
- `DateFormat`: Formato de fecha (D/M/YYYY)
- `TimeFormat`: Formato de hora (h:mm:ss)

## Conclusiones y Recomendaciones

### Fortalezas del Modelo:
1. ✅ Estructura clara y eficiente tipo estrella
2. ✅ Buen uso de grupos dimensionales (cíclicos y jerárquicos)
3. ✅ Generación de QVDs para optimización
4. ✅ Nomenclatura clara de campos
5. ✅ Tamaño óptimo del modelo

### Áreas de Mejora:
1. 📌 Documentar explícitamente las relaciones entre tablas en el script
2. 📌 Implementar validaciones de integridad referencial
3. 📌 Agregar manejo de errores para cargas de datos
4. 📌 Considerar implementar un calendario maestro si se necesita análisis temporal
5. 📌 Estandarizar el uso de Set Analysis en todas las visualizaciones para evitar duplicaciones

---

**Documento generado**: 2024
**Versión del modelo**: QlikView Build 50689
**Estado**: Producción
