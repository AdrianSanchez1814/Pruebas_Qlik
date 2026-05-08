# Arquitectura del Modelo - F1 Histórico

## Información General del Proyecto

**Proyecto**: F1 Histórico  
**Archivo QVW**: F1 codigo y objetos.qvw  
**Rol**: ETL + Visualización  
**Última Ejecución**: 2026-04-21 17:19:52 UTC  
**QlikView Build**: 50689  
**Tamaño del Archivo**: 688,384 bytes

---

## Origen de Datos

### Fuente Principal
- **Archivo**: Formula1 - Historico.xlsx
- **Ubicación**: Set Pruebas/
- **Tipo**: Archivo Excel

### Hojas de Excel Cargadas
1. **constructor** - Datos de constructores de F1
2. **results** - Resultados de carreras
3. **drivers** - Información de pilotos

---

## Estructura del Modelo de Datos

### 1. Carga de Datos (Data Load)

#### Tabla: Constructor
**Origen**: Formula1 - Historico.xlsx - Hoja "constructor"

**Proceso de Carga**:
```
LOAD [Campo1], [Campo2], ... 
FROM [Formula1 - Historico.xlsx]
(ooxml, embedded labels, table is constructor);
```

**Output QVD**: constructor.qvd

**Descripción**: Contiene la información de los constructores/escuderías participantes en la Fórmula 1.

---

#### Tabla: Resultados
**Origen**: Formula1 - Historico.xlsx - Hoja "results"

**Proceso de Carga**:
```
LOAD [Campo1], [Campo2], ...
FROM [Formula1 - Historico.xlsx]
(ooxml, embedded labels, table is results);
```

**Output QVD**: Resultados.qvd

**Descripción**: Almacena los resultados históricos de las carreras de Fórmula 1.

---

#### Tabla: Drivers
**Origen**: Formula1 - Historico.xlsx - Hoja "drivers"

**Proceso de Carga**:
```
LOAD [Campo1], [Campo2], ...
FROM [Formula1 - Historico.xlsx]
(ooxml, embedded labels, table is drivers);
```

**Descripción**: Contiene información sobre los pilotos de Fórmula 1.

---

## Transformaciones Aplicadas

### Sin Transformaciones Complejas Detectadas
Basado en el análisis del archivo, no se identificaron transformaciones complejas como:
- RESIDENT LOAD
- JOIN (⚠️)
- CONCATENATE
- MAPPING LOAD

El modelo utiliza cargas directas desde el archivo Excel fuente.

---

## Relaciones del Modelo

### Modelo Estrella/Copo de Nieve

**Tablas de Dimensión**:
1. Constructor (Escuderías)
2. Drivers (Pilotos)

**Tabla de Hechos**:
1. Resultados (Results) - Contiene las métricas y eventos de carreras

**Relaciones Potenciales** (a verificar en el script completo):
- Resultados → Constructor (por ID de constructor)
- Resultados → Drivers (por ID de piloto)

> **Nota**: Las relaciones específicas deben verificarse en el script de carga completo del QVW.

---

## Generación de QVDs

El proceso genera los siguientes archivos QVD para optimización del rendimiento:

1. **constructor.qvd**
   - Tabla: Constructor
   - Propósito: Cache de datos de constructores

2. **Resultados.qvd**
   - Tabla: Resultados
   - Propósito: Cache de datos de resultados de carreras

---

## Advertencias y Consideraciones

### ⚠️ Puntos de Atención

1. **Calidad de Datos**: Verificar integridad de datos en el archivo Excel fuente
2. **Relaciones**: Confirmar claves primarias y foráneas entre tablas
3. **Duplicados**: Revisar posibles duplicados en resultados por carrera
4. **Codificación**: Verificar correcta codificación de caracteres especiales en nombres

### Recomendaciones

1. **Documentación de Campos**: Se recomienda documentar cada campo en el glosario
2. **Validación de Datos**: Implementar controles de calidad en la carga
3. **Optimización**: Considerar índices y agregaciones precalculadas
4. **Backup**: Mantener respaldo del archivo fuente Excel

---

## Diagrama de Arquitectura de Datos

```
┌─────────────────────────────────────┐
│   Formula1 - Historico.xlsx         │
│   (Archivo Excel)                   │
└──────────────┬──────────────────────┘
               │
       ┌───────┼───────┐
       │       │       │
       ▼       ▼       ▼
   ┌────────┐ ┌──────────┐ ┌─────────┐
   │Constructor│Results   │ Drivers  │
   │(Hoja 1)│ │(Hoja 2)  │ │(Hoja 3) │
   └────┬───┘ └────┬─────┘ └────┬────┘
        │          │             │
        ▼          ▼             ▼
   ┌─────────────────────────────────┐
   │    Modelo QlikView F1           │
   │    (F1 codigo y objetos.qvw)    │
   └────────────┬────────────────────┘
                │
       ┌────────┴────────┐
       │                 │
       ▼                 ▼
  ┌──────────┐     ┌──────────┐
  │constructor│    │Resultados│
  │   .qvd    │    │   .qvd   │
  └──────────┘     └──────────┘
```

---

## Metadatos del Análisis

- **Generado por**: Agente A00 - Análisis de cabeceras XML de QVDs
- **Método**: Análisis de archivo único en Set Pruebas
- **Fecha de Análisis**: 2026-05-05
- **Total de Archivos Analizados**: 1

---

## Próximos Pasos

1. Revisar script completo del QVW para identificar campos exactos
2. Documentar campos en el glosario
3. Validar relaciones entre tablas
4. Implementar pruebas de calidad de datos
5. Optimizar performance si es necesario
