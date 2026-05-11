# Human Review Required - F1 Histórico

## Fecha: 2026-05-05

## Decisiones Pendientes

### 1. Tabla Drivers No Relacionada
**Problema:** La tabla Drivers está cargada en el modelo pero no tiene relación explícita con otras tablas.

**Opciones:**
- A) Establecer relación mediante driverId con Resultados
- B) Eliminar la tabla si no se está usando
- C) Mantener como está si hay una razón de negocio

**Acción Requerida:** Verificar con el negocio si Drivers se usa y cómo debe relacionarse

---

### 2. Campos Desnormalizados en Resultados
**Problema:** Resultados contiene campos de Drivers (driverRef, code, forename, surname, dob, nationalityDriver)

**Opciones:**
- A) Eliminar campos desnormalizados y usar relación
- B) Mantener por rendimiento (si es crítico)
- C) Crear vista que combine ambas tablas

**Acción Requerida:** Decidir estrategia de normalización para Power BI

---

### 3. Tabla Dim_Race Faltante
**Problema:** raceId existe en Resultados pero no hay tabla dimensional

**Pregunta:** ¿Debemos crear Dim_Race desde:
- A) El mismo archivo Excel (si tiene hoja races)
- B) Fuente externa
- C) No es necesaria

**Acción Requerida:** Confirmar si se requiere tabla de carreras

---

### 4. Campo "campo" en Set Analysis
**Problema:** Las expresiones usan Count({<campo={1}>} positionOrder) pero "campo" no aparece en el modelo

**Pregunta:** ¿Es este campo:
- A) Un campo que falta en la metadata
- B) Un error en las expresiones
- C) Un campo calculado

**Acción Requerida:** Validar existencia y propósito del campo

---

## Validaciones Necesarias

1. **Consistencia de Datos**
   - Verificar que 26,080 registros en Resultados es correcto
   - Validar que statusId no necesita tabla dimensional
   - Confirmar cardinalidades de campos clave

2. **Uso de Grupos Dimensionales**
   - Validar si CiclicoG y JerarquicoG son usados activamente
   - Determinar cómo replicar en Power BI

3. **QVDs Generados**
   - Confirmar si constructor.qvd y Resultados.qvd se usan en otros procesos
   - Validar ubicación de almacenamiento

---

## Supuestos Realizados

1. **Esquema Estrella:** Se asumió que el modelo debe convertirse a estrella para Power BI
2. **Normalización:** Se recomienda eliminar desnormalización de Drivers
3. **Relaciones:** Se asumió relación many-to-one entre Resultados y Constructor
4. **Naming:** Se propuso convención Dim_/Fact_ para Power BI

---

## Archivos Generados

- `Outputs/qlik/expressions/F1_Historico/expresiones.md` - Documentación de fórmulas
- `Outputs/qlik/scripts/F1_Historico/metadata.json` - Metadata del modelo
- `Outputs/qlik/inventory/F1_Historico/inventory.json` - Inventario completo

---

## Próximos Pasos

1. Revisar y validar decisiones pendientes
2. Confirmar estrategia de normalización
3. Validar existencia del campo "campo"
4. Aprobar esquema estrella propuesto
5. Iniciar migración a Power BI