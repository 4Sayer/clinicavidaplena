INSERT INTO clinica.sede (nombre, direccion, telefono) VALUES
('Sede Centro', 'Av. Juárez 120, Col. Centro', '6622101001'),
('Sede Norte', 'Blvd. Morelos 850, Col. Pitic', '6622101002'),
('Sede Sur', 'Periférico Sur 410, Col. Las Palmas', '6622101003');

INSERT INTO clinica.aseguradora (nombre, porcentaje_cobertura, telefono) VALUES
('Seguros Bienestar', 80.00, '8001002001'),
('GNP Salud Integral', 75.00, '8001002002'),
('AXA Protección Médica', 90.00, '8001002003'),
('MetLife Clínico', 60.00, '8001002004'),
('Mapfre Cobertura Básica', 40.00, '8001002005');

INSERT INTO clinica.especialidad (nombre, descripcion) VALUES
('Medicina General', 'Atención primaria, prevención y control de enfermedades comunes'),
('Pediatría', 'Atención médica integral para recién nacidos, niños y adolescentes'),
('Cardiología', 'Diagnóstico y tratamiento de enfermedades del corazón y sistema circulatorio'),
('Dermatología', 'Tratamiento de afecciones de la piel, cabello y uñas'),
('Ginecología', 'Salud integral de la mujer y control prenatal'),
('Traumatología', 'Atención de lesiones musculoesqueléticas, fracturas y articulaciones'),
('Neurología', 'Diagnóstico y manejo de trastornos del sistema nervioso'),
('Oftalmología', 'Evaluación y tratamiento de enfermedades oculares'),
('Psiquiatría', 'Atención de trastornos de la salud mental y emocional'),
('Nutrición', 'Evaluación nutricional y planes alimenticios terapéuticos');

INSERT INTO clinica.diagnostico_catalogo (codigo_cie10, nombre, descripcion) VALUES
('J00', 'Rinofaringitis aguda', 'Resfriado común de vías respiratorias altas'),
('J02.9', 'Faringitis aguda', 'Inflamación aguda de la faringe no especificada'),
('I10', 'Hipertensión esencial', 'Presión arterial elevada primaria'),
('E11.9', 'Diabetes mellitus tipo 2', 'Control metabólico de diabetes tipo 2 sin complicaciones'),
('K29.7', 'Gastritis', 'Inflamación de la mucosa gástrica'),
('M54.5', 'Lumbalgia', 'Dolor en la región lumbar'),
('R51', 'Cefalea', 'Dolor de cabeza de origen primario'),
('J20.9', 'Bronquitis aguda', 'Inflamación aguda de los bronquios'),
('L20.9', 'Dermatitis atópica', 'Inflamación crónica pruriginosa de la piel'),
('N39.0', 'Infección de vías urinarias', 'Infección urinaria sin localización especificada'),
('E66.9', 'Obesidad', 'Exceso de tejido adiposo corporal'),
('F41.1', 'Trastorno de ansiedad generalizada', 'Ansiedad persistente y preocupación excesiva'),
('H10.9', 'Conjuntivitis', 'Inflamación de la conjuntiva ocular'),
('S93.4', 'Esguince de tobillo', 'Distensión ligamentosa de la articulación del tobillo'),
('J45.9', 'Asma no especificada', 'Enfermedad inflamatoria crónica de las vías aéreas'),
('K58.9', 'Síndrome del intestino irritable', 'Trastorno funcional digestivo crónico'),
('E78.5', 'Dislipidemia', 'Alteración de los lípidos séricos'),
('G43.9', 'Migraña', 'Cefalea vascular recurrente'),
('M25.5', 'Artralgia', 'Dolor articular localizado'),
('Z00.0', 'Examen médico general', 'Revisión preventiva de rutina en adulto sano');

INSERT INTO clinica.medicamento (codigo, nombre, principio_activo, presentacion, precio_unitario) VALUES
('MED-001', 'Paracetamol 500mg', 'Paracetamol', 'Caja con 20 tabletas', 45.00),
('MED-002', 'Ibuprofeno 400mg', 'Ibuprofeno', 'Caja con 10 cápsulas', 65.00),
('MED-003', 'Amoxicilina 500mg', 'Amoxicilina', 'Caja con 12 cápsulas', 120.00),
('MED-004', 'Losartán 50mg', 'Losartán potásico', 'Caja con 30 tabletas', 185.00),
('MED-005', 'Metformina 850mg', 'Metformina', 'Caja con 30 tabletas', 110.00),
('MED-006', 'Omeprazol 20mg', 'Omeprazol', 'Caja con 14 cápsulas', 85.00),
('MED-007', 'Loratadina 10mg', 'Loratadina', 'Caja con 10 tabletas', 55.00),
('MED-008', 'Atorvastatina 20mg', 'Atorvastatina', 'Caja con 30 tabletas', 240.00),
('MED-009', 'Salbutamol Inhalador', 'Salbutamol', 'Frasco aerosol 200 dosis', 195.00),
('MED-010', 'Ciprofloxacino 500mg', 'Ciprofloxacino', 'Caja con 12 tabletas', 160.00),
('MED-011', 'Naproxeno 500mg', 'Naproxeno sódico', 'Caja con 12 tabletas', 90.00),
('MED-012', 'Azitromicina 500mg', 'Azitromicina', 'Caja con 3 tabletas', 175.00),
('MED-013', 'Ketorolaco 10mg', 'Ketorolaco trometamina', 'Caja con 10 tabletas', 78.00),
('MED-014', 'Enalapril 10mg', 'Enalapril', 'Caja con 30 tabletas', 135.00),
('MED-015', 'Hidrocortisona Crema 1%', 'Hidrocortisona', 'Tubo con 30 g', 115.00),
('MED-016', 'Tobramicina Gotas', 'Tobramicina', 'Frasco gotero 5 ml', 210.00),
('MED-017', 'Sumatriptán 50mg', 'Sumatriptán', 'Caja con 2 tabletas', 290.00),
('MED-018', 'Complejo B', 'Tiamina / Piridoxina / Cianocobalamina', 'Caja con 30 tabletas', 95.00),
('MED-019', 'Diclofenaco 100mg', 'Diclofenaco sódico', 'Caja con 20 tabletas', 88.00),
('MED-020', 'Butilhioscina 10mg', 'Butilbromuro de hioscina', 'Caja con 10 grageas', 105.00),
('MED-021', 'Cefalexina 500mg', 'Cefalexina', 'Caja con 20 cápsulas', 150.00),
('MED-022', 'Clotrimazol Crema 1%', 'Clotrimazol', 'Tubo con 30 g', 92.00),
('MED-023', 'Sertralina 50mg', 'Sertralina', 'Caja con 14 tabletas', 260.00),
('MED-024', 'Insulina Glargina', 'Insulina glargina', 'Pluma precargada 3 ml', 680.00),
('MED-025', 'Rivaroxabán 20mg', 'Rivaroxabán', 'Caja con 28 tabletas', 890.00);

WITH nombres AS (
    SELECT ARRAY[
        'Carlos', 'María', 'José', 'Ana', 'Luis', 'Laura', 'Juan', 'Sofía', 'Miguel', 'Fernanda',
        'Carlos Eduardo', 'Valeria', 'Jorge', 'Paola', 'Ricardo', 'Gabriela', 'Daniel', 'Andrea', 'Fernando', 'Lucía'
    ] AS arr_nom,
    ARRAY[
        'García', 'López', 'Martínez', 'Rodríguez', 'Hernández', 'González', 'Pérez', 'Sánchez', 'Ramírez', 'Torres',
        'Flores', 'Rivera', 'Gómez', 'Díaz', 'Cruz', 'Morales', 'Ortiz', 'Gutiérrez', 'Chávez', 'Ramos'
    ] AS arr_ape
)
INSERT INTO clinica.persona (nombres, apellidos, fecha_nacimiento, curp, telefono, correo, direccion)
SELECT
    arr_nom[1 + ((g - 1) % 20)],
    arr_ape[1 + (((g - 1) / 20) % 20)] || ' ' || arr_ape[1 + (((g * 7) - 1) % 20)],
    CASE
        WHEN g <= 32 THEN DATE '1970-01-01' + ((g * 280) % 9500)
        WHEN g <= 477 THEN DATE '1955-01-01' + ((g * 97) % 18000)
        ELSE DATE '2011-01-01' + ((g * 53) % 4200)
    END,
    'CURP' || LPAD(g::text, 10, '0') || 'HSR0',
    '662' || LPAD((1000000 + g)::text, 7, '0'),
    'persona' || g || '@clinicavidaplena.mx',
    'Calle ' || (10 + (g % 90)) || ' #' || (100 + g) || ', Hermosillo, Son.'
FROM nombres, generate_series(1, 527) AS g;

INSERT INTO clinica.empleado (id_persona, tipo_empleado, fecha_contratacion, salario, activo)
SELECT
    g,
    CASE
        WHEN g <= 20 THEN 'medico'
        WHEN g <= 26 THEN 'recepcionista'
        ELSE 'farmaceutico'
    END,
    DATE '2018-01-15' + ((g * 45) % 2000),
    CASE
        WHEN g <= 20 THEN 32000.00 + ((g % 5) * 3500.00)
        WHEN g <= 26 THEN 14500.00 + ((g % 3) * 1200.00)
        ELSE 19500.00 + ((g % 3) * 1500.00)
    END,
    TRUE
FROM generate_series(1, 32) AS g;

INSERT INTO clinica.medico (id_persona, cedula_profesional, tarifa_consulta)
SELECT
    g,
    'CED-MED-' || LPAD(g::text, 5, '0'),
    550.00 + ((g % 6) * 100.00)
FROM generate_series(1, 20) AS g;

INSERT INTO clinica.recepcionista (id_persona, turno, extension)
SELECT
    g,
    CASE (g - 21) % 3
        WHEN 0 THEN 'matutino'
        WHEN 1 THEN 'vespertino'
        ELSE 'mixto'
    END,
    'EXT-' || (100 + g)
FROM generate_series(21, 26) AS g;

INSERT INTO clinica.farmaceutico (id_persona, licencia_sanitaria, id_sede_asignada)
SELECT
    g,
    'LIC-FAR-' || LPAD(g::text, 5, '0'),
    1 + ((g - 27) / 2)
FROM generate_series(27, 32) AS g;

INSERT INTO clinica.paciente (id_persona, id_aseguradora, id_responsable, numero_poliza, tipo_sangre)
SELECT
    p.id_persona,
    CASE WHEN p.id_persona % 3 = 0 THEN NULL ELSE 1 + (p.id_persona % 5) END,
    CASE WHEN p.id_persona BETWEEN 478 AND 527 THEN 33 + ((p.id_persona - 478) % 50) ELSE NULL END,
    CASE WHEN p.id_persona % 3 = 0 THEN NULL ELSE 'POL-' || LPAD(p.id_persona::text, 6, '0') END,
    (ARRAY['O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-'])[1 + (p.id_persona % 8)]
FROM clinica.persona p
WHERE p.id_persona IN (1, 2, 21, 22, 27) OR p.id_persona >= 33;

INSERT INTO clinica.medico_especialidad (id_medico, id_especialidad, fecha_certificacion)
VALUES
(1, 1, '2015-05-10'), (1, 3, '2018-06-15'),
(2, 2, '2016-03-20'),
(3, 3, '2014-08-11'), (3, 1, '2012-07-01'),
(4, 4, '2017-02-14'),
(5, 5, '2015-11-22'),
(6, 6, '2016-09-05'),
(7, 7, '2014-12-01'),
(8, 8, '2017-04-18'),
(9, 9, '2016-06-30'),
(10, 10, '2018-01-25'),
(11, 1, '2015-09-12'), (11, 2, '2019-03-10'),
(12, 2, '2017-10-08'),
(13, 3, '2016-11-19'),
(14, 4, '2018-04-03'),
(15, 5, '2015-07-21'),
(16, 6, '2017-08-14'),
(17, 7, '2016-02-28'),
(18, 8, '2018-09-17'),
(19, 1, '2019-05-05'),
(20, 1, '2020-02-10');

INSERT INTO clinica.horario_medico (id_medico, id_sede, dia_semana, hora_inicio, hora_fin)
SELECT
    m.id_persona,
    CASE
        WHEN m.id_persona IN (7, 17) THEN CASE WHEN d <= 3 THEN 1 ELSE 2 END
        WHEN d <= 3 THEN 1 + ((m.id_persona - 1) % 3)
        ELSE 1 + (m.id_persona % 3)
    END,
    d,
    TIME '08:00:00',
    TIME '18:00:00'
FROM clinica.medico m
CROSS JOIN generate_series(1, 6) AS d;

WITH pacientes_arr AS (
    SELECT array_agg(id_persona ORDER BY id_persona) AS ids
    FROM clinica.paciente
),
esp_principal AS (
    SELECT id_medico, MIN(id_especialidad) AS id_especialidad
    FROM clinica.medico_especialidad
    GROUP BY id_medico
),
dias AS (
    SELECT d::date AS fecha
    FROM generate_series(
        CURRENT_DATE - INTERVAL '420 days',
        CURRENT_DATE + INTERVAL '30 days',
        INTERVAL '1 day'
    ) AS d
),
bloques AS (
    SELECT generate_series(0, 19) AS blk
),
candidatos AS (
    SELECT
        h.id_medico,
        ep.id_especialidad,
        h.id_sede,
        (d.fecha + h.hora_inicio + (b.blk * INTERVAL '30 minutes'))::timestamp AS fecha_hora
    FROM dias d
    JOIN clinica.horario_medico h
        ON h.dia_semana = EXTRACT(ISODOW FROM d.fecha)::smallint
    JOIN esp_principal ep
        ON ep.id_medico = h.id_medico
    CROSS JOIN bloques b
    WHERE (h.hora_inicio + (b.blk * INTERVAL '30 minutes')) < h.hora_fin
      AND NOT (h.id_medico = 20 AND d.fecha >= date_trunc('month', CURRENT_DATE)::date)
      AND NOT (
          ep.id_especialidad = 9
          AND (
              d.fecha < (date_trunc('month', CURRENT_DATE) - INTERVAL '1 month')::date
              OR d.fecha >= date_trunc('month', CURRENT_DATE)::date
          )
      )
      AND NOT (
          ep.id_especialidad = 10
          AND (
              d.fecha < date_trunc('month', CURRENT_DATE)::date
              OR d.fecha >= (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month')::date
          )
      )
),
priorizados AS (
    SELECT
        c.*,
        ROW_NUMBER() OVER (PARTITION BY c.fecha_hora ORDER BY c.id_medico) AS rn_hora,
        CASE
            WHEN c.fecha_hora::date = CURRENT_DATE THEN 1
            WHEN c.id_especialidad IN (9, 10) THEN 2
            WHEN c.fecha_hora >= (date_trunc('month', CURRENT_DATE) - INTERVAL '1 month') THEN 3
            ELSE 4
        END AS prioridad
    FROM candidatos c
),
seleccionados AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (ORDER BY p.prioridad, p.fecha_hora, p.id_medico) AS seq_global
    FROM priorizados p
    LIMIT 50000
)
INSERT INTO clinica.cita (id_paciente, id_medico, id_especialidad, id_sede, fecha_hora, duracion_min, estado)
SELECT
    pa.ids[1 + (((s.rn_hora * 23 + (EXTRACT(EPOCH FROM s.fecha_hora)::bigint / 1800)) % 500 + 500) % 500)],
    s.id_medico,
    s.id_especialidad,
    s.id_sede,
    s.fecha_hora,
    30,
    CASE
        WHEN s.fecha_hora::date < CURRENT_DATE THEN
            CASE
                WHEN s.seq_global % 10 = 0 THEN 'cancelada'
                WHEN s.seq_global % 15 = 0 THEN 'no_asistio'
                ELSE 'atendida'
            END
        WHEN s.fecha_hora::date = CURRENT_DATE THEN
            CASE
                WHEN s.seq_global % 5 = 0 THEN 'confirmada'
                ELSE 'programada'
            END
        ELSE
            CASE
                WHEN s.seq_global % 8 = 0 THEN 'confirmada'
                ELSE 'programada'
            END
    END
FROM seleccionados s
CROSS JOIN pacientes_arr pa;

WITH citas_atendidas AS (
    SELECT
        id_cita,
        fecha_hora,
        ROW_NUMBER() OVER (ORDER BY fecha_hora DESC, id_cita) AS rn
    FROM clinica.cita
    WHERE estado = 'atendida'
    LIMIT 15000
)
INSERT INTO clinica.consulta (id_cita, fecha_consulta, motivo_consulta, presion_arterial, frecuencia_cardiaca, temperatura, peso_kg, notas_clinicas)
SELECT
    ca.id_cita,
    ca.fecha_hora + INTERVAL '10 minutes',
    (ARRAY[
        'Control periódico general',
        'Dolor de cabeza y malestar general',
        'Revisión de presión arterial',
        'Síntomas respiratorios leves',
        'Dolor lumbar agudo',
        'Seguimiento de tratamiento'
    ])[1 + (ca.rn % 6)],
    (110 + (ca.rn % 25)) || '/' || (70 + (ca.rn % 15)),
    64 + (ca.rn % 28),
    36.2 + ((ca.rn % 15) * 0.1),
    55.0 + (ca.rn % 40),
    'Paciente valorado en consulta externa. Se indican medidas generales y seguimiento.'
FROM citas_atendidas ca;

INSERT INTO clinica.consulta_diagnostico (id_consulta, id_diagnostico, es_principal, observaciones)
SELECT
    id_consulta,
    1 + (id_consulta % 20),
    TRUE,
    'Diagnóstico principal confirmado en consulta'
FROM clinica.consulta;

INSERT INTO clinica.consulta_diagnostico (id_consulta, id_diagnostico, es_principal, observaciones)
SELECT
    id_consulta,
    1 + ((id_consulta + 5) % 20),
    FALSE,
    'Hallazgo secundario asociado'
FROM clinica.consulta
WHERE id_consulta % 5 IN (0, 1);

WITH consultas_receta AS (
    SELECT
        co.id_consulta,
        co.fecha_consulta,
        c.id_sede,
        ROW_NUMBER() OVER (ORDER BY co.id_consulta) AS rn
    FROM clinica.consulta co
    JOIN clinica.cita c ON c.id_cita = co.id_cita
    LIMIT 8000
)
INSERT INTO clinica.receta (id_consulta, fecha_emision, estado, id_farmaceutico_dispensa, fecha_dispensacion)
SELECT
    cr.id_consulta,
    cr.fecha_consulta,
    CASE WHEN cr.rn <= 7950 THEN 'dispensada' ELSE 'pendiente' END,
    CASE WHEN cr.rn <= 7950 THEN 27 + ((cr.id_sede - 1) * 2) ELSE NULL END,
    CASE WHEN cr.rn <= 7950 THEN cr.fecha_consulta + INTERVAL '20 minutes' ELSE NULL END
FROM consultas_receta cr;

INSERT INTO clinica.detalle_receta (id_receta, num_linea, id_medicamento, dosis, frecuencia, duracion_dias, cantidad)
SELECT
    r.id_receta,
    1,
    1 + (r.id_receta % 23),
    '1 tableta o dosis',
    'Cada 8 horas',
    7,
    1 + (r.id_receta % 3)
FROM clinica.receta r;

INSERT INTO clinica.detalle_receta (id_receta, num_linea, id_medicamento, dosis, frecuencia, duracion_dias, cantidad)
SELECT
    r.id_receta,
    2,
    1 + ((r.id_receta + 7) % 23),
    '1 cápsula',
    'Cada 12 horas',
    5,
    1 + (r.id_receta % 2)
FROM clinica.receta r
WHERE r.id_receta % 2 = 0;

INSERT INTO clinica.lote_inventario (id_medicamento, id_sede, numero_lote, fecha_vencimiento, stock, precio_costo)
SELECT
    m.id_medicamento,
    s.id_sede,
    'LOTE-' || LPAD(m.id_medicamento::text, 2, '0') || '-' || s.id_sede || '-' || t.num,
    CASE t.num
        WHEN 1 THEN CURRENT_DATE + (15 + ((m.id_medicamento * 7 + s.id_sede * 11) % 65))
        ELSE CURRENT_DATE + (180 + ((m.id_medicamento * 13 + s.id_sede * 17) % 240))
    END,
    CASE t.num
        WHEN 1 THEN 40 + ((m.id_medicamento + s.id_sede) % 60)
        ELSE 5000 + ((m.id_medicamento * 10) % 500)
    END,
    ROUND(m.precio_unitario * 0.65, 2)
FROM clinica.medicamento m
CROSS JOIN clinica.sede s
CROSS JOIN (VALUES (1), (2)) AS t(num);

INSERT INTO clinica.lote_inventario (id_medicamento, id_sede, numero_lote, fecha_vencimiento, stock, precio_costo)
SELECT
    m.id_medicamento,
    1,
    'LOTE-VENC-' || LPAD(m.id_medicamento::text, 2, '0'),
    CURRENT_DATE - 30,
    12,
    ROUND(m.precio_unitario * 0.60, 2)
FROM clinica.medicamento m
WHERE m.id_medicamento <= 5;

WITH lote_vigente AS (
    SELECT DISTINCT ON (id_medicamento, id_sede)
        id_lote,
        id_medicamento,
        id_sede
    FROM clinica.lote_inventario
    WHERE fecha_vencimiento > CURRENT_DATE + 120
    ORDER BY id_medicamento, id_sede, fecha_vencimiento DESC
)
INSERT INTO clinica.dispensacion_lote (id_receta, num_linea, id_lote, cantidad_entregada, precio_unitario_venta, fecha_dispensacion)
SELECT
    dr.id_receta,
    dr.num_linea,
    lv.id_lote,
    dr.cantidad,
    med.precio_unitario,
    r.fecha_dispensacion
FROM clinica.detalle_receta dr
JOIN clinica.receta r ON r.id_receta = dr.id_receta
JOIN clinica.consulta co ON co.id_consulta = r.id_consulta
JOIN clinica.cita c ON c.id_cita = co.id_cita
JOIN clinica.medicamento med ON med.id_medicamento = dr.id_medicamento
JOIN lote_vigente lv ON lv.id_medicamento = dr.id_medicamento AND lv.id_sede = c.id_sede
WHERE r.estado = 'dispensada';

WITH totales_med AS (
    SELECT
        r.id_consulta,
        COALESCE(SUM(dl.cantidad_entregada * dl.precio_unitario_venta), 0) AS total_meds
    FROM clinica.receta r
    JOIN clinica.dispensacion_lote dl ON dl.id_receta = r.id_receta
    GROUP BY r.id_consulta
),
base_fact AS (
    SELECT
        co.id_consulta,
        c.id_paciente,
        pac.id_aseguradora,
        COALESCE(ase.porcentaje_cobertura, 0) AS pct,
        co.fecha_consulta + INTERVAL '30 minutes' AS fecha_emision,
        (med.tarifa_consulta + COALESCE(tm.total_meds, 0))::numeric(12,2) AS subtotal,
        ROW_NUMBER() OVER (ORDER BY co.id_consulta) AS rn
    FROM clinica.consulta co
    JOIN clinica.cita c ON c.id_cita = co.id_cita
    JOIN clinica.medico med ON med.id_persona = c.id_medico
    JOIN clinica.paciente pac ON pac.id_persona = c.id_paciente
    LEFT JOIN clinica.aseguradora ase ON ase.id_aseguradora = pac.id_aseguradora
    LEFT JOIN totales_med tm ON tm.id_consulta = co.id_consulta
)
INSERT INTO clinica.factura (
    id_consulta, id_paciente, id_aseguradora, porcentaje_cobertura_aplicado,
    fecha_emision, subtotal, monto_seguro, monto_paciente, total, saldo_pendiente, estado
)
SELECT
    bf.id_consulta,
    bf.id_paciente,
    bf.id_aseguradora,
    bf.pct,
    bf.fecha_emision,
    bf.subtotal,
    ROUND(bf.subtotal * bf.pct / 100.0, 2),
    bf.subtotal - ROUND(bf.subtotal * bf.pct / 100.0, 2),
    bf.subtotal,
    CASE
        WHEN bf.rn <= 11000 THEN 0.00
        WHEN bf.rn <= 13500 THEN bf.subtotal - ROUND(bf.subtotal * 0.50, 2)
        ELSE bf.subtotal
    END,
    CASE
        WHEN bf.rn <= 11000 THEN 'pagada'
        WHEN bf.rn <= 13500 THEN 'parcial'
        ELSE 'pendiente'
    END
FROM base_fact bf;

INSERT INTO clinica.detalle_factura (id_factura, tipo_concepto, id_medicamento, descripcion, cantidad, precio_unitario_venta)
SELECT
    f.id_factura,
    'consulta',
    NULL,
    'Consulta médica de ' || esp.nombre,
    1,
    med.tarifa_consulta
FROM clinica.factura f
JOIN clinica.consulta co ON co.id_consulta = f.id_consulta
JOIN clinica.cita c ON c.id_cita = co.id_cita
JOIN clinica.medico med ON med.id_persona = c.id_medico
JOIN clinica.especialidad esp ON esp.id_especialidad = c.id_especialidad;

INSERT INTO clinica.detalle_factura (id_factura, tipo_concepto, id_medicamento, descripcion, cantidad, precio_unitario_venta)
SELECT
    f.id_factura,
    'medicamento',
    dr.id_medicamento,
    m.nombre,
    dl.cantidad_entregada,
    dl.precio_unitario_venta
FROM clinica.factura f
JOIN clinica.receta r ON r.id_consulta = f.id_consulta
JOIN clinica.dispensacion_lote dl ON dl.id_receta = r.id_receta
JOIN clinica.detalle_receta dr ON dr.id_receta = dl.id_receta AND dr.num_linea = dl.num_linea
JOIN clinica.medicamento m ON m.id_medicamento = dr.id_medicamento;

INSERT INTO clinica.pago (id_factura, fecha_pago, monto, metodo_pago, referencia)
SELECT
    f.id_factura,
    f.fecha_emision + INTERVAL '5 minutes',
    CASE
        WHEN f.estado = 'pagada' THEN f.total
        ELSE ROUND(f.total * 0.50, 2)
    END,
    (ARRAY['efectivo', 'tarjeta', 'transferencia', 'seguro'])[1 + (f.id_factura % 4)],
    'PAG-' || LPAD(f.id_factura::text, 7, '0')
FROM clinica.factura f
WHERE f.estado IN ('pagada', 'parcial');

INSERT INTO clinica.auditoria (tabla_afectada, id_registro, campo_modificado, valor_anterior, valor_nuevo, usuario_bd, fecha_cambio)
SELECT
    'cita',
    c.id_cita,
    'estado',
    'confirmada',
    c.estado,
    'rol_recepcion',
    c.fecha_hora
FROM clinica.cita c
WHERE c.estado = 'atendida'
LIMIT 500;
