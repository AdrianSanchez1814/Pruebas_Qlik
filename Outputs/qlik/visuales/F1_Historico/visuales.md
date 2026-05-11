# Visuales - F1 Histórico

## Información General del Proyecto

- **Proyecto**: F1 Histórico
- **QlikView Build**: 50689
- **Fecha Última Ejecución UTC**: 2026-04-21 17:19:52
- **Total de Archivos**: 3 archivos QVW analizados
- **Fecha de Análisis**: 2026-05-05

---

## Archivo 1: F1 codigo y objetos.qvw

### Información del Archivo
- **Ruta**: Set Pruebas/F1 codigo y objetos.qvw
- **Tamaño**: 688,384 bytes
- **Rol**: ETL + Visualización
- **Fuente de Datos**: Formula1 - Historico.xlsx (hojas: constructor, results, drivers)
- **QVDs Generados**: constructor.qvd, Resultados.qvd
- **Última Recarga**: 2026-04-21 17:19:52

### Estructura de Hojas

#### **Total de Páginas: 1**

---

### 📊 Hoja 1: Principal (Document\SH01)

**Objetos Totales**: 3 objetos visuales

#### Objetos Visuales

1. **CH01 - Tabla**
   - **Tipo**: Tabla Pivotante
   - **ObjectId**: Document\CH01
   - **Dimensiones**:
     - CiclicoG (Grupo Cíclico: constructorRef, driverRef)
   - **Expresiones**:
     - `Count({<campo={1}> positionOrder)` - Etiqueta: "Contar Set Analisis"
     - `Sum(positionOrder)` - Etiqueta: "Suma"
   - **Uso**: Análisis con Set Analysis y grupo cíclico

2. **LB01 - constructorRef**
   - **Tipo**: Cuadro de Lista
   - **ObjectId**: Document\LB01
   - **Campo**: constructorRef
   - **Uso**: Filtro de selección para constructor

3. **CH02 - Contar Set Analisis**
   - **Tipo**: Gráfico Mekko
   - **ObjectId**: Document\CH02
   - **Dimensiones**:
     - CiclicoG (Grupo Cíclico: constructorRef, driverRef)
   - **Expresiones**:
     - `Count({<campo={1}> positionOrder)` - Etiqueta: "Contar Set Analisis"
     - `Sum(positionOrder)` - Etiqueta: "Suma"
   - **Uso**: Visualización comparativa con Set Analysis

---

## Archivo 2: 1.qvw

### Información del Archivo
- **Ruta**: Set Pruebas/1.qvw
- **Tamaño**: Aproximadamente 688KB
- **Última Recarga**: No especificada

### Estructura de Hojas

#### **Total de Páginas: 1**

---

### 📊 Hoja 1: Principal (Document\SH01)

**Objetos Totales**: 4 objetos visuales

#### Objetos Visuales

1. **CH01 - Tabla**
   - **Tipo**: Tabla Pivotante
   - **ObjectId**: Document\CH01
   - **Dimensiones**:
     - CiclicoG (Grupo Cíclico)
   - **Expresiones**:
     - `Count({<campo={1}> positionOrder)` - Etiqueta: "Contar Set Analisis"
     - `Sum(positionOrder)` - Etiqueta: "Suma"

2. **LB01 - constructorRef**
   - **Tipo**: Cuadro de Lista
   - **ObjectId**: Document\LB01
   - **Campo**: constructorRef

3. **CH02 - Contar Set Analisis**
   - **Tipo**: Gráfico Mekko
   - **ObjectId**: Document\CH02
   - **Dimensiones**:
     - CiclicoG (Grupo Cíclico)
   - **Expresiones**:
     - `Count({<campo={1}> positionOrder)` - Etiqueta: "Contar Set Analisis"
     - `Sum(positionOrder)` - Etiqueta: "Suma"

4. **CH03 - Tabla**
   - **Tipo**: Tabla Pivotante
   - **ObjectId**: Document\CH03
   - **Dimensiones**:
     - JerarquicoG (Grupo Jerárquico)
   - **Expresiones**:
     - `Count({<campo={1}> positionOrder)` - Etiqueta: "Contar Set Analisis"
     - `Sum(positionOrder)` - Etiqueta: "Suma"

---

## Archivo 3: F1 - Prueba01.qvw

### Información del Archivo
- **Ruta**: Set Pruebas/F1 - Prueba01.qvw
- **Última Recarga**: 2026-04-22 12:29:20 (UTC: 2026-04-22 10:29:20)
- **Fuente de Datos**: Formula1 - Historico.xlsx

### Estructura de Hojas

#### **Total de Páginas: 2**

---

### 📊 Hoja 1: Pantalla 1 (Document\Panta1)

**Objetos Totales**: 10 objetos visuales

#### Objetos Visuales

1. **CH02 - Tabla Pivotante Grupo Ciclico**
   - **Tipo**: Tabla Simple
   - **ObjectId**: Document\CH02

2. **CH03 - Tabla Pivotante Jerarquico**
   - **Tipo**: Tabla Pivotante
   - **ObjectId**: Document\CH03

3. **LB34** (Lista de selección)
   - **Tipo**: Objeto de lista
   - **ObjectId**: Document\LB34

4. **CH04 - Grafico de barras**
   - **Tipo**: Gráfico de Barras
   - **ObjectId**: Document\CH04

5. **SB02** (Slider/Control)
   - **Tipo**: Control deslizante
   - **ObjectId**: Document\SB02

6. **MB01** (Multi-box)
   - **Tipo**: Cuadro múltiple
   - **ObjectId**: Document\MB01

7. **TB02** (Table Box)
   - **Tipo**: Tabla de datos
   - **ObjectId**: Document\TB02

8. **CH06 - Grafico combinado**
   - **Tipo**: Gráfico Combinado
   - **ObjectId**: Document\CH06
   - **Dimensiones**:
     - Grupo_Jerarquico
   - **Expresiones**: Métricas combinadas

9. **CH07 - Grafico indicador**
   - **Tipo**: Gráfico de Indicador
   - **ObjectId**: Document\CH07
   - **Dimensiones**:
     - Grupo_Jerarquico
   - **Expresiones**:
     - `Sum (points)` - Etiqueta: "Suma"
     - `Count({<campo={1}> positionOrder)` - Etiqueta: "Count Sert Analisis"
     - `sum((points-positionOrder)/positionOrder)` - Etiqueta: "% Expreesion"

10. **BU03** (Botón)
    - **Tipo**: Botón de acción
    - **ObjectId**: Document\BU03

---

### 📊 Hoja 2: Pantalla 2 (Document\SH02)

**Objetos Totales**: 16 objetos visuales

#### Objetos Visuales

1. **TX01** (Objeto de texto)
   - **Tipo**: Texto
   - **ObjectId**: Document\TX01

2. **BU01** (Botón 1)
   - **Tipo**: Botón de acción
   - **ObjectId**: Document\BU01

3. **BU02** (Botón 2)
   - **Tipo**: Botón de acción
   - **ObjectId**: Document\BU02

4. **IB01** (Input Box)
   - **Tipo**: Cuadro de entrada
   - **ObjectId**: Document\IB01

5. **SO01** (Search Object)
   - **Tipo**: Objeto de búsqueda
   - **ObjectId**: Document\SO01

6. **CH05 - Grafico de lineas**
   - **Tipo**: Gráfico de líneas
   - **ObjectId**: Document\CH05

7. **CH08 - Grafico de tarta**
   - **Tipo**: Gráfico de Tarta
   - **ObjectId**: Document\CH08
   - **Dimensiones**:
     - nationalityCostructor
   - **Expresiones**:
     - `Avg (position)`

8. **CH09** (Gráfico circular adicional)
   - **Tipo**: Gráfico (tipo no especificado)
   - **ObjectId**: Document\CH09
   - **Dimensiones**:
     - nationalityCostructor
   - **Expresiones**:
     - `Avg (position)`

9. **CH11** (Gráfico de métricas)
   - **Tipo**: Gráfico (tipo no especificado)
   - **ObjectId**: Document\CH11
   - **Dimensiones**:
     - constructorRef
   - **Expresiones**:
     - `Avg (position)` - Etiqueta: "position"
     - `Sum ([points])` - Etiqueta: "points"

10. **CH13** (Gráfico de análisis detallado)
    - **Tipo**: Gráfico (tipo no especificado)
    - **ObjectId**: Document\CH13
    - **Dimensiones**:
      - constructorRef
      - forename
    - **Expresiones**:
      - `Avg (position)` - Etiqueta: "position"
      - `Sum ([points])` - Etiqueta: "points"

11. **CH14** (Gráfico por nacionalidad)
    - **Tipo**: Gráfico (tipo no especificado)
    - **ObjectId**: Document\CH14
    - **Dimensiones**:
      - nationalityCostructor
    - **Expresiones**:
      - `Avg (position)`

12. **CH15** (Gráfico por nacionalidad 2)
    - **Tipo**: Gráfico (tipo no especificado)
    - **ObjectId**: Document\CH15
    - **Dimensiones**:
      - nationalityCostructor
    - **Expresiones**:
      - `Avg (position)`

13. **CH16** (Gráfico por nacionalidad 3)
    - **Tipo**: Gráfico (tipo no especificado)
    - **ObjectId**: Document\CH16
    - **Dimensiones**:
      - nationalityCostructor
    - **Expresiones**:
      - `Avg (position)`

14. **LA01** (Layout Object)
    - **Tipo**: Objeto de diseño
    - **ObjectId**: Document\LA01

15. **SL01** (Slider)
    - **Tipo**: Control deslizante
    - **ObjectId**: Document\SL01

16. **BM01** (Bookmark)
    - **Tipo**: Marcador
    - **ObjectId**: Document\BM01

---

## Resumen General de Visualización

### Distribución de Objetos por Aplicación

| Aplicación | Páginas | Objetos Totales | Gráficos | Tablas | Filtros/Controles |
|------------|---------|-----------------|----------|--------|-------------------|
| F1 codigo y objetos.qvw | 1 | 3 | 1 | 1 | 1 |
| 1.qvw | 1 | 4 | 1 | 2 | 1 |
| F1 - Prueba01.qvw | 2 | 26 | 11 | 2 | 13 |
| **TOTAL** | **4** | **33** | **13** | **5** | **15** |

### Tipos de Gráficos Utilizados

1. **Gráfico Mekko** - 2 instancias
2. **Gráfico de Barras** - 1 instancia
3. **Gráfico de Líneas** - 1 instancia
4. **Gráfico Combinado** - 1 instancia
5. **Gráfico de Indicador** - 1 instancia
6. **Gráfico de Tarta** - 1 instancia
7. **Gráficos de análisis múltiple** - 6 instancias
8. **Tabla Pivotante** - 4 instancias
9. **Tabla Simple** - 1 instancia

### Tipos de Controles Interactivos

1. **Cuadros de Lista** (Listbox) - 2 instancias
2. **Botones de Acción** - 4 instancias
3. **Controles Deslizantes** (Slider) - 2 instancias
4. **Cuadro Múltiple** (Multi-box) - 1 instancia
5. **Tabla de Datos** (Table Box) - 1 instancia
6. **Cuadro de Entrada** (Input Box) - 1 instancia
7. **Objeto de Búsqueda** - 1 instancia
8. **Objeto de Texto** - 1 instancia
9. **Layout Object** - 1 instancia
10. **Marcador** (Bookmark) - 1 instancia

---

## Análisis de Set Analysis

### Expresiones de Set Analysis Identificadas

Todas las aplicaciones utilizan expresiones de Set Analysis con la sintaxis:

```qlik
Count({<campo={1}> positionOrder)
```

Esta expresión filtra los datos donde el campo `campo` es igual a 1, aplicando un conteo condicional sobre `positionOrder`.

### Grupos Dimensionales

#### Grupo Cíclico (CiclicoG)
- **Campos**: constructorRef, driverRef
- **Tipo**: Cíclico
- **Uso**: Permite alternar entre dimensiones en gráficos

#### Grupo Jerárquico (JerarquicoG / Grupo_Jerarquico)
- **Campos**: constructorRef, driverRef
- **Tipo**: Jerárquico
- **Uso**: Navegación drill-down entre niveles

---

## Métricas y KPIs Principales

### Expresiones Comunes

1. **Conteos**:
   - `Count({<campo={1}> positionOrder)` - Conteo con Set Analysis
   
2. **Sumas**:
   - `Sum(positionOrder)` - Suma de posiciones
   - `Sum(points)` - Suma de puntos
   - `Sum([points])` - Suma de puntos (notación alternativa)

3. **Promedios**:
   - `Avg(position)` - Promedio de posiciones

4. **Cálculos Complejos**:
   - `sum((points-positionOrder)/positionOrder)` - Cálculo de porcentaje/variación

---

## Dimensiones Utilizadas

### Dimensiones Principales

1. **constructorRef** - Referencia del constructor
2. **driverRef** - Referencia del piloto
3. **nationalityCostructor** - Nacionalidad del constructor
4. **forename** - Nombre del piloto

### Grupos Dimensionales

- **CiclicoG**: Grupo cíclico (constructorRef ↔ driverRef)
- **JerarquicoG / Grupo_Jerarquico**: Grupo jerárquico (constructorRef → driverRef)

---

## Human Review Required

### ⚠️ Puntos que Requieren Revisión Manual

1. **Tipos de Gráfico Incompletos**:
   - Los objetos CH09, CH11, CH13, CH14, CH15, CH16 en "F1 - Prueba01.qvw" no tienen el tipo de gráfico específico documentado en los metadatos XML
   - **Recomendación**: Verificar visualmente en QlikView Desktop

2. **Propiedades Visuales**:
   - No se pudieron extraer colores, estilos, formatos de números ni propiedades de presentación
   - **Recomendación**: Documentar manualmente las propiedades estéticas

3. **Expresiones de CH05**:
   - El gráfico "Grafico de lineas" (CH05) no tiene expresiones documentadas en los metadatos
   - **Recomendación**: Revisar el archivo QVW para completar

4. **Acciones de Botones**:
   - Los botones BU01, BU02, BU03 no tienen documentadas sus acciones
   - **Recomendación**: Documentar las acciones asociadas (selecciones, navegación, etc.)

5. **Configuración de Controles**:
   - Los controles SB02, SL01, MB01, TB02 requieren documentación de sus configuraciones específicas
   - **Recomendación**: Verificar campos asociados y rangos de valores

6. **Bookmarks**:
   - Únicamente se identificó el bookmark `$LASTKNOWNSTATE` (estado por defecto)
   - **Recomendación**: Verificar si existen bookmarks adicionales definidos por usuarios

7. **Orden de Ejecución**:
   - Aunque el archivo `orden_ejecucion.json` lista solo "F1 codigo y objetos.qvw", se encontraron 3 archivos QVW
   - **Recomendación**: Actualizar el archivo de orden de ejecución si es necesario

8. **Nomenclatura de Objetos**:
   - Algunos objetos tienen nombres genéricos como "Tabla", "Gráfico"
   - **Recomendación**: Establecer convención de nombres más descriptiva

9. **Expresiones Duplicadas**:
   - Múltiples objetos utilizan las mismas expresiones de Set Analysis
   - **Recomendación**: Considerar crear variables para expresiones reutilizables

10. **Documentación de Uso**:
    - No hay descripciones sobre el propósito o caso de uso de cada hoja
    - **Recomendación**: Agregar contexto de negocio para cada dashboard

---

## Notas Técnicas

### Modelo de Datos Subyacente

Basado en los objetos visuales, el modelo utiliza:

- **Tabla principal**: Resultados (26,080 registros)
- **Dimensiones**: constructor, Drivers
- **Campos clave**: 
  - constructorId / constructorRef
  - driverId / driverRef
  - positionOrder
  - points
  - position

### Set Analysis

Patrón común detectado:
```qlik
Count({<campo={1}> positionOrder)
```

Esto indica un campo calculado `campo` que actúa como flag para filtrar registros.

### Almacenamiento QVD

El archivo principal genera:
- **constructor.qvd** - Datos de constructores
- **Resultados.qvd** - Datos de resultados

---

## Conclusiones

1. **Complejidad**: La aplicación "F1 - Prueba01.qvw" es la más completa con 2 páginas y 26 objetos
2. **Consistencia**: Hay redundancia en las aplicaciones "F1 codigo y objetos.qvw" y "1.qvw" que parecen versiones similares
3. **Set Analysis**: Uso extensivo de Set Analysis para filtrado condicional
4. **Grupos Dimensionales**: Implementación correcta de grupos cíclicos y jerárquicos para análisis flexible
5. **Interactividad**: Amplia gama de controles interactivos en "F1 - Prueba01.qvw"

### Recomendaciones de Mejora

1. Consolidar las aplicaciones similares (F1 codigo y objetos.qvw y 1.qvw)
2. Establecer nomenclatura estándar para objetos
3. Documentar el propósito de cada hoja y objeto
4. Crear variables para expresiones reutilizables
5. Agregar descripciones de ayuda para usuarios finales

---

**Fecha de Generación**: 2026-05-05  
**Generado por**: Agente de Extracción de Metadatos Qlik - Proyecto Aqualia  
**Versión del Documento**: 1.0
