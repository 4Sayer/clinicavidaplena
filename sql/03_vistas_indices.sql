CREATE OR REPLACE VIEW clinica.v_agenda_diaria AS
SELECT
    c.id_cita,
    c.fecha_hora,
    c.duracion_min,
    c.estado,
    s.id_sede,
    s.nombre AS sede,
    e.id_especialidad,
    e.nombre AS especialidad,
    c.id_medico,
    pm.nombres || ' ' || pm.apellidos AS medico,
    c.id_paciente,
    pp.nombres || ' ' || pp.apellidos AS paciente
FROM clinica.cita c
JOIN clinica.sede s ON s.id_sede = c.id_sede
JOIN clinica.especialidad e ON e.id_especialidad = c.id_especialidad
JOIN clinica.persona pm ON pm.id_persona = c.id_medico
JOIN clinica.persona pp ON pp.id_persona = c.id_paciente;

CREATE OR REPLACE VIEW clinica.v_inventario_por_vencer AS
SELECT
    l.id_lote,
    s.id_sede,
    s.nombre AS sede,
    m.id_medicamento,
    m.codigo,
    m.nombre AS medicamento,
    l.numero_lote,
    l.fecha_vencimiento,
    l.stock,
    (l.fecha_vencimiento - CURRENT_DATE) AS dias_para_vencer
FROM clinica.lote_inventario l
JOIN clinica.sede s ON s.id_sede = l.id_sede
JOIN clinica.medicamento m ON m.id_medicamento = l.id_medicamento
WHERE l.stock > 0
  AND l.fecha_vencimiento >= CURRENT_DATE
  AND l.fecha_vencimiento <= CURRENT_DATE + INTERVAL '90 days';

CREATE OR REPLACE VIEW clinica.v_resumen_facturacion AS
SELECT
    f.id_factura,
    f.id_consulta,
    f.fecha_emision,
    f.id_paciente,
    pp.nombres || ' ' || pp.apellidos AS paciente,
    COALESCE(a.nombre, 'Particular') AS aseguradora,
    f.porcentaje_cobertura_aplicado,
    f.subtotal,
    f.monto_seguro,
    f.monto_paciente,
    f.total,
    f.saldo_pendiente,
    f.estado
FROM clinica.factura f
JOIN clinica.persona pp ON pp.id_persona = f.id_paciente
LEFT JOIN clinica.aseguradora a ON a.id_aseguradora = f.id_aseguradora;

CREATE OR REPLACE VIEW clinica.v_expediente_clinico AS
SELECT
    co.id_consulta,
    co.fecha_consulta,
    c.id_cita,
    c.id_paciente,
    pp.nombres || ' ' || pp.apellidos AS paciente,
    c.id_medico,
    pm.nombres || ' ' || pm.apellidos AS medico,
    e.nombre AS especialidad,
    co.motivo_consulta,
    co.presion_arterial,
    co.frecuencia_cardiaca,
    co.temperatura,
    co.peso_kg,
    co.notas_clinicas,
    dc.codigo_cie10 AS diagnostico_principal_cie10,
    dc.nombre AS diagnostico_principal
FROM clinica.consulta co
JOIN clinica.cita c ON c.id_cita = co.id_cita
JOIN clinica.persona pp ON pp.id_persona = c.id_paciente
JOIN clinica.persona pm ON pm.id_persona = c.id_medico
JOIN clinica.especialidad e ON e.id_especialidad = c.id_especialidad
LEFT JOIN clinica.consulta_diagnostico cd ON cd.id_consulta = co.id_consulta AND cd.es_principal = TRUE
LEFT JOIN clinica.diagnostico_catalogo dc ON dc.id_diagnostico = cd.id_diagnostico;

CREATE INDEX idx_cita_sede_fecha ON clinica.cita (id_sede, fecha_hora);
CREATE INDEX idx_cita_fecha_esp ON clinica.cita (fecha_hora, id_especialidad);
CREATE INDEX idx_cita_medico_estado ON clinica.cita (id_medico, estado, id_especialidad);
CREATE INDEX idx_cita_paciente_fecha ON clinica.cita (id_paciente, fecha_hora DESC);
CREATE INDEX idx_consulta_fecha ON clinica.consulta (fecha_consulta DESC, id_consulta DESC);
CREATE INDEX idx_detalle_receta_med ON clinica.detalle_receta (id_medicamento);
CREATE INDEX idx_lote_vencimiento ON clinica.lote_inventario (fecha_vencimiento, id_sede) WHERE stock > 0;
CREATE INDEX idx_factura_paciente ON clinica.factura (id_paciente, estado);
CREATE INDEX idx_pago_factura ON clinica.pago (id_factura, fecha_pago);
CREATE INDEX idx_persona_busqueda ON clinica.persona (LOWER(nombres), LOWER(apellidos));
