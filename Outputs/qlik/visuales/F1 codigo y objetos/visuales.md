# Visuales - F1 codigo y objetos

## Información General
- **Aplicación**: F1 codigo y objetos.qvw
- **Proyecto**: F1 Histórico
- **Fuente de datos**: Formula1 - Historico.xlsx (hojas: constructor, results, drivers)
- **Última ejecución**: 2026-05-06 15:19:25 UTC
- **Rol**: ETL + visualización

---

## Resumen Ejecutivo

### Número de Páginas (Sheets)
**Total: 1 página**

### Distribución de Objetos por Página
- **Página Principal**: 3 objetos visuales

---

## Detalle de Páginas y Objetos

### Página 1: Principal

**Título**: Principal  
**ID**: Document\SH01  
**Número de objetos**: 3

#### Objetos Visuales en esta página:

##### 1. Objeto CH01
- **Tipo**: Tabla Pivotante
- **Caption**: Tabla
- **Dimensiones**:
  - CiclicoG (Grupo Cíclico)
- **Expresiones**:
  - **Contar Set Analisis**: `Count({<campo={1}> positionOrder})`
  - **Suma**: `Sum(positionOrder)`

##### 2. Objeto LB01
- **Tipo**: Cuadro de Lista
- **Caption**: constructorRef
- **Campo**: constructorRef

##### 3. Objeto CH02
- **Tipo**: Gráfico Mekko
- **Caption**: Contar Set Analisis
- **Dimensiones**:
  - CiclicoG (Grupo Cíclico)
- **Expresiones**:
  - **Contar Set Analisis**: `Count({<campo={1}> positionOrder})`
  - **Suma**: `Sum(positionOrder)`

---

## Grupos Utilizados

### Grupos Cíclicos
1. **CiclicoG**
   - Campos: constructorRef, driverRef
   - Tipo: Cíclico

### Grupos Jerárquicos
1. **JerarquicoG**
   - Campos: constructorRef, driverRef
   - Tipo: Jerárquico

---

## Tipos de Visualizaciones Utilizadas

| Tipo de Objeto | Cantidad |
|----------------|----------|
| Tabla Pivotante | 1 |
| Cuadro de Lista | 1 |
| Gráfico Mekko | 1 |
| **Total** | **3** |

---

## Expresiones de Set Analysis

Las siguientes expresiones de Set Analysis fueron identificadas en la aplicación:

1. `Count({<campo={1}> positionOrder)`
   - Utilizada en: CH01, CH02
   - Propósito: Contar registros con filtro en campo=1

---

## Campos Utilizados en Visuales

### Dimensiones
- constructorRef
- driverRef (como parte de grupos)

### Métricas
- positionOrder
- points (referencias en otras expresiones no mostradas en pantalla principal)

---

## Decisiones y Consideraciones

### Human review required

1. **Grupos Definidos pero no Todos Visibles**: 
   - Se detectó un grupo jerárquico "JerarquicoG" definido en el modelo pero no utilizado explícitamente en la página Principal
   - Revisar si existen otras páginas o si este grupo está pendiente de implementación

2. **Set Analysis**:
   - La expresión `{<campo={1}>}` utiliza un campo llamado "campo" que parece ser un campo auxiliar o de control
   - Confirmar la lógica de negocio detrás de este filtro

3. **Datos Cargados**:
   - La aplicación carga datos de 3 tablas: constructor (211 filas), Resultados (26,080 filas), y Drivers (857 filas)
   - Verificar que las relaciones entre tablas sean correctas

4. **QVDs Generados**:
   - constructor.qvd
   - Resultados.qvd
   - Estos QVDs se almacenan para uso posterior

---

## Notas Técnicas

- **QlikView Build**: 50689
- **Tamaño del archivo**: 688,384 bytes
- **Tablas en modelo**: 3 tablas principales + tablas de sistema
- **Variables detectadas**: ErrorMode, StripComments, OpenUrlTimeout, ScriptError (variables reservadas del sistema)

---

## Metadata del Documento

- **GenerateLogfile**: false
- **HasSectionAccess**: false
- **DynamicReduceData**: false
- **Última recarga**: 2026-05-06 17:19:25 (local) / 2026-05-06 15:19:25 (UTC)

---

*Documento generado automáticamente por el agente de extracción de metadata de Qlik para el proyecto Aqualia*
