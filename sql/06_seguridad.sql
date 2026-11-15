DO $$
DECLARE
    r_name TEXT;
BEGIN
    FOREACH r_name IN ARRAY ARRAY['rol_recepcion', 'rol_medico', 'rol_farmacia', 'rol_auditor']
    LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r_name) THEN
            EXECUTE format('CREATE ROLE %I NOLOGIN', r_name);
        ELSE
            EXECUTE format('REVOKE ALL ON SCHEMA clinica FROM %I', r_name);
            EXECUTE format('REVOKE ALL ON ALL TABLES IN SCHEMA clinica FROM %I', r_name);
            EXECUTE format('REVOKE ALL ON ALL SEQUENCES IN SCHEMA clinica FROM %I', r_name);
            EXECUTE format('REVOKE ALL ON ALL FUNCTIONS IN SCHEMA clinica FROM %I', r_name);
            EXECUTE format('REVOKE ALL ON ALL PROCEDURES IN SCHEMA clinica FROM %I', r_name);
        END IF;
    END LOOP;
END;
$$;

REVOKE ALL ON SCHEMA clinica FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA clinica FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA clinica FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA clinica FROM PUBLIC;
REVOKE ALL ON ALL PROCEDURES IN SCHEMA clinica FROM PUBLIC;

GRANT USAGE ON SCHEMA clinica TO rol_recepcion, rol_medico, rol_farmacia, rol_auditor;

GRANT SELECT ON
    clinica.sede,
    clinica.aseguradora,
    clinica.empleado,
    clinica.medico,
    clinica.especialidad,
    clinica.medico_especialidad,
    clinica.horario_medico,
    clinica.v_agenda_diaria,
    clinica.v_resumen_facturacion
TO rol_recepcion;

GRANT SELECT, INSERT, UPDATE ON
    clinica.persona,
    clinica.paciente,
    clinica.cita,
    clinica.factura,
    clinica.detalle_factura,
    clinica.pago
TO rol_recepcion;

GRANT USAGE, SELECT ON SEQUENCE
    clinica.persona_id_persona_seq,
    clinica.cita_id_cita_seq,
    clinica.factura_id_factura_seq,
    clinica.detalle_factura_id_detalle_factura_seq,
    clinica.pago_id_pago_seq
TO rol_recepcion;

GRANT EXECUTE ON FUNCTION clinica.fn_disponibilidad_medico(INT, DATE) TO rol_recepcion;
GRANT EXECUTE ON PROCEDURE
    clinica.sp_reservar_cita(INT, INT, INT, INT, TIMESTAMP),
    clinica.sp_cambiar_estado_cita(INT, VARCHAR),
    clinica.sp_generar_factura(INT),
    clinica.sp_registrar_pago(INT, NUMERIC, VARCHAR, VARCHAR)
TO rol_recepcion;

GRANT SELECT ON
    clinica.sede,
    clinica.persona,
    clinica.paciente,
    clinica.aseguradora,
    clinica.empleado,
    clinica.medico,
    clinica.especialidad,
    clinica.medico_especialidad,
    clinica.horario_medico,
    clinica.cita,
    clinica.diagnostico_catalogo,
    clinica.medicamento,
    clinica.v_agenda_diaria,
    clinica.v_expediente_clinico
TO rol_medico;

GRANT SELECT, INSERT, UPDATE ON
    clinica.consulta,
    clinica.consulta_diagnostico,
    clinica.receta,
    clinica.detalle_receta
TO rol_medico;

GRANT USAGE, SELECT ON SEQUENCE
    clinica.consulta_id_consulta_seq,
    clinica.receta_id_receta_seq
TO rol_medico;

GRANT EXECUTE ON FUNCTION clinica.fn_disponibilidad_medico(INT, DATE) TO rol_medico;

GRANT SELECT ON
    clinica.sede,
    clinica.persona,
    clinica.paciente,
    clinica.empleado,
    clinica.farmaceutico,
    clinica.medicamento,
    clinica.receta,
    clinica.detalle_receta,
    clinica.v_inventario_por_vencer
TO rol_farmacia;

GRANT UPDATE (estado, id_farmaceutico_dispensa, fecha_dispensacion) ON clinica.receta TO rol_farmacia;

GRANT SELECT, INSERT, UPDATE ON
    clinica.lote_inventario,
    clinica.dispensacion_lote
TO rol_farmacia;

GRANT USAGE, SELECT ON SEQUENCE
    clinica.lote_inventario_id_lote_seq,
    clinica.dispensacion_lote_id_dispensacion_seq
TO rol_farmacia;

GRANT EXECUTE ON PROCEDURE clinica.sp_dispensar_receta(INT, INT, INT) TO rol_farmacia;

GRANT SELECT ON
    clinica.auditoria,
    clinica.sede,
    clinica.aseguradora,
    clinica.persona,
    clinica.paciente,
    clinica.empleado,
    clinica.medico,
    clinica.recepcionista,
    clinica.farmaceutico,
    clinica.especialidad,
    clinica.cita,
    clinica.factura,
    clinica.detalle_factura,
    clinica.pago,
    clinica.lote_inventario,
    clinica.dispensacion_lote,
    clinica.v_agenda_diaria,
    clinica.v_inventario_por_vencer,
    clinica.v_resumen_facturacion
TO rol_auditor;
