CREATE OR REPLACE FUNCTION clinica.fn_validar_menor_responsable()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_pac DATE;
    v_fecha_resp DATE;
BEGIN
    SELECT fecha_nacimiento INTO v_fecha_pac
    FROM clinica.persona
    WHERE id_persona = NEW.id_persona;

    IF age(CURRENT_DATE, v_fecha_pac) < INTERVAL '18 years' AND NEW.id_responsable IS NULL THEN
        RAISE EXCEPTION 'Todo paciente menor de edad debe tener un paciente responsable.';
    END IF;

    IF NEW.id_responsable IS NOT NULL THEN
        SELECT p.fecha_nacimiento INTO v_fecha_resp
        FROM clinica.paciente pac
        JOIN clinica.persona p ON p.id_persona = pac.id_persona
        WHERE pac.id_persona = NEW.id_responsable;

        IF NOT FOUND OR age(CURRENT_DATE, v_fecha_resp) < INTERVAL '18 years' THEN
            RAISE EXCEPTION 'El responsable (%) debe ser un paciente mayor de edad.', NEW.id_responsable;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_menor_responsable
BEFORE INSERT OR UPDATE ON clinica.paciente
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_menor_responsable();

CREATE OR REPLACE FUNCTION clinica.fn_validar_subtipo_empleado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo VARCHAR(20);
    v_esperado VARCHAR(20);
BEGIN
    v_esperado := TG_ARGV[0];

    SELECT tipo_empleado INTO v_tipo
    FROM clinica.empleado
    WHERE id_persona = NEW.id_persona;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La persona % no existe como empleado.', NEW.id_persona;
    END IF;

    IF v_tipo <> v_esperado THEN
        RAISE EXCEPTION 'El empleado % tiene tipo %, no %.', NEW.id_persona, v_tipo, v_esperado;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_subtipo_medico
BEFORE INSERT OR UPDATE ON clinica.medico
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_subtipo_empleado('medico');

CREATE TRIGGER trg_validar_subtipo_recepcionista
BEFORE INSERT OR UPDATE ON clinica.recepcionista
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_subtipo_empleado('recepcionista');

CREATE TRIGGER trg_validar_subtipo_farmaceutico
BEFORE INSERT OR UPDATE ON clinica.farmaceutico
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_subtipo_empleado('farmaceutico');

CREATE OR REPLACE FUNCTION clinica.fn_validar_solapamiento_horario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM clinica.horario_medico h
        WHERE h.id_medico = NEW.id_medico
          AND h.dia_semana = NEW.dia_semana
          AND h.id_horario <> COALESCE(NEW.id_horario, -1)
          AND NEW.hora_inicio < h.hora_fin
          AND NEW.hora_fin > h.hora_inicio
    ) THEN
        RAISE EXCEPTION 'El horario del médico % en día % se solapa con otro bloque existente.', NEW.id_medico, NEW.dia_semana;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_solapamiento_horario
BEFORE INSERT OR UPDATE ON clinica.horario_medico
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_solapamiento_horario();

CREATE OR REPLACE FUNCTION clinica.fn_validar_horario_cita()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_dia SMALLINT;
    v_hora TIME;
BEGIN
    IF NEW.estado = 'cancelada' THEN
        RETURN NEW;
    END IF;

    v_dia := EXTRACT(ISODOW FROM NEW.fecha_hora)::smallint;
    v_hora := NEW.fecha_hora::time;

    IF NOT EXISTS (
        SELECT 1
        FROM clinica.horario_medico h
        WHERE h.id_medico = NEW.id_medico
          AND h.id_sede = NEW.id_sede
          AND h.dia_semana = v_dia
          AND v_hora >= h.hora_inicio
          AND (v_hora + INTERVAL '30 minutes') <= h.hora_fin
    ) THEN
        RAISE EXCEPTION 'La cita (%) está fuera del horario del médico % en la sede %.', NEW.fecha_hora, NEW.id_medico, NEW.id_sede;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_horario_cita
BEFORE INSERT OR UPDATE ON clinica.cita
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_horario_cita();

CREATE OR REPLACE FUNCTION clinica.fn_validar_transicion_cita()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.estado = OLD.estado THEN
        RETURN NEW;
    END IF;

    IF OLD.estado = 'programada' AND NEW.estado IN ('confirmada', 'cancelada') THEN
        RETURN NEW;
    ELSIF OLD.estado = 'confirmada' AND NEW.estado IN ('atendida', 'cancelada', 'no_asistio') THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Transición de estado inválida en cita %: de % a %.', OLD.id_cita, OLD.estado, NEW.estado;
    END IF;
END;
$$;

CREATE TRIGGER trg_validar_transicion_cita
BEFORE UPDATE OF estado ON clinica.cita
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_transicion_cita();

CREATE OR REPLACE FUNCTION clinica.fn_validar_consulta_cita()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado VARCHAR(20);
BEGIN
    SELECT estado INTO v_estado
    FROM clinica.cita
    WHERE id_cita = NEW.id_cita;

    IF NOT FOUND OR v_estado <> 'atendida' THEN
        RAISE EXCEPTION 'Solo las citas en estado atendida pueden generar una consulta (cita %, estado %).', NEW.id_cita, v_estado;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_consulta_cita
BEFORE INSERT OR UPDATE OF id_cita ON clinica.consulta
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_consulta_cita();

CREATE OR REPLACE FUNCTION clinica.fn_validar_diagnostico_principal()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_consulta INT;
    v_total INT;
    v_principales INT;
BEGIN
    v_id_consulta := COALESCE(NEW.id_consulta, OLD.id_consulta);

    IF NOT EXISTS (SELECT 1 FROM clinica.consulta WHERE id_consulta = v_id_consulta) THEN
        RETURN NULL;
    END IF;

    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE es_principal)
    INTO v_total, v_principales
    FROM clinica.consulta_diagnostico
    WHERE id_consulta = v_id_consulta;

    IF v_total = 0 OR v_principales <> 1 THEN
        RAISE EXCEPTION 'La consulta % debe tener al menos un diagnóstico y exactamente uno principal (actuales: total=%, principales=%).',
            v_id_consulta, v_total, v_principales;
    END IF;

    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_validar_diagnostico_principal
AFTER INSERT OR UPDATE OR DELETE ON clinica.consulta_diagnostico
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_validar_diagnostico_principal();

CREATE OR REPLACE FUNCTION clinica.fn_procesar_pago()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_saldo NUMERIC(12,2);
    v_estado VARCHAR(20);
    v_nuevo_saldo NUMERIC(12,2);
BEGIN
    SELECT saldo_pendiente, estado
    INTO v_saldo, v_estado
    FROM clinica.factura
    WHERE id_factura = NEW.id_factura
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la factura %.', NEW.id_factura;
    END IF;

    IF v_estado IN ('pagada', 'anulada') THEN
        RAISE EXCEPTION 'La factura % tiene estado % y no admite más pagos.', NEW.id_factura, v_estado;
    END IF;

    IF NEW.monto > v_saldo THEN
        RAISE EXCEPTION 'El monto (%) supera el saldo pendiente (%) de la factura %.', NEW.monto, v_saldo, NEW.id_factura;
    END IF;

    v_nuevo_saldo := v_saldo - NEW.monto;

    UPDATE clinica.factura
    SET saldo_pendiente = v_nuevo_saldo,
        estado = CASE WHEN v_nuevo_saldo = 0 THEN 'pagada' ELSE 'parcial' END
    WHERE id_factura = NEW.id_factura;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_procesar_pago
BEFORE INSERT ON clinica.pago
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_procesar_pago();

CREATE OR REPLACE FUNCTION clinica.fn_auditar_cita()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = clinica, pg_temp
AS $$
DECLARE
    v_actor NAME;
BEGIN
    v_actor := COALESCE(NULLIF(current_setting('role', true), 'none'), session_user);

    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        INSERT INTO clinica.auditoria (
            tabla_afectada,
            id_registro,
            campo_modificado,
            valor_anterior,
            valor_nuevo,
            usuario_bd
        ) VALUES (
            'cita',
            OLD.id_cita,
            'estado',
            OLD.estado,
            NEW.estado,
            v_actor
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auditar_cita
AFTER UPDATE ON clinica.cita
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_auditar_cita();

CREATE OR REPLACE FUNCTION clinica.fn_auditar_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = clinica, pg_temp
AS $$
DECLARE
    v_actor NAME;
BEGIN
    v_actor := COALESCE(NULLIF(current_setting('role', true), 'none'), session_user);

    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        INSERT INTO clinica.auditoria (
            tabla_afectada,
            id_registro,
            campo_modificado,
            valor_anterior,
            valor_nuevo,
            usuario_bd
        ) VALUES (
            'factura',
            OLD.id_factura,
            'estado',
            OLD.estado,
            NEW.estado,
            v_actor
        );
    END IF;

    IF NEW.total IS DISTINCT FROM OLD.total THEN
        INSERT INTO clinica.auditoria (
            tabla_afectada,
            id_registro,
            campo_modificado,
            valor_anterior,
            valor_nuevo,
            usuario_bd
        ) VALUES (
            'factura',
            OLD.id_factura,
            'total',
            OLD.total::text,
            NEW.total::text,
            v_actor
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auditar_factura
AFTER UPDATE ON clinica.factura
FOR EACH ROW
EXECUTE FUNCTION clinica.fn_auditar_factura();
