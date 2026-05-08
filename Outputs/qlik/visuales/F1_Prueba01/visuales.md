# Visuales - F1 - Prueba01.qvw

## Información General
- **Archivo QVW**: F1 - Prueba01.qvw
- **Proyecto**: F1 Histórico
- **Fecha Última Recarga**: 2026-04-22 10:29:20 UTC
- **Fuente de Datos**: Formula1 - Historico.xlsx
- **Ubicación Original**: C:\Users\albertogonzalez1\Desktop\Set de pruebas\

---

## Resumen de Páginas
- **Total de Páginas**: 2
- **Página 1**: Pantalla 1
- **Página 2**: Pantalla 2

---

## Detalle de Páginas y Objetos Visuales

### Página 1: Pantalla 1

**Total de objetos en esta página**: 10

#### 1. Tabla Simple (CH02)
- **Tipo**: Tabla Simple
- **Caption**: Tabla Pivotante Grupo Ciclico

#### 2. Tabla Pivotante (CH03)
- **Tipo**: Tabla Pivotante
- **Caption**: Tabla Pivotante Jerarquico

#### 3. Gráfico de Barras (CH04)
- **Tipo**: Gráfico de Barras
- **Caption**: Grafico de barras
- **Dimensión**: Grupo_Jerarquico
- **Expresiones**:
  - **Suma**: `Sum (points)`
  - **Count Set Analisis**: `Count({<campo={1}> positionOrder)`
  - **% Expresion**: `sum((points-positionOrder)/positionOrder)`

#### 4. Lista (LB34)
- **Tipo**: List Box
- **Identificador**: LB34

#### 5. Selector (SB02)
- **Tipo**: Selector
- **Identificador**: SB02

#### 6. Multi Box (MB01)
- **Tipo**: Multi Box
- **Identificador**: MB01

#### 7. Table Box (TB02)
- **Tipo**: Table Box
- **Identificador**: TB02

#### 8. Gráfico Combinado (CH06)
- **Tipo**: Gráfico Combinado
- **Caption**: Grafico combinado
- **Dimensión**: Grupo_Jerarquico
- **Expresiones**:
  - **Suma**: `Sum (points)`
  - **Count Set Analisis**: `Count({<campo={1}> positionOrder)`
  - **% Expresion**: `sum((points-positionOrder)/positionOrder)`

#### 9. Gráfico de Indicador (CH07)
- **Tipo**: Gráfico de Indicador
- **Caption**: Grafico indicador
- **Dimensión**: Grupo_Jerarquico
- **Expresiones**:
  - **Suma**: `Sum (points)`
  - **Count Set Analisis**: `Count({<campo={1}> positionOrder)`
  - **% Expresion**: `sum((points-positionOrder)/positionOrder)`

#### 10. Botón (BU03)
- **Tipo**: Botón
- **Identificador**: BU03

---

### Página 2: Pantalla 2

**Total de objetos en esta página**: 16

#### 1. Text Object (TX01)
- **Tipo**: Text Object
- **Identificador**: TX01

#### 2. Botón 1 (BU01)
- **Tipo**: Botón
- **Identificador**: BU01

#### 3. Botón 2 (BU02)
- **Tipo**: Botón
- **Identificador**: BU02

#### 4. Input Box (IB01)
- **Tipo**: Input Box
- **Identificador**: IB01

#### 5. Search Object (SO01)
- **Tipo**: Search Object
- **Identificador**: SO01

#### 6. Gráfico de Líneas (CH05)
- **Tipo**: Gráfico de líneas
- **Caption**: Grafico de lineas
- **Dimensión**: nationalityCostructor
- **Expresión**: `Avg (position)`

#### 7. Gráfico de Tarta (CH08)
- **Tipo**: Gráfico de Tarta
- **Caption**: Grafico de tarta
- **Dimensión**: nationalityCostructor
- **Expresión**: `Avg (position)`

#### 8. Gráfico (CH09)
- **Tipo**: Gráfico
- **Caption**: (Sin especificar en metadata)
- **Dimensión**: nationalityCostructor
- **Expresión**: `Avg (position)`

#### 9. Gráfico de Combo (CH11)
- **Tipo**: Gráfico de Combo
- **Caption**: (Sin especificar en metadata)
- **Dimensiones**: constructorRef
- **Expresiones**:
  - **position**: `Avg (position)`
  - **points**: `Sum ([points])`

#### 10. Gráfico Multi-Dimensión (CH13)
- **Tipo**: Gráfico
- **Caption**: (Sin especificar en metadata)
- **Dimensiones**: 
  - constructorRef
  - forename
- **Expresiones**:
  - **position**: `Avg (position)`
  - **points**: `Sum ([points])`

#### 11. Gráfico (CH14)
- **Tipo**: Gráfico
- **Caption**: (Sin especificar en metadata)
- **Dimensión**: nationalityCostructor
- **Expresión**: `Avg (position)`

#### 12. Gráfico (CH15)
- **Tipo**: Gráfico
- **Caption**: (Sin especificar en metadata)
- **Dimensión**: nationalityCostructor
- **Expresión**: `Avg (position)`

#### 13. Gráfico (CH16)
- **Tipo**: Gráfico
- **Caption**: (Sin especificar en metadata)
- **Dimensión**: nationalityCostructor
- **Expresión**: `Avg (position)`

#### 14. Line Area (LA01)
- **Tipo**: Line Area
- **Identificador**: LA01

#### 15. Slider (SL01)
- **Tipo**: Slider/Deslizador
- **Identificador**: SL01

#### 16. Bookmark (BM01)
- **Tipo**: Bookmark Object
- **Identificador**: BM01

---

## Grupos Definidos

### Grupo Jerárquico: Grupo_Jerarquico
- **Tipo**: Jerárquico (IsCyclic=false)
- **Campos**:
  - constructorRef
  - driverRef
- **Uso**: Utilizado en CH04, CH06, CH07 de Pantalla 1

### Grupo Cíclico: Grupo_Ciclico
- **Tipo**: Cíclico (IsCyclic=true)
- **Campos**:
  - constructorRef
  - driverRef
- **Uso**: Utilizado en tablas de Pantalla 1

---

## Análisis Set Analysis Detectado

Los siguientes objetos utilizan Set Analysis con la expresión `Count({<campo={1}> positionOrder)`:
1. **CH04** - Gráfico de Barras (Pantalla 1)
2. **CH06** - Gráfico Combinado (Pantalla 1)
3. **CH07** - Gráfico de Indicador (Pantalla 1)

**Expresión común**: `Count({<campo={1}> positionOrder)`

---

## Tablas de Datos Subyacentes

1. **constructor** (211 filas, 4 campos, 844 bytes)
2. **Resultados** (26,080 filas, 24 campos, 652,126 bytes)

---

## QVDs Generados
- constructor.qvd
- Resultados.qvd

---

## Campos Principales Utilizados

### Dimensiones:
- constructorRef
- driverRef
- nationalityCostructor
- forename

### Métricas:
- position
- points
- positionOrder

---

## Notas de Revisión

### Human review required

#### Suposiciones Realizadas
1. Los objetos sin caption detallado (CH09, CH11, CH13, CH14, CH15, CH16) se asumen como gráficos de análisis complementarios.
2. Se asume que "nationalityCostructor" es la nacionalidad del constructor (posible error tipográfico de "Constructor").
3. El campo "campo" en Set Analysis `{<campo={1}>}` se asume como un campo de filtro condicional, pero requiere validación.
4. La expresión `sum((points-positionOrder)/positionOrder)` calcula un porcentaje de variación, se asume como métrica de rendimiento.

#### Preguntas Abiertas
1. **Campo en Set Analysis**: ¿Cuál es el propósito específico del campo "campo" usado en `{<campo={1}>}`? ¿Es un flag de validación?
2. **Typo en campo**: ¿"nationalityCostructor" debería ser "nationalityConstructor"? Requiere verificación en datos fuente.
3. **Objetos sin Caption**: ¿CH09, CH14, CH15, CH16 tienen propósitos específicos o son experimentales?
4. **Diferencia entre grupos**: ¿Cuál es el caso de uso específico para Grupo_Ciclico vs Grupo_Jerarquico en el contexto del negocio?
5. **Objetos de interacción**: ¿Qué acciones realizan los botones BU01, BU02, BU03?
6. **Input Box (IB01)**: ¿Qué variable o campo está vinculado a este input box?
7. **Slider (SL01)**: ¿Qué dimensión o rango controla el slider?

#### Errores Potenciales Detectados
1. **Sintaxis Set Analysis**: La expresión `Count({<campo={1}> positionOrder)` parece incompleta - falta cerrar paréntesis en la función Count.
2. **Tipografía**: "nationalityCostructor" probablemente debería ser "nationalityConstructor".

#### Recomendaciones
1. **Documentación de Captions**: Agregar captions descriptivos a todos los objetos gráficos para mejor experiencia de usuario.
2. **Validar Set Analysis**: Revisar y corregir la sintaxis de las expresiones Set Analysis.
3. **Estandarizar nombres**: Corregir posibles errores tipográficos en nombres de campos.
4. **Documentar interacciones**: Crear documentación de las acciones de los botones y objetos interactivos.
5. **Consolidar gráficos similares**: Varios gráficos (CH09, CH14, CH15, CH16) usan la misma expresión `Avg(position)` con la misma dimensión. Considerar si todos son necesarios o si pueden consolidarse.
6. **Uso de bookmarks**: Documentar el propósito del bookmark object (BM01).

#### Análisis de Complejidad
- **Pantalla 1**: Complejidad Media - Enfocada en análisis jerárquico con grupos definidos
- **Pantalla 2**: Complejidad Alta - Mayor variedad de tipos de objetos y elementos de interacción

#### Observaciones de Diseño
- La Pantalla 1 se enfoca en análisis estructurado con grupos jerárquicos y cíclicos
- La Pantalla 2 incluye más elementos de interacción y navegación (botones, input box, search, slider)
- Existe redundancia en algunos gráficos de la Pantalla 2 que podría optimizarse
