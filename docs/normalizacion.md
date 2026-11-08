# Normalización y desnormalización controlada

## 1. Dependencias funcionales y comprobación de 3FN (6 tablas)

### 1.1 `clinica.persona`
- **Clave candidata / PK:** `id_persona`, `curp`, `correo`
- **Dependencias funcionales:**
  - `id_persona -> {nombres, apellidos, fecha_nacimiento, curp, telefono, correo, direccion}`
  - `curp -> id_persona`, `correo -> id_persona`
- **1FN:** Todos los atributos son atómicos (sin listas ni grupos repetitivos).
- **2FN:** La PK es simple (`id_persona`), no existen dependencias parciales.
- **3FN:** Todos los determinantes (`id_persona`, `curp`, `correo`) son superclaves; no hay dependencias transitivas (p. ej. no se almacena edad derivada ni código postal separado que determine ciudad).

### 1.2 `clinica.paciente`
- **Clave candidata / PK:** `id_persona`
- **Dependencias funcionales:**
  - `id_persona -> {id_aseguradora, id_responsable, numero_poliza, tipo_sangre}`
- **1FN:** Atributos atómicos.
- **2FN:** PK simple (`id_persona`).
- **3FN:** El porcentaje de cobertura depende de `id_aseguradora` y vive en `clinica.aseguradora`, no aquí; por eso no existe dependencia transitiva `id_persona -> id_aseguradora -> porcentaje_cobertura`.

### 1.3 `clinica.cita`
- **Claves candidatas:** `id_cita` (PK); `(id_medico, fecha_hora)` y `(id_paciente, fecha_hora)` cuando `estado <> 'cancelada'`.
- **Dependencias funcionales:**
  - `id_cita -> {id_paciente, id_medico, id_especialidad, id_sede, fecha_hora, duracion_min, estado, fecha_creacion}`
- **1FN:** Cada columna contiene un solo valor.
- **2FN:** PK simple (`id_cita`).
- **3FN:** La tarifa del médico vive en `clinica.medico` y los nombres en `clinica.persona`; ningún atributo no clave depende de otro atributo no clave.

### 1.4 `clinica.detalle_receta` (entidad débil)
- **Claves candidatas:** `(id_receta, num_linea)` (PK) y `(id_receta, id_medicamento)` (UNIQUE).
- **Dependencias funcionales:**
  - `(id_receta, num_linea) -> {id_medicamento, dosis, frecuencia, duracion_dias, cantidad}`
  - `(id_receta, id_medicamento) -> num_linea`
- **1FN:** Cada línea representa un único medicamento con dosis, frecuencia y cantidad atómicas.
- **2FN:** Ningún atributo no clave depende solo de `id_receta` o solo de `num_linea`; todos dependen de la clave compuesta completa.
- **3FN:** El precio unitario y principio activo del medicamento viven en `clinica.medicamento`, evitando dependencias transitivas desde `id_medicamento`.

### 1.5 `clinica.lote_inventario`
- **Claves candidatas:** `id_lote` (PK) y `(id_medicamento, id_sede, numero_lote)` (UNIQUE).
- **Dependencias funcionales:**
  - `id_lote -> {id_medicamento, id_sede, numero_lote, fecha_vencimiento, stock, precio_costo}`
  - `(id_medicamento, id_sede, numero_lote) -> id_lote`
- **1FN:** Valores atómicos por lote y sede.
- **2FN:** PK simple (`id_lote`).
- **3FN:** Todos los determinantes (`id_lote` y la terna única) son superclaves; los datos del catálogo de medicamento y sede están en sus tablas respectivas.

### 1.6 `clinica.horario_medico`
- **Claves candidatas:** `id_horario` (PK) y `(id_medico, id_sede, dia_semana, hora_inicio)` (UNIQUE).
- **Dependencias funcionales:**
  - `id_horario -> {id_medico, id_sede, dia_semana, hora_inicio, hora_fin}`
  - `(id_medico, id_sede, dia_semana, hora_inicio) -> {id_horario, hora_fin}`
- **1FN:** Campos atómicos (un bloque horario continuo por fila).
- **2FN:** PK simple (`id_horario`).
- **3FN:** No existen dependencias transitivas entre atributos no clave.

---

## 2. Evaluación en FNBC

Una relación está en Forma Normal de Boyce-Codd (FNBC) si para toda dependencia funcional no trivial `X -> Y`, `X` es una superclave.

1. **`clinica.horario_medico`:**
   - Dependencias no triviales:
     - `id_horario -> {id_medico, id_sede, dia_semana, hora_inicio, hora_fin}` (`id_horario` es superclave).
     - `(id_medico, id_sede, dia_semana, hora_inicio) -> {id_horario, hora_fin}` (es superclave por la restricción `UNIQUE`).
   - Además, el trigger `trg_validar_solapamiento_horario` garantiza que un médico no tenga dos bloques traslapados en el mismo día, de modo que `(id_medico, dia_semana, hora_inicio)` también determina unívocamente al registro.
   - **Resultado:** Cumple **FNBC**.

2. **`clinica.medico_especialidad`:**
   - Atributos: `(id_medico, id_especialidad, fecha_certificacion)`.
   - Única dependencia funcional no trivial: `(id_medico, id_especialidad) -> fecha_certificacion`.
   - El determinante `(id_medico, id_especialidad)` es la PK completa, por lo tanto es superclave.
   - **Resultado:** Cumple **FNBC**.

---

## 3. Desnormalización o redundancia controlada (RN-15 y RN-16)

En **`clinica.factura`** y **`clinica.detalle_factura`** se mantiene redundancia controlada intencional:

1. **`detalle_factura.precio_unitario_venta`** y **`dispensacion_lote.precio_unitario_venta`:**
   - Aunque `clinica.medicamento.precio_unitario` y `clinica.medico.tarifa_consulta` ya existen en sus catálogos, se guarda una copia del precio vigente al momento de la venta.
   - **Motivo (RN-15):** Si en el futuro cambia el precio de un medicamento o la tarifa de un médico, las facturas históricas no deben recalcularse ni alterar su total contable.
2. **`factura.porcentaje_cobertura_aplicado`, `subtotal`, `monto_seguro`, `monto_paciente`, `total`, `saldo_pendiente`:**
   - Podrían calcularse sumando `detalle_factura` y `pago` o leyendo `aseguradora.porcentaje_cobertura`, pero se materializan en `factura`.
   - **Motivo:** Preserva la cobertura exacta vigente al emitir la factura (RN-16), evita sumar miles de líneas en cada cobro o consulta de saldo (RN-17) y permite bloquear directamente la fila de `factura` con `FOR UPDATE` al registrar pagos concurrentes.
   - **Control de integridad:** Las restricciones `CHECK (total = subtotal AND monto_seguro + monto_paciente = total)` y el trigger `trg_procesar_pago` garantizan que nunca queden desfasados.
