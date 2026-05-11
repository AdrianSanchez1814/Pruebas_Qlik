# Expresiones y Fórmulas - F1 Histórico

## Aplicación: F1 codigo y objetos.qvw

### Página: Principal (SH01)

#### Objeto CH01 - Tabla Pivotante
**Tipo:** Tabla Pivotante

**Dimensiones:**
- CiclicoG (Grupo Cíclico: constructorRef, driverRef)

**Expresiones:**
1. **Contar Set Analisis**
   ```qlik
   Count({<campo={1}>} positionOrder)
   ```
   - Descripción: Cuenta registros de positionOrder con Set Analysis filtrando campo=1

2. **Suma**
   ```qlik
   Sum(positionOrder)
   ```
   - Descripción: Suma del campo positionOrder

---

#### Objeto CH02 - Gráfico Mekko  
**Tipo:** Gráfico Mekko

**Dimensiones:**
- CiclicoG (Grupo Cíclico: constructorRef, driverRef)

**Expresiones:**
1. **Contar Set Analisis**
   ```qlik
   Count({<campo={1}>} positionOrder)
   ```
   - Descripción: Cuenta registros con filtro Set Analysis

2. **Suma**
   ```qlik
   Sum(positionOrder)
   ```
   - Descripción: Suma de posiciones

---

#### Objeto LB01 - Cuadro de Lista
**Tipo:** Cuadro de Lista
**Campo:** constructorRef

---

### Grupos Dimensionales

#### CiclicoG (Grupo Cíclico)
**Campos:**
- constructorRef
- driverRef

**Tipo:** Cíclico (permite alternar entre las dimensiones)

---

#### JerarquicoG (Grupo Jerárquico)
**Campos:**
1. constructorRef (nivel superior)
2. driverRef (nivel inferior)

**Tipo:** Jerárquico (drill-down de constructor a driver)

---

## Archivo: F1 - Prueba01.qvw

### Página: Pantalla 1 (Panta1)

#### Objeto CH02 - Tabla Pivotante Grupo Cíclico
**Tipo:** Tabla Simple

**Dimensiones:**
- Grupo cíclico (constructorRef, driverRef)

---

#### Objeto CH03 - Tabla Pivotante Jerarquico
**Tipo:** Tabla Pivotante

**Dimensiones:**
- Grupo_Jerarquico (constructorRef → driverRef)

---

#### Objeto CH04 - Gráfico de Barras
**Tipo:** Gráfico de Barras

---

#### Objeto CH06 - Gráfico Combinado
**Tipo:** Gráfico Combinado

**Dimensiones:**
- Grupo_Jerarquico

---

#### Objeto CH07 - Gráfico Indicador
**Tipo:** Gráfico de Indicador

**Dimensiones:**
- Grupo_Jerarquico

**Expresiones:**
1. **Suma**
   ```qlik
   Sum(points)
   ```

2. **Count Set Analisis**
   ```qlik
   Count({<campo={1}>} positionOrder)
   ```

3. **% Expression**
   ```qlik
   sum((points-positionOrder)/positionOrder)
   ```
   - Descripción: Calcula el porcentaje de diferencia entre points y positionOrder

---

### Página: Pantalla 2 (SH02)

#### Objeto CH05 - Gráfico de Lineas
**Tipo:** Gráfico de líneas

---

#### Objeto CH08 - Gráfico de Tarta
**Tipo:** Gráfico de Tarta

**Dimensiones:**
- nationalityCostructor

**Expresiones:**
1. **Promedio Posición**
   ```qlik
   Avg(position)
   ```

---

#### Objeto CH09 - Gráfico
**Dimensiones:**
- nationalityCostructor

**Expresiones:**
1. **Promedio Posición**
   ```qlik
   Avg(position)
   ```

---

#### Objeto CH11 - Gráfico
**Dimensiones:**
- constructorRef

**Expresiones:**
1. **position**
   ```qlik
   Avg(position)
   ```

2. **points**
   ```qlik
   Sum([points])
   ```

---

#### Objeto CH13 - Gráfico
**Dimensiones:**
- constructorRef
- forename

**Expresiones:**
1. **position**
   ```qlik
   Avg(position)
   ```

2. **points**
   ```qlik
   Sum([points])
   ```

---

#### Objeto CH14, CH15, CH16 - Gráficos
**Dimensiones:**
- nationalityCostructor

**Expresiones:**
1. **Promedio Posición**
   ```qlik
   Avg(position)
   ```

---

## Archivo: 1.qvw

### Página: Principal (SH01)

#### Objeto CH01 - Tabla Pivotante
**Tipo:** Tabla Pivotante

**Dimensiones:**
- CiclicoG (Grupo Cíclico)

**Expresiones:**
1. **Contar Set Analisis**
   ```qlik
   Count({<campo={1}>} positionOrder)
   ```

2. **Suma**
   ```qlik
   Sum(positionOrder)
   ```

---

#### Objeto CH02 - Gráfico Mekko
**Tipo:** Gráfico Mekko

**Dimensiones:**
- CiclicoG

**Expresiones:**
1. **Contar Set Analisis**
   ```qlik
   Count({<campo={1}>} positionOrder)
   ```

2. **Suma**
   ```qlik
   Sum(positionOrder)
   ```

---

#### Objeto CH03 - Tabla
**Tipo:** Tabla Pivotante

**Dimensiones:**
- JerarquicoG (Grupo Jerárquico)

**Expresiones:**
1. **Contar Set Analisis**
   ```qlik
   Count({<campo={1}>} positionOrder)
   ```

2. **Suma**
   ```qlik
   Sum(positionOrder)
   ```

---

## Variables del Sistema

Todas las aplicaciones utilizan las siguientes variables de configuración regional:

- **ThousandSep:** . (punto)
- **DecimalSep:** , (coma)
- **MoneyFormat:** #.##0,00 €;-#.##0,00 €
- **TimeFormat:** h:mm:ss
- **DateFormat:** D/M/YYYY
- **TimestampFormat:** D/M/YYYY h:mm:ss[.fff]
- **FirstWeekDay:** 0 (Lunes)
- **CollationLocale:** es-ES
- **MonthNames:** ene;feb;mar;abr;may;jun;jul;ago;sept;oct;nov;dic
- **LongMonthNames:** enero;febrero;marzo;abril;mayo;junio;julio;agosto;septiembre;octubre;noviembre;diciembre
- **DayNames:** lun;mar;mié;jue;vie;sáb;dom
- **LongDayNames:** lunes;martes;miércoles;jueves;viernes;sábado;domingo

---

## Notas Importantes

1. **Set Analysis Recurrente:** La expresión `Count({<campo={1}>} positionOrder)` aparece en múltiples objetos, filtrando por un campo llamado "campo" con valor 1
2. **Grupos Dimensionales:** Se utilizan tanto grupos cíclicos como jerárquicos para navegación flexible entre constructorRef y driverRef
3. **Cálculos de Agregación:** Se utilizan principalmente funciones Sum(), Count() y Avg()
4. **Formato Regional:** Todas las aplicaciones están configuradas para español de España (es-ES)