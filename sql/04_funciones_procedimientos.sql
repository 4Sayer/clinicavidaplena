CREATE OR REPLACE FUNCTION clinica.fn_disponibilidad_medico(
    p_id_medico INT,
    p_fecha DATE
)
RETURNS TABLE (
    hora_bloque TIME,
    id_sede INT,
    sede VARCHAR,
    disponible BOOLEAN
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        (h.hora_inicio + (gs.n * INTERVAL '30 minutes'))::time AS hora_bloque,
        h.id_sede,
        s.nombre AS sede,
        NOT EXISTS (
            SELECT 1
            FROM clinica.cita c
            WHERE c.id_medico = p_id_medico
              AND c.fecha_hora = (p_fecha + h.hora_inicio + (gs.n * INTERVAL '30 minutes'))::timestamp
              AND c.estado <> 'cancelada'
        ) AS disponible
    FROM clinica.horario_medico h
    JOIN clinica.sede s ON s.id_sede = h.id_sede
    CROSS JOIN LATERAL generate_series(
        0,
        ((EXTRACT(EPOCH FROM (h.hora_fin - h.hora_inicio)) / 1800)::int) - 1
    ) AS gs(n)
    WHERE h.id_medico = p_id_medico
      AND h.dia_semana = EXTRACT(ISODOW FROM p_fecha)::smallint
    ORDER BY hora_bloque;
$$;

CREATE OR REPLACE PROCEDURE clinica.sp_reservar_cita(
    p_id_paciente INT,
    p_id_medico INT,
    p_id_especialidad INT,
    p_id_sede INT,
    p_fecha_hora TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_fecha_hora IS NULL THEN
        RAISE EXCEPTION 'La fecha y hora de la cita es obligatoria.';
    END IF;

    INSERT INTO clinica.cita (
        id_paciente,
        id_medico,
        id_especialidad,
        id_sede,
        fecha_hora,
        duracion_min,
        estado
    ) VALUES (
        p_id_paciente,
        p_id_medico,
        p_id_especialidad,
        p_id_sede,
        p_fecha_hora,
        30,
        'programada'
    );
END;
$$;

CREATE OR REPLACE PROCEDURE clinica.sp_cambiar_estado_cita(
    p_id_cita INT,
    p_nuevo_estado VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE clinica.cita
    SET estado = p_nuevo_estado
    WHERE id_cita = p_id_cita;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la cita con id %.', p_id_cita;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE clinica.sp_dispensar_receta(
    p_id_receta INT,
    p_id_farmaceutico INT,
    p_id_sede INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_receta VARCHAR(20);
    v_linea RECORD;
    v_lote RECORD;
    v_pendiente INT;
    v_entregar INT;
BEGIN
    SELECT r.estado
    INTO v_estado_receta
    FROM clinica.receta r
    WHERE r.id_receta = p_id_receta
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la receta con id %.', p_id_receta;
    END IF;

    IF v_estado_receta <> 'pendiente' THEN
        RAISE EXCEPTION 'La receta % tiene estado % y no puede dispensarse.', p_id_receta, v_estado_receta;
    END IF;

    FOR v_linea IN
        SELECT dr.num_linea, dr.id_medicamento, dr.cantidad, m.precio_unitario, m.nombre
        FROM clinica.detalle_receta dr
        JOIN clinica.medicamento m ON m.id_medicamento = dr.id_medicamento
        WHERE dr.id_receta = p_id_receta
        ORDER BY dr.num_linea
    LOOP
        v_pendiente := v_linea.cantidad;

        FOR v_lote IN
            SELECT l.id_lote, l.stock
            FROM clinica.lote_inventario l
            WHERE l.id_medicamento = v_linea.id_medicamento
              AND l.id_sede = p_id_sede
              AND l.fecha_vencimiento >= CURRENT_DATE
              AND l.stock > 0
            ORDER BY l.fecha_vencimiento ASC, l.id_lote ASC
            FOR UPDATE
        LOOP
            v_entregar := LEAST(v_pendiente, v_lote.stock);

            UPDATE clinica.lote_inventario
            SET stock = stock - v_entregar
            WHERE id_lote = v_lote.id_lote;

            INSERT INTO clinica.dispensacion_lote (
                id_receta,
                num_linea,
                id_lote,
                cantidad_entregada,
                precio_unitario_venta
            ) VALUES (
                p_id_receta,
                v_linea.num_linea,
                v_lote.id_lote,
                v_entregar,
                v_linea.precio_unitario
            );

            v_pendiente := v_pendiente - v_entregar;
            EXIT WHEN v_pendiente = 0;
        END LOOP;

        IF v_pendiente > 0 THEN
            RAISE EXCEPTION 'Stock insuficiente para % (id_medicamento=%) en sede %: faltan % unidades.',
                v_linea.nombre, v_linea.id_medicamento, p_id_sede, v_pendiente;
        END IF;
    END LOOP;

    UPDATE clinica.receta
    SET estado = 'dispensada',
        id_farmaceutico_dispensa = p_id_farmaceutico,
        fecha_dispensacion = now()
    WHERE id_receta = p_id_receta;
END;
$$;

CREATE OR REPLACE PROCEDURE clinica.sp_generar_factura(
    p_id_consulta INT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = clinica, pg_temp
AS $$
DECLARE
    v_id_paciente INT;
    v_id_aseguradora INT;
    v_porcentaje NUMERIC(5,2);
    v_tarifa NUMERIC(10,2);
    v_especialidad VARCHAR(100);
    v_total_meds NUMERIC(12,2);
    v_subtotal NUMERIC(12,2);
    v_monto_seguro NUMERIC(12,2);
    v_monto_paciente NUMERIC(12,2);
    v_id_factura INT;
BEGIN
    SELECT
        c.id_paciente,
        pac.id_aseguradora,
        COALESCE(ase.porcentaje_cobertura, 0),
        med.tarifa_consulta,
        esp.nombre
    INTO
        v_id_paciente,
        v_id_aseguradora,
        v_porcentaje,
        v_tarifa,
        v_especialidad
    FROM clinica.consulta co
    JOIN clinica.cita c ON c.id_cita = co.id_cita
    JOIN clinica.medico med ON med.id_persona = c.id_medico
    JOIN clinica.especialidad esp ON esp.id_especialidad = c.id_especialidad
    JOIN clinica.paciente pac ON pac.id_persona = c.id_paciente
    LEFT JOIN clinica.aseguradora ase ON ase.id_aseguradora = pac.id_aseguradora
    WHERE co.id_consulta = p_id_consulta;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la consulta con id %.', p_id_consulta;
    END IF;

    SELECT COALESCE(SUM(dl.cantidad_entregada * dl.precio_unitario_venta), 0)
    INTO v_total_meds
    FROM clinica.receta r
    JOIN clinica.dispensacion_lote dl ON dl.id_receta = r.id_receta
    WHERE r.id_consulta = p_id_consulta
      AND r.estado = 'dispensada';

    v_subtotal := ROUND(v_tarifa + v_total_meds, 2);
    v_monto_seguro := ROUND(v_subtotal * v_porcentaje / 100.0, 2);
    v_monto_paciente := v_subtotal - v_monto_seguro;

    INSERT INTO clinica.factura (
        id_consulta,
        id_paciente,
        id_aseguradora,
        porcentaje_cobertura_aplicado,
        subtotal,
        monto_seguro,
        monto_paciente,
        total,
        saldo_pendiente,
        estado
    ) VALUES (
        p_id_consulta,
        v_id_paciente,
        v_id_aseguradora,
        v_porcentaje,
        v_subtotal,
        v_monto_seguro,
        v_monto_paciente,
        v_subtotal,
        v_subtotal,
        'pendiente'
    )
    RETURNING id_factura INTO v_id_factura;

    INSERT INTO clinica.detalle_factura (
        id_factura,
        tipo_concepto,
        id_medicamento,
        descripcion,
        cantidad,
        precio_unitario_venta
    ) VALUES (
        v_id_factura,
        'consulta',
        NULL,
        'Consulta médica de ' || v_especialidad,
        1,
        v_tarifa
    );

    INSERT INTO clinica.detalle_factura (
        id_factura,
        tipo_concepto,
        id_medicamento,
        descripcion,
        cantidad,
        precio_unitario_venta
    )
    SELECT
        v_id_factura,
        'medicamento',
        dr.id_medicamento,
        m.nombre,
        SUM(dl.cantidad_entregada),
        dl.precio_unitario_venta
    FROM clinica.receta r
    JOIN clinica.dispensacion_lote dl ON dl.id_receta = r.id_receta
    JOIN clinica.detalle_receta dr ON dr.id_receta = dl.id_receta AND dr.num_linea = dl.num_linea
    JOIN clinica.medicamento m ON m.id_medicamento = dr.id_medicamento
    WHERE r.id_consulta = p_id_consulta
      AND r.estado = 'dispensada'
    GROUP BY dr.id_medicamento, m.nombre, dl.precio_unitario_venta;
END;
$$;

CREATE OR REPLACE PROCEDURE clinica.sp_registrar_pago(
    p_id_factura INT,
    p_monto NUMERIC,
    p_metodo_pago VARCHAR,
    p_referencia VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO clinica.pago (
        id_factura,
        monto,
        metodo_pago,
        referencia
    ) VALUES (
        p_id_factura,
        p_monto,
        p_metodo_pago,
        p_referencia
    );
END;
$$;
