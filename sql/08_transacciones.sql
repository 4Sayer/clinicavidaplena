DO $$
DECLARE
    v_fecha_libre TIMESTAMP;
    v_id_sede INT;
    v_id_cita1 INT;
    v_id_cita2 INT;
BEGIN
    SELECT
        (d.fecha + h.hora_inicio)::timestamp,
        h.id_sede
    INTO v_fecha_libre, v_id_sede
    FROM generate_series(CURRENT_DATE + 45, CURRENT_DATE + 60, INTERVAL '1 day') AS d(fecha)
    JOIN clinica.horario_medico h
      ON h.id_medico = 1
     AND h.dia_semana = EXTRACT(ISODOW FROM d.fecha)::smallint
    WHERE NOT EXISTS (
        SELECT 1
        FROM clinica.cita c
        WHERE c.id_medico = 1
          AND c.fecha_hora = (d.fecha + h.hora_inicio)::timestamp
          AND c.estado <> 'cancelada'
    )
    ORDER BY d.fecha
    LIMIT 1;

    CALL clinica.sp_reservar_cita(33, 1, 1, v_id_sede, v_fecha_libre);
    SELECT id_cita INTO v_id_cita1
    FROM clinica.cita
    WHERE id_medico = 1 AND fecha_hora = v_fecha_libre AND estado <> 'cancelada';

    RAISE NOTICE 'Prueba RN-08: Cita % reservada para paciente 33 en %', v_id_cita1, v_fecha_libre;

    BEGIN
        CALL clinica.sp_reservar_cita(34, 1, 1, v_id_sede, v_fecha_libre);
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'Prueba RN-08: Doble reserva rechazada correctamente por uq_cita_medico_bloque';
    END;

    CALL clinica.sp_cambiar_estado_cita(v_id_cita1, 'cancelada');
    CALL clinica.sp_reservar_cita(34, 1, 1, v_id_sede, v_fecha_libre);

    SELECT id_cita INTO v_id_cita2
    FROM clinica.cita
    WHERE id_medico = 1 AND fecha_hora = v_fecha_libre AND estado <> 'cancelada';

    RAISE NOTICE 'Prueba RN-08: Tras cancelar cita %, el bloque quedó libre y se reservó cita %', v_id_cita1, v_id_cita2;
END;
$$;

DO $$
DECLARE
    v_id_receta INT;
    v_id_sede INT;
    v_id_med INT;
    v_stock_antes INT;
    v_stock_despues INT;
BEGIN
    SELECT r.id_receta, c.id_sede, dr.id_medicamento
    INTO v_id_receta, v_id_sede, v_id_med
    FROM clinica.receta r
    JOIN clinica.consulta co ON co.id_consulta = r.id_consulta
    JOIN clinica.cita c ON c.id_cita = co.id_cita
    JOIN clinica.detalle_receta dr ON dr.id_receta = r.id_receta AND dr.num_linea = 1
    WHERE r.estado = 'pendiente'
    ORDER BY r.id_receta
    LIMIT 1;

    SELECT COALESCE(SUM(stock), 0) INTO v_stock_antes
    FROM clinica.lote_inventario
    WHERE id_medicamento = v_id_med AND id_sede = v_id_sede AND fecha_vencimiento >= CURRENT_DATE;

    BEGIN
        INSERT INTO clinica.detalle_receta (id_receta, num_linea, id_medicamento, dosis, frecuencia, duracion_dias, cantidad)
        VALUES (v_id_receta, 99, 24, '10 UI', 'Cada 24h', 30, 999999);

        CALL clinica.sp_dispensar_receta(v_id_receta, 27 + ((v_id_sede - 1) * 2), v_id_sede);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Prueba RN-14 (rollback): %', SQLERRM;
    END;

    SELECT COALESCE(SUM(stock), 0) INTO v_stock_despues
    FROM clinica.lote_inventario
    WHERE id_medicamento = v_id_med AND id_sede = v_id_sede AND fecha_vencimiento >= CURRENT_DATE;

    IF v_stock_antes <> v_stock_despues THEN
        RAISE EXCEPTION 'Fallo de atomicidad: el stock cambió tras el rollback';
    END IF;

    CALL clinica.sp_dispensar_receta(v_id_receta, 27 + ((v_id_sede - 1) * 2), v_id_sede);
    RAISE NOTICE 'Prueba RN-14: Receta % dispensada completamente bajo FEFO en sede %', v_id_receta, v_id_sede;
END;
$$;

BEGIN;
DO $$
DECLARE
    v_fecha_libre TIMESTAMP;
    v_id_sede INT;
    v_id_cita INT;
    v_id_consulta INT;
    v_id_factura INT;
    v_total NUMERIC(12,2);
    v_saldo NUMERIC(12,2);
    v_estado VARCHAR(20);
BEGIN
    SELECT (d.fecha + h.hora_inicio)::timestamp, h.id_sede
    INTO v_fecha_libre, v_id_sede
    FROM generate_series(CURRENT_DATE + 65, CURRENT_DATE + 80, INTERVAL '1 day') AS d(fecha)
    JOIN clinica.horario_medico h
      ON h.id_medico = 2
     AND h.dia_semana = EXTRACT(ISODOW FROM d.fecha)::smallint
    WHERE NOT EXISTS (
        SELECT 1 FROM clinica.cita c
        WHERE c.id_medico = 2
          AND c.fecha_hora = (d.fecha + h.hora_inicio)::timestamp
          AND c.estado <> 'cancelada'
    )
    ORDER BY d.fecha
    LIMIT 1;

    CALL clinica.sp_reservar_cita(35, 2, 2, v_id_sede, v_fecha_libre);
    SELECT id_cita INTO v_id_cita FROM clinica.cita WHERE id_medico = 2 AND fecha_hora = v_fecha_libre AND estado <> 'cancelada';

    CALL clinica.sp_cambiar_estado_cita(v_id_cita, 'confirmada');
    CALL clinica.sp_cambiar_estado_cita(v_id_cita, 'atendida');

    INSERT INTO clinica.consulta (id_cita, motivo_consulta, presion_arterial, frecuencia_cardiaca, temperatura, peso_kg, notas_clinicas)
    VALUES (v_id_cita, 'Prueba integral facturación', '120/80', 74, 36.6, 70.0, 'Sin complicaciones')
    RETURNING id_consulta INTO v_id_consulta;

    INSERT INTO clinica.consulta_diagnostico (id_consulta, id_diagnostico, es_principal, observaciones)
    VALUES (v_id_consulta, 20, TRUE, 'Revisión general');

    CALL clinica.sp_generar_factura(v_id_consulta);
    SELECT id_factura, total INTO v_id_factura, v_total FROM clinica.factura WHERE id_consulta = v_id_consulta;

    CALL clinica.sp_registrar_pago(v_id_factura, 200.00, 'efectivo', 'PAGO-PRUEBA-1');

    BEGIN
        CALL clinica.sp_registrar_pago(v_id_factura, v_total + 500.00, 'tarjeta', 'PAGO-INVALIDO');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Prueba RN-17 (exceso rechazado): %', SQLERRM;
    END;

    SELECT saldo_pendiente INTO v_saldo FROM clinica.factura WHERE id_factura = v_id_factura;
    CALL clinica.sp_registrar_pago(v_id_factura, v_saldo, 'transferencia', 'PAGO-PRUEBA-2');

    SELECT saldo_pendiente, estado INTO v_saldo, v_estado FROM clinica.factura WHERE id_factura = v_id_factura;
    RAISE NOTICE 'Prueba RN-17/18: Factura % cerrada con saldo=% y estado=%', v_id_factura, v_saldo, v_estado;
END;
$$;
COMMIT;

DO $$
DECLARE
    v_cnt INT;
BEGIN
    SET LOCAL ROLE rol_recepcion;
    SELECT COUNT(*) INTO v_cnt FROM clinica.v_agenda_diaria;
    RAISE NOTICE 'Permiso OK rol_recepcion: lectura de v_agenda_diaria (% filas)', v_cnt;
    BEGIN
        PERFORM * FROM clinica.consulta LIMIT 1;
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Restricción RN-19 OK rol_recepcion: denegado SELECT en clinica.consulta';
    END;
    RESET ROLE;

    SET LOCAL ROLE rol_medico;
    SELECT COUNT(*) INTO v_cnt FROM clinica.v_expediente_clinico;
    RAISE NOTICE 'Permiso OK rol_medico: lectura de v_expediente_clinico (% filas)', v_cnt;
    BEGIN
        PERFORM * FROM clinica.factura LIMIT 1;
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Restricción OK rol_medico: denegado SELECT en clinica.factura';
    END;
    RESET ROLE;

    SET LOCAL ROLE rol_farmacia;
    SELECT COUNT(*) INTO v_cnt FROM clinica.v_inventario_por_vencer;
    RAISE NOTICE 'Permiso OK rol_farmacia: lectura de v_inventario_por_vencer (% filas)', v_cnt;
    BEGIN
        PERFORM * FROM clinica.consulta_diagnostico LIMIT 1;
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Restricción RN-19 OK rol_farmacia: denegado SELECT en clinica.consulta_diagnostico';
    END;
    RESET ROLE;

    SET LOCAL ROLE rol_auditor;
    SELECT COUNT(*) INTO v_cnt FROM clinica.auditoria;
    RAISE NOTICE 'Permiso OK rol_auditor: lectura de clinica.auditoria (% filas)', v_cnt;
    BEGIN
        DELETE FROM clinica.auditoria WHERE id_auditoria = -1;
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Restricción OK rol_auditor: denegado DELETE en clinica.auditoria';
    END;
    RESET ROLE;
END;
$$;
