# Glosario de Datos - F1 Histórico

## Información General

**Proyecto**: F1 Histórico  
**Aplicación QVW**: F1 codigo y objetos.qvw  
**Fuente de Datos**: Formula1 - Historico.xlsx  
**Fecha de Documentación**: 2026-05-05

---

## Propósito del Documento

Este glosario proporciona una descripción detallada de cada tabla y sus campos en el modelo de datos de F1 Histórico. El objetivo es facilitar la comprensión del modelo para usuarios de negocio, analistas y desarrolladores.

---

## Tablas del Modelo

### 1. Constructor (Constructores/Escuderías)

**Descripción**: Contiene la información de los constructores (escuderías) que han participado en la Fórmula 1.

**Origen**: Hoja "constructor" del archivo Formula1 - Historico.xlsx

**Archivo QVD Generado**: constructor.qvd

**Tipo de Tabla**: Dimensión

#### Campos de la Tabla Constructor

> **Nota**: Los campos específicos deben ser extraídos del script de carga del QVW. A continuación se presentan los campos típicos esperados en una tabla de constructores de F1:

| Campo | Tipo de Dato | Descripción | Ejemplo | Clave |
|-------|--------------|-------------|---------|-------|
| constructorId | Numérico | Identificador único del constructor | 1, 2, 3... | PK |
| constructorRef | Texto | Referencia corta del constructor | "mclaren", "ferrari" | - |
| name | Texto | Nombre completo del constructor | "McLaren", "Ferrari" | - |
| nationality | Texto | Nacionalidad del constructor | "British", "Italian" | - |
| url | Texto | URL de Wikipedia del constructor | "http://..." | - |

**Relaciones**:
- Se relaciona con la tabla Resultados mediante constructorId

**Observaciones**:
- Tabla de dimensión maestra
- Datos relativamente estáticos
- Almacenada en QVD para optimización

---

### 2. Resultados (Results)

**Descripción**: Almacena los resultados históricos de todas las carreras de Fórmula 1, incluyendo posiciones, tiempos, y puntos obtenidos.

**Origen**: Hoja "results" del archivo Formula1 - Historico.xlsx

**Archivo QVD Generado**: Resultados.qvd

**Tipo de Tabla**: Hechos

#### Campos de la Tabla Resultados

> **Nota**: Los campos específicos deben ser extraídos del script de carga del QVW. A continuación se presentan los campos típicos esperados:

| Campo | Tipo de Dato | Descripción | Ejemplo | Clave |
|-------|--------------|-------------|---------|-------|
| resultId | Numérico | Identificador único del resultado | 1, 2, 3... | PK |
| raceId | Numérico | Identificador de la carrera | 100, 101... | FK |
| driverId | Numérico | Identificador del piloto | 5, 10... | FK |
| constructorId | Numérico | Identificador del constructor | 1, 2... | FK |
| number | Numérico | Número del auto en la carrera | 44, 33... | - |
| grid | Numérico | Posición en la parrilla de salida | 1-20 | - |
| position | Numérico | Posición final en la carrera | 1-20 | - |
| positionText | Texto | Posición final como texto | "1", "2", "R" (Retirado) | - |
| positionOrder | Numérico | Orden de posición para clasificación | 1-20 | - |
| points | Numérico | Puntos obtenidos en la carrera | 25, 18, 15... | - |
| laps | Numérico | Número de vueltas completadas | 50, 55... | - |
| time | Texto | Tiempo total de carrera | "1:34:50.616" | - |
| milliseconds | Numérico | Tiempo en milisegundos | 5690616 | - |
| fastestLap | Numérico | Número de vuelta más rápida | 45 | - |
| rank | Numérico | Ranking de vuelta rápida | 1-20 | - |
| fastestLapTime | Texto | Tiempo de vuelta más rápida | "1:32.238" | - |
| fastestLapSpeed | Numérico | Velocidad de vuelta rápida | 218.300 | - |
| statusId | Numérico | Estado final (terminado/retirado) | 1, 2, 3... | FK |

**Relaciones**:
- → Constructor (constructorId)
- → Drivers (driverId)
- → Race (raceId) - si existe tabla de carreras
- → Status (statusId) - si existe tabla de estados

**Métricas Calculables**:
- Total de puntos por constructor
- Total de puntos por piloto
- Victorias por temporada
- Podios por escudería
- Tasa de abandono

**Observaciones**:
- Tabla de hechos principal del modelo
- Alta volumetría de datos
- Contiene métricas clave del negocio
- Almacenada en QVD para rendimiento

---

### 3. Drivers (Pilotos)

**Descripción**: Contiene la información de todos los pilotos que han participado en la Fórmula 1.

**Origen**: Hoja "drivers" del archivo Formula1 - Historico.xlsx

**Tipo de Tabla**: Dimensión

#### Campos de la Tabla Drivers

> **Nota**: Los campos específicos deben ser extraídos del script de carga del QVW. A continuación se presentan los campos típicos esperados:

| Campo | Tipo de Dato | Descripción | Ejemplo | Clave |
|-------|--------------|-------------|---------|-------|
| driverId | Numérico | Identificador único del piloto | 1, 2, 3... | PK |
| driverRef | Texto | Referencia corta del piloto | "hamilton", "alonso" | - |
| number | Numérico | Número permanente del piloto | 44, 14... | - |
| code | Texto | Código de tres letras | "HAM", "ALO" | - |
| forename | Texto | Nombre del piloto | "Lewis", "Fernando" | - |
| surname | Texto | Apellido del piloto | "Hamilton", "Alonso" | - |
| dob | Fecha | Fecha de nacimiento | "1985-01-07" | - |
| nationality | Texto | Nacionalidad del piloto | "British", "Spanish" | - |
| url | Texto | URL de Wikipedia del piloto | "http://..." | - |

**Campos Calculados Sugeridos**:
- FullName = forename + " " + surname
- Age = Year(Today()) - Year(dob)
- YearsActive = Cálculo basado en primera y última carrera

**Relaciones**:
- Se relaciona con la tabla Resultados mediante driverId

**Observaciones**:
- Tabla de dimensión maestra
- Datos relativamente estáticos
- Importante para análisis de desempeño individual

---

## Campos Comunes y Estándares

### Convenciones de Nomenclatura

| Sufijo | Significado | Ejemplo |
|--------|-------------|---------|
| Id | Identificador único (clave primaria) | constructorId, driverId |
| Ref | Referencia corta o código | constructorRef, driverRef |
| Text | Versión texto de un valor | positionText |
| Order | Campo de ordenamiento | positionOrder |

---

## Relaciones entre Tablas

### Diagrama de Relaciones

```
┌──────────────┐         ┌──────────────┐
│  Constructor │         │   Drivers    │
│              │         │              │
│ constructorId├───┐ ┌───┤ driverId     │
│ name         │   │ │   │ forename     │
│ nationality  │   │ │   │ surname      │
└──────────────┘   │ │   │ nationality  │
                   │ │   └──────────────┘
                   │ │
                   ▼ ▼
            ┌──────────────┐
            │  Resultados  │
            │              │
            │ resultId     │
            │ constructorId│ (FK)
            │ driverId     │ (FK)
            │ position     │
            │ points       │
            │ time         │
            └──────────────┘
```

### Cardinalidad

| Relación | Cardinalidad | Descripción |
|----------|--------------|-------------|
| Constructor → Resultados | 1:N | Un constructor puede tener muchos resultados |
| Drivers → Resultados | 1:N | Un piloto puede tener muchos resultados |

---

## Métricas de Negocio

### KPIs Principales

1. **Total de Puntos**
   - Fórmula: `Sum(points)`
   - Descripción: Suma total de puntos obtenidos

2. **Victorias**
   - Fórmula: `Count({<position={1}>} resultId)`
   - Descripción: Número de primeros lugares

3. **Podios**
   - Fórmula: `Count({<position={'1','2','3'}>} resultId)`
   - Descripción: Número de posiciones en el top 3

4. **Tasa de Finalización**
   - Fórmula: `Count({<positionText-={'R','D','W','F','N'}>} resultId) / Count(resultId)`
   - Descripción: Porcentaje de carreras terminadas

5. **Posición Promedio**
   - Fórmula: `Avg(position)`
   - Descripción: Posición final promedio

---

## Valores Especiales y Códigos

### Códigos de Estado de Posición (positionText)

| Código | Significado | Descripción |
|--------|-------------|-------------|
| 1-20 | Posición Final | Posición numérica final |
| R | Retired | Retirado (abandono) |
| D | Disqualified | Descalificado |
| W | Withdrawn | Retirado antes de la carrera |
| F | Failed to qualify | No calificó |
| N | Not classified | No clasificado |

---

## Calidad de Datos

### Validaciones Recomendadas

1. **Constructor**
   - constructorId debe ser único
   - name no debe ser nulo
   - nationality debe estar en lista válida

2. **Drivers**
   - driverId debe ser único
   - forename y surname no deben ser nulos
   - dob debe ser fecha válida

3. **Resultados**
   - resultId debe ser único
   - constructorId y driverId deben existir en sus tablas respectivas
   - points debe ser >= 0
   - position debe estar entre 1 y 20 o ser nulo

### Datos Faltantes

- Verificar valores NULL en campos clave
- Validar integridad referencial entre tablas
- Revisar duplicados en resultados

---

## Notas Adicionales

### Limitaciones Conocidas

1. **Archivo QVW Binario**: El contenido del script detallado requiere abrir el archivo QVW en QlikView Desktop para extracción completa de campos
2. **Campos Exactos**: Los campos listados son estimaciones basadas en estructura típica de datos de F1
3. **Transformaciones**: Se requiere análisis adicional del script para identificar campos calculados

### Actualizaciones Futuras

Para completar este glosario se recomienda:
1. Extraer script completo del QVW
2. Listar campos exactos con sus tipos de datos
3. Documentar fórmulas de campos calculados
4. Incluir reglas de negocio específicas
5. Agregar ejemplos de valores reales

---

## Referencias

- **Proyecto**: F1 Histórico
- **Archivo Fuente**: Formula1 - Historico.xlsx
- **Ubicación**: Set Pruebas/F1 codigo y objetos.qvw
- **Documentación Relacionada**: arquitectura.md

---

## Control de Versiones

| Versión | Fecha | Autor | Cambios |
|---------|-------|-------|---------|
| 1.0 | 2026-05-05 | Agente de Extracción Qlik | Versión inicial basada en metadata |

---

**Última Actualización**: 2026-05-05  
**Estado**: Documentación inicial - Requiere validación con script completo
