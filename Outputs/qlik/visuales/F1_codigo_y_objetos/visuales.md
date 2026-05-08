# Visuales - F1 codigo y objetos.qvw

## Información General
- **Archivo QVW**: F1 codigo y objetos.qvw
- **Proyecto**: F1 Histórico
- **Orden de Ejecución**: 1
- **Rol**: ETL + visualización
- **Fuente de Datos**: Formula1 - Historico.xlsx (hojas: constructor, results, drivers)
- **Fecha Última Ejecución**: 2026-04-21 17:19:52 UTC
- **Tamaño**: 688384 bytes

---

## Resumen de Páginas
- **Total de Páginas**: 1
- **Página Principal**: Principal

---

## Detalle de Páginas y Objetos Visuales

### Página 1: Principal

**Objetos contenidos en esta página:**

#### 1. Tabla Pivotante (CH01)
- **Tipo**: Tabla Pivotante
- **Caption**: Tabla
- **Dimensiones**:
  - CiclicoG (Grupo Cíclico)
- **Expresiones**:
  - **Contar Set Analisis**: `Count({<campo={1}> positionOrder)`
  - **Suma**: `Sum(positionOrder)`

#### 2. Gráfico Mekko (CH02)
- **Tipo**: Gráfico Mekko
- **Caption**: Contar Set Analisis
- **Dimensiones**:
  - CiclicoG (Grupo Cíclico)
- **Expresiones**:
  - **Contar Set Analisis**: `Count({<campo={1}> positionOrder)`
  - **Suma**: `Sum(positionOrder)`

#### 3. Cuadro de Lista (LB01)
- **Tipo**: Cuadro de Lista
- **Caption**: constructorRef
- **Campo**: constructorRef

---

## Grupos Definidos

### Grupo Cíclico: CiclicoG
- **Tipo**: Cíclico (IsCyclic=true)
- **Campos**:
  - constructorRef
  - driverRef

### Grupo Jerárquico: JerarquicoG
- **Tipo**: Jerárquico (IsCyclic=false)
- **Campos**:
  - constructorRef
  - driverRef

---

## Análisis Set Analysis Detectado

Los siguientes objetos utilizan Set Analysis:
1. **CH01** - Expresión: `Count({<campo={1}> positionOrder)`
2. **CH02** - Expresión: `Count({<campo={1}> positionOrder)`

---

## Tablas de Datos Subyacentes

1. **constructor** (211 filas, 4 campos)
2. **Resultados** (26,080 filas, 18 campos)
3. **Drivers** (857 filas, 8 campos)

---

## QVDs Generados
- constructor.qvd
- Resultados.qvd

---

## Notas de Revisión

### Human review required

#### Suposiciones Realizadas
1. El campo "campo" en la expresión Set Analysis `{<campo={1}>}` parece ser un campo específico usado como filtro. Se requiere validación sobre el propósito y definición de este campo.
2. Se asume que CiclicoG permite la navegación alterna entre constructorRef y driverRef.
3. El Gráfico Mekko (CH02) tiene el mismo set de expresiones que la Tabla Pivotante (CH01).

#### Preguntas Abiertas
1. ¿Cuál es el campo específico referenciado en `{<campo={1}>}` en las expresiones de Set Analysis?
2. ¿Existe documentación sobre el propósito del Grupo Cíclico vs el Grupo Jerárquico?
3. ¿Se utiliza el objeto LB01 (constructorRef) como filtro principal para los demás objetos?
4. ¿Por qué el Gráfico Mekko y la Tabla Pivotante tienen expresiones idénticas? ¿Deberían mostrar información diferente?

#### Recomendaciones
1. Validar la sintaxis del Set Analysis - la expresión `Count({<campo={1}> positionOrder)` parece tener un paréntesis faltante.
2. Documentar el uso específico de los grupos cíclicos y jerárquicos en el contexto del negocio.
3. Considerar agregar descripciones (captions) más descriptivas a los objetos visuales para mejor comprensión del usuario final.
