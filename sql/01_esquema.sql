DROP SCHEMA IF EXISTS clinica CASCADE;
CREATE SCHEMA clinica;

CREATE TABLE clinica.sede (
    id_sede SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    direccion VARCHAR(200) NOT NULL,
    telefono VARCHAR(20) NOT NULL
);

CREATE TABLE clinica.aseguradora (
    id_aseguradora SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL UNIQUE,
    porcentaje_cobertura NUMERIC(5,2) NOT NULL CHECK (porcentaje_cobertura BETWEEN 0 AND 100),
    telefono VARCHAR(20) NOT NULL
);

CREATE TABLE clinica.persona (
    id_persona SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento <= CURRENT_DATE),
    curp VARCHAR(18) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    direccion VARCHAR(200) NOT NULL
);

CREATE TABLE clinica.paciente (
    id_persona INT PRIMARY KEY REFERENCES clinica.persona(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_aseguradora INT REFERENCES clinica.aseguradora(id_aseguradora) ON DELETE SET NULL ON UPDATE CASCADE,
    id_responsable INT REFERENCES clinica.paciente(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    numero_poliza VARCHAR(50),
    tipo_sangre VARCHAR(5) CHECK (tipo_sangre IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    CHECK (id_responsable IS NULL OR id_responsable <> id_persona)
);

CREATE TABLE clinica.empleado (
    id_persona INT PRIMARY KEY REFERENCES clinica.persona(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    tipo_empleado VARCHAR(20) NOT NULL CHECK (tipo_empleado IN ('medico', 'recepcionista', 'farmaceutico')),
    fecha_contratacion DATE NOT NULL,
    salario NUMERIC(10,2) NOT NULL CHECK (salario > 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE clinica.medico (
    id_persona INT PRIMARY KEY REFERENCES clinica.empleado(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
    cedula_profesional VARCHAR(30) NOT NULL UNIQUE,
    tarifa_consulta NUMERIC(10,2) NOT NULL CHECK (tarifa_consulta > 0)
);

CREATE TABLE clinica.recepcionista (
    id_persona INT PRIMARY KEY REFERENCES clinica.empleado(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
    turno VARCHAR(15) NOT NULL CHECK (turno IN ('matutino', 'vespertino', 'mixto')),
    extension VARCHAR(10) NOT NULL
);

CREATE TABLE clinica.farmaceutico (
    id_persona INT PRIMARY KEY REFERENCES clinica.empleado(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
    licencia_sanitaria VARCHAR(30) NOT NULL UNIQUE,
    id_sede_asignada INT NOT NULL REFERENCES clinica.sede(id_sede) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE clinica.especialidad (
    id_especialidad SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(250) NOT NULL
);

CREATE TABLE clinica.medico_especialidad (
    id_medico INT NOT NULL REFERENCES clinica.medico(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
    id_especialidad INT NOT NULL REFERENCES clinica.especialidad(id_especialidad) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_certificacion DATE NOT NULL,
    PRIMARY KEY (id_medico, id_especialidad)
);

CREATE TABLE clinica.horario_medico (
    id_horario SERIAL PRIMARY KEY,
    id_medico INT NOT NULL REFERENCES clinica.medico(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
    id_sede INT NOT NULL REFERENCES clinica.sede(id_sede) ON DELETE RESTRICT ON UPDATE CASCADE,
    dia_semana SMALLINT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_inicio TIME NOT NULL CHECK (EXTRACT(MINUTE FROM hora_inicio) IN (0, 30) AND EXTRACT(SECOND FROM hora_inicio) = 0),
    hora_fin TIME NOT NULL CHECK (EXTRACT(MINUTE FROM hora_fin) IN (0, 30) AND EXTRACT(SECOND FROM hora_fin) = 0),
    CHECK (hora_fin > hora_inicio),
    UNIQUE (id_medico, id_sede, dia_semana, hora_inicio)
);

CREATE TABLE clinica.cita (
    id_cita SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL REFERENCES clinica.paciente(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_medico INT NOT NULL REFERENCES clinica.medico(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_especialidad INT NOT NULL REFERENCES clinica.especialidad(id_especialidad) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_sede INT NOT NULL REFERENCES clinica.sede(id_sede) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_hora TIMESTAMP NOT NULL CHECK (EXTRACT(MINUTE FROM fecha_hora) IN (0, 30) AND EXTRACT(SECOND FROM fecha_hora) = 0),
    duracion_min SMALLINT NOT NULL DEFAULT 30 CHECK (duracion_min = 30),
    estado VARCHAR(20) NOT NULL DEFAULT 'programada' CHECK (estado IN ('programada', 'confirmada', 'atendida', 'cancelada', 'no_asistio')),
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (id_medico, id_especialidad) REFERENCES clinica.medico_especialidad(id_medico, id_especialidad) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE UNIQUE INDEX uq_cita_medico_bloque
    ON clinica.cita (id_medico, fecha_hora)
    WHERE estado <> 'cancelada';

CREATE UNIQUE INDEX uq_cita_paciente_bloque
    ON clinica.cita (id_paciente, fecha_hora)
    WHERE estado <> 'cancelada';

CREATE TABLE clinica.consulta (
    id_consulta SERIAL PRIMARY KEY,
    id_cita INT NOT NULL UNIQUE REFERENCES clinica.cita(id_cita) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_consulta TIMESTAMP NOT NULL DEFAULT now(),
    motivo_consulta VARCHAR(250) NOT NULL,
    presion_arterial VARCHAR(15) NOT NULL,
    frecuencia_cardiaca SMALLINT NOT NULL CHECK (frecuencia_cardiaca BETWEEN 30 AND 240),
    temperatura NUMERIC(4,1) NOT NULL CHECK (temperatura BETWEEN 30.0 AND 45.0),
    peso_kg NUMERIC(5,2) NOT NULL CHECK (peso_kg > 0),
    notas_clinicas TEXT NOT NULL
);

CREATE TABLE clinica.diagnostico_catalogo (
    id_diagnostico SERIAL PRIMARY KEY,
    codigo_cie10 VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(300) NOT NULL
);

CREATE TABLE clinica.consulta_diagnostico (
    id_consulta INT NOT NULL REFERENCES clinica.consulta(id_consulta) ON DELETE CASCADE ON UPDATE CASCADE,
    id_diagnostico INT NOT NULL REFERENCES clinica.diagnostico_catalogo(id_diagnostico) ON DELETE RESTRICT ON UPDATE CASCADE,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    observaciones VARCHAR(250),
    PRIMARY KEY (id_consulta, id_diagnostico)
);

CREATE UNIQUE INDEX uq_consulta_diag_principal
    ON clinica.consulta_diagnostico (id_consulta)
    WHERE es_principal = TRUE;

CREATE TABLE clinica.receta (
    id_receta SERIAL PRIMARY KEY,
    id_consulta INT NOT NULL UNIQUE REFERENCES clinica.consulta(id_consulta) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_emision TIMESTAMP NOT NULL DEFAULT now(),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'dispensada', 'cancelada')),
    id_farmaceutico_dispensa INT REFERENCES clinica.farmaceutico(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_dispensacion TIMESTAMP
);

CREATE TABLE clinica.medicamento (
    id_medicamento SERIAL PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    principio_activo VARCHAR(120) NOT NULL,
    presentacion VARCHAR(100) NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario > 0)
);

CREATE TABLE clinica.detalle_receta (
    id_receta INT NOT NULL REFERENCES clinica.receta(id_receta) ON DELETE CASCADE ON UPDATE CASCADE,
    num_linea SMALLINT NOT NULL CHECK (num_linea > 0),
    id_medicamento INT NOT NULL REFERENCES clinica.medicamento(id_medicamento) ON DELETE RESTRICT ON UPDATE CASCADE,
    dosis VARCHAR(80) NOT NULL,
    frecuencia VARCHAR(80) NOT NULL,
    duracion_dias SMALLINT NOT NULL CHECK (duracion_dias > 0),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    PRIMARY KEY (id_receta, num_linea),
    UNIQUE (id_receta, id_medicamento)
);

CREATE TABLE clinica.lote_inventario (
    id_lote SERIAL PRIMARY KEY,
    id_medicamento INT NOT NULL REFERENCES clinica.medicamento(id_medicamento) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_sede INT NOT NULL REFERENCES clinica.sede(id_sede) ON DELETE RESTRICT ON UPDATE CASCADE,
    numero_lote VARCHAR(40) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),
    precio_costo NUMERIC(10,2) NOT NULL CHECK (precio_costo >= 0),
    UNIQUE (id_medicamento, id_sede, numero_lote)
);

CREATE TABLE clinica.dispensacion_lote (
    id_dispensacion SERIAL PRIMARY KEY,
    id_receta INT NOT NULL,
    num_linea SMALLINT NOT NULL,
    id_lote INT NOT NULL REFERENCES clinica.lote_inventario(id_lote) ON DELETE RESTRICT ON UPDATE CASCADE,
    cantidad_entregada INT NOT NULL CHECK (cantidad_entregada > 0),
    precio_unitario_venta NUMERIC(10,2) NOT NULL CHECK (precio_unitario_venta > 0),
    fecha_dispensacion TIMESTAMP NOT NULL DEFAULT now(),
    FOREIGN KEY (id_receta, num_linea) REFERENCES clinica.detalle_receta(id_receta, num_linea) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE clinica.factura (
    id_factura SERIAL PRIMARY KEY,
    id_consulta INT NOT NULL UNIQUE REFERENCES clinica.consulta(id_consulta) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_paciente INT NOT NULL REFERENCES clinica.paciente(id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_aseguradora INT REFERENCES clinica.aseguradora(id_aseguradora) ON DELETE SET NULL ON UPDATE CASCADE,
    porcentaje_cobertura_aplicado NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (porcentaje_cobertura_aplicado BETWEEN 0 AND 100),
    fecha_emision TIMESTAMP NOT NULL DEFAULT now(),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    monto_seguro NUMERIC(12,2) NOT NULL CHECK (monto_seguro >= 0),
    monto_paciente NUMERIC(12,2) NOT NULL CHECK (monto_paciente >= 0),
    total NUMERIC(12,2) NOT NULL CHECK (total >= 0),
    saldo_pendiente NUMERIC(12,2) NOT NULL CHECK (saldo_pendiente >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'parcial', 'pagada', 'anulada')),
    CHECK (total = subtotal AND monto_seguro + monto_paciente = total)
);

CREATE TABLE clinica.detalle_factura (
    id_detalle_factura SERIAL PRIMARY KEY,
    id_factura INT NOT NULL REFERENCES clinica.factura(id_factura) ON DELETE CASCADE ON UPDATE CASCADE,
    tipo_concepto VARCHAR(15) NOT NULL CHECK (tipo_concepto IN ('consulta', 'medicamento')),
    id_medicamento INT REFERENCES clinica.medicamento(id_medicamento) ON DELETE RESTRICT ON UPDATE CASCADE,
    descripcion VARCHAR(200) NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario_venta NUMERIC(10,2) NOT NULL CHECK (precio_unitario_venta >= 0),
    importe NUMERIC(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario_venta) STORED,
    CHECK ((tipo_concepto = 'consulta' AND id_medicamento IS NULL) OR (tipo_concepto = 'medicamento' AND id_medicamento IS NOT NULL))
);

CREATE TABLE clinica.pago (
    id_pago SERIAL PRIMARY KEY,
    id_factura INT NOT NULL REFERENCES clinica.factura(id_factura) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_pago TIMESTAMP NOT NULL DEFAULT now(),
    monto NUMERIC(12,2) NOT NULL CHECK (monto > 0),
    metodo_pago VARCHAR(20) NOT NULL CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia', 'seguro')),
    referencia VARCHAR(80) NOT NULL
);

CREATE TABLE clinica.auditoria (
    id_auditoria BIGSERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(60) NOT NULL,
    id_registro BIGINT NOT NULL,
    campo_modificado VARCHAR(60) NOT NULL,
    valor_anterior TEXT,
    valor_nuevo TEXT,
    usuario_bd NAME NOT NULL DEFAULT current_user,
    fecha_cambio TIMESTAMPTZ NOT NULL DEFAULT now()
);
