/*
 * Consulta 1: ¿Qué citas tiene una sede en un rango de fechas, de la más próxima a la más lejana?
 * Solución: Filtra clinica.cita por sede y rango de fechas con BETWEEN y ordena ascendentemente por fecha_hora.
 * Muestra de resultado:
 *  id_cita |    sede     |     fecha_hora      |   estado   |           medico           |          paciente
 * ---------+-------------+---------------------+------------+----------------------------+----------------------------
 *    16203 | Sede Centro | 2026-11-20 08:00:00 | programada | José García García         | Miguel García Martínez
 *    16206 | Sede Centro | 2026-11-20 08:00:00 | programada | Laura García López         | Andrea Rodríguez González
 */
SELECT
    c.id_cita,
    s.nombre AS sede,
    c.fecha_hora,
    c.estado,
    pm.nombres || ' ' || pm.apellidos AS medico,
    pp.nombres || ' ' || pp.apellidos AS paciente
FROM clinica.cita c
JOIN clinica.sede s ON s.id_sede = c.id_sede
JOIN clinica.persona pm ON pm.id_persona = c.id_medico
JOIN clinica.persona pp ON pp.id_persona = c.id_paciente
WHERE c.id_sede = 1
  AND c.fecha_hora BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '7 days'
ORDER BY c.fecha_hora ASC
LIMIT 15;

/*
 * Consulta 2: ¿Qué pacientes no tienen aseguradora? Mostrar «Particular» en su lugar.
 * Solución: Une clinica.paciente con clinica.aseguradora mediante LEFT JOIN, filtra IS NULL y reemplaza NULL con COALESCE.
 * Muestra de resultado:
 *  id_persona |       paciente       | cobertura
 * ------------+----------------------+------------
 *          21 | Carlos López Pérez   | Particular
 *          27 | Juan López Ramírez   | Particular
 */
SELECT
    p.id_persona,
    per.nombres || ' ' || per.apellidos AS paciente,
    COALESCE(a.nombre, 'Particular') AS cobertura
FROM clinica.paciente p
JOIN clinica.persona per ON per.id_persona = p.id_persona
LEFT JOIN clinica.aseguradora a ON a.id_aseguradora = p.id_aseguradora
WHERE p.id_aseguradora IS NULL
ORDER BY p.id_persona
LIMIT 15;

/*
 * Consulta 3: ¿Qué pacientes coinciden con un nombre parcial, por páginas de 20 y con el nombre formateado?
 * Solución: Usa ILIKE para búsqueda sin distinguir mayúsculas, formatea con UPPER/SPLIT_PART/INITCAP y pagina con LIMIT 20 OFFSET 0.
 * Muestra de resultado:
 *  id_persona |    nombre_formateado    |  telefono  |             correo
 * ------------+-------------------------+------------+--------------------------------
 *         371 | CHÁVEZ, Carlos Eduardo  | 6621000371 | persona371@clinicavidaplena.mx
 *         361 | CHÁVEZ, Carlos          | 6621000361 | persona361@clinicavidaplena.mx
 */
SELECT
    p.id_persona,
    UPPER(SPLIT_PART(per.apellidos, ' ', 1)) || ', ' || INITCAP(per.nombres) AS nombre_formateado,
    per.telefono,
    per.correo
FROM clinica.paciente p
JOIN clinica.persona per ON per.id_persona = p.id_persona
WHERE (per.nombres || ' ' || per.apellidos) ILIKE '%Carlos%'
ORDER BY per.apellidos, per.nombres
LIMIT 20 OFFSET 0;

/*
 * Consulta 4: ¿Qué especialidades superaron 20 citas por mes en el último año?
 * Solución: Agrupa citas activas por especialidad y mes con date_trunc('month', fecha_hora) y filtra grupos con HAVING COUNT(*) > 20.
 * Muestra de resultado:
 *    especialidad   |   mes   | total_citas
 * ------------------+---------+-------------
 *  Medicina General | 2026-12 |        1360
 *  Traumatología    | 2026-12 |         680
 */
SELECT
    e.nombre AS especialidad,
    TO_CHAR(date_trunc('month', c.fecha_hora), 'YYYY-MM') AS mes,
    COUNT(*) AS total_citas
FROM clinica.cita c
JOIN clinica.especialidad e ON e.id_especialidad = c.id_especialidad
WHERE c.fecha_hora >= CURRENT_DATE - INTERVAL '1 year'
  AND c.estado <> 'cancelada'
GROUP BY e.nombre, date_trunc('month', c.fecha_hora)
HAVING COUNT(*) > 20
ORDER BY date_trunc('month', c.fecha_hora) DESC, total_citas DESC
LIMIT 15;

/*
 * Consulta 5: ¿Cuál es la agenda del día, con paciente, médico, especialidad y sede?
 * Solución: Enlaza cita con sede, especialidad, medico, paciente y persona filtrando fecha_hora::date = CURRENT_DATE.
 * Muestra de resultado:
 *  id_cita |   hora   |    sede     |   especialidad   |           medico           |          paciente          |   estado
 * ---------+----------+-------------+------------------+----------------------------+----------------------------+------------
 *       11 | 08:00:00 | Sede Centro | Pediatría        | Valeria García Rodríguez   | Luis Martínez Cruz         | programada
 *       17 | 08:00:00 | Sede Centro | Oftalmología     | Andrea García González     | José Torres García         | programada
 */
SELECT
    c.id_cita,
    c.fecha_hora::time AS hora,
    s.nombre AS sede,
    e.nombre AS especialidad,
    pm.nombres || ' ' || pm.apellidos AS medico,
    pp.nombres || ' ' || pp.apellidos AS paciente,
    c.estado
FROM clinica.cita c
JOIN clinica.sede s ON s.id_sede = c.id_sede
JOIN clinica.especialidad e ON e.id_especialidad = c.id_especialidad
JOIN clinica.medico med ON med.id_persona = c.id_medico
JOIN clinica.persona pm ON pm.id_persona = med.id_persona
JOIN clinica.paciente pac ON pac.id_persona = c.id_paciente
JOIN clinica.persona pp ON pp.id_persona = pac.id_persona
WHERE c.fecha_hora::date = CURRENT_DATE
ORDER BY c.fecha_hora, s.nombre
LIMIT 15;

/*
 * Consulta 6: ¿Cuántas citas tuvo cada médico este mes, incluidos los que no tuvieron ninguna?
 * Solución: Parte de clinica.medico con LEFT JOIN hacia clinica.cita filtrando el mes actual en el ON para conservar los ceros.
 * Muestra de resultado:
 *  id_medico |         medico         | citas_mes_actual
 * -----------+------------------------+------------------
 *          9 | Miguel García Martínez |                0
 *         20 | Lucía García Ramos     |                0
 *          1 | Carlos García Pérez    |              470
 */
SELECT
    med.id_persona AS id_medico,
    pm.nombres || ' ' || pm.apellidos AS medico,
    COUNT(c.id_cita) AS citas_mes_actual
FROM clinica.medico med
JOIN clinica.persona pm ON pm.id_persona = med.id_persona
LEFT JOIN clinica.cita c
    ON c.id_medico = med.id_persona
   AND c.fecha_hora >= date_trunc('month', CURRENT_DATE)
   AND c.fecha_hora < date_trunc('month', CURRENT_DATE) + INTERVAL '1 month'
   AND c.estado <> 'cancelada'
GROUP BY med.id_persona, pm.nombres, pm.apellidos
ORDER BY citas_mes_actual ASC, med.id_persona;

/*
 * Consulta 7: ¿Cuántas citas hubo por cada combinación de sede y especialidad, incluidas las que suman cero?
 * Solución: Genera todas las combinaciones con CROSS JOIN entre sede y especialidad y hace LEFT JOIN con cita para contar inclusive ceros.
 * Muestra de resultado:
 *     sede     | especialidad | total_citas
 * -------------+--------------+-------------
 *  Sede Norte  | Psiquiatría  |           0
 *  Sede Sur    | Cardiología  |           0
 *  Sede Sur    | Neurología   |           0
 */
SELECT
    s.nombre AS sede,
    e.nombre AS especialidad,
    COUNT(c.id_cita) AS total_citas
FROM clinica.sede s
CROSS JOIN clinica.especialidad e
LEFT JOIN clinica.cita c
    ON c.id_sede = s.id_sede
   AND c.id_especialidad = e.id_especialidad
   AND c.estado <> 'cancelada'
GROUP BY s.nombre, e.nombre
ORDER BY total_citas ASC, s.nombre, e.nombre;

/*
 * Consulta 8: ¿Qué pacientes menores tienen responsable, y quién es?
 * Solución: Aplica un self join de clinica.paciente consigo misma mediante id_responsable y obtiene ambos nombres desde clinica.persona.
 * Muestra de resultado:
 *  id_menor |      paciente_menor       | edad | id_responsable |       responsable       | telefono_responsable
 * ----------+---------------------------+------+----------------+-------------------------+----------------------
 *       478 | Andrea Rodríguez González |   15 |             33 | Jorge López Flores      | 6621000033
 *       479 | Fernando Rodríguez Gómez  |   15 |             34 | Paola López Gutiérrez   | 6621000034
 */
SELECT
    men.id_persona AS id_menor,
    pmen.nombres || ' ' || pmen.apellidos AS paciente_menor,
    DATE_PART('year', age(CURRENT_DATE, pmen.fecha_nacimiento))::int AS edad,
    resp.id_persona AS id_responsable,
    presp.nombres || ' ' || presp.apellidos AS responsable,
    presp.telefono AS telefono_responsable
FROM clinica.paciente men
JOIN clinica.persona pmen ON pmen.id_persona = men.id_persona
JOIN clinica.paciente resp ON resp.id_persona = men.id_responsable
JOIN clinica.persona presp ON presp.id_persona = resp.id_persona
ORDER BY men.id_persona
LIMIT 15;

/*
 * Consulta 9: ¿Qué medicamentos del catálogo nunca se han recetado?
 * Solución: Selecciona filas de clinica.medicamento donde NOT EXISTS ningún registro relacionado en clinica.detalle_receta.
 * Muestra de resultado:
 *  id_medicamento | codigo  |      nombre       |     presentacion      | precio_unitario
 * ----------------+---------+-------------------+-----------------------+-----------------
 *              24 | MED-024 | Insulina Glargina | Pluma precargada 3 ml |          680.00
 *              25 | MED-025 | Rivaroxabán 20mg  | Caja con 28 tabletas  |          890.00
 */
SELECT
    m.id_medicamento,
    m.codigo,
    m.nombre,
    m.presentacion,
    m.precio_unitario
FROM clinica.medicamento m
WHERE NOT EXISTS (
    SELECT 1
    FROM clinica.detalle_receta dr
    WHERE dr.id_medicamento = m.id_medicamento
)
ORDER BY m.id_medicamento;

/*
 * Consulta 10: ¿Qué médicos facturan más que el promedio de su especialidad?
 * Solución: Calcula la facturación por médico y especialidad en un CTE y compara cada fila contra el promedio mediante subconsulta correlacionada.
 * Muestra de resultado:
 *             medico             |   especialidad   | total_facturado
 * -------------------------------+------------------+-----------------
 *  Ana García Sánchez            | Dermatología     |       869433.00
 *  Luis García Cruz              | Ginecología      |      1094906.00
 */
WITH facturacion_medico AS (
    SELECT
        med.id_persona AS id_medico,
        pm.nombres || ' ' || pm.apellidos AS medico,
        c.id_especialidad,
        e.nombre AS especialidad,
        SUM(f.total) AS total_facturado
    FROM clinica.factura f
    JOIN clinica.consulta co ON co.id_consulta = f.id_consulta
    JOIN clinica.cita c ON c.id_cita = co.id_cita
    JOIN clinica.medico med ON med.id_persona = c.id_medico
    JOIN clinica.persona pm ON pm.id_persona = med.id_persona
    JOIN clinica.especialidad e ON e.id_especialidad = c.id_especialidad
    WHERE f.estado <> 'anulada'
    GROUP BY med.id_persona, pm.nombres, pm.apellidos, c.id_especialidad, e.nombre
)
SELECT
    fm.medico,
    fm.especialidad,
    fm.total_facturado
FROM facturacion_medico fm
WHERE fm.total_facturado > (
    SELECT AVG(fm2.total_facturado)
    FROM facturacion_medico fm2
    WHERE fm2.id_especialidad = fm.id_especialidad
)
ORDER BY fm.especialidad, fm.total_facturado DESC;

/*
 * Consulta 11: ¿Qué personas son empleados y pacientes a la vez?
 * Solución: Intersecta los identificadores y nombres de clinica.empleado y clinica.paciente usando INTERSECT.
 * Muestra de resultado:
 *  id_persona |   nombre_completo
 * ------------+---------------------
 *           1 | Carlos García Pérez
 *           2 | María García Díaz
 *          21 | Carlos López Pérez
 */
SELECT p.id_persona, per.nombres || ' ' || per.apellidos AS nombre_completo
FROM clinica.empleado e
JOIN clinica.persona per ON per.id_persona = e.id_persona
JOIN clinica.persona p ON p.id_persona = e.id_persona
INTERSECT
SELECT pac.id_persona, per.nombres || ' ' || per.apellidos AS nombre_completo
FROM clinica.paciente pac
JOIN clinica.persona per ON per.id_persona = pac.id_persona
ORDER BY id_persona;

/*
 * Consulta 12: ¿Qué lotes vencen en los próximos 90 días, por sede y con su stock?
 * Solución: Une lote_inventario con sede y medicamento, filtrando fecha_vencimiento entre CURRENT_DATE y +90 días con stock > 0.
 * Muestra de resultado:
 *     sede     | codigo  |   medicamento    | numero_lote | fecha_vencimiento | dias_restantes | stock
 * -------------+---------+------------------+-------------+-------------------+----------------+-------
 *  Sede Centro | MED-017 | Sumatriptán 50mg | LOTE-17-1-1 | 2026-12-04        |             15 |    58
 *  Sede Sur    | MED-014 | Enalapril 10mg   | LOTE-14-3-1 | 2026-12-05        |             16 |    57
 */
SELECT
    s.nombre AS sede,
    m.codigo,
    m.nombre AS medicamento,
    l.numero_lote,
    l.fecha_vencimiento,
    (l.fecha_vencimiento - CURRENT_DATE) AS dias_restantes,
    l.stock
FROM clinica.lote_inventario l
JOIN clinica.sede s ON s.id_sede = l.id_sede
JOIN clinica.medicamento m ON m.id_medicamento = l.id_medicamento
WHERE l.fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days'
  AND l.stock > 0
ORDER BY l.fecha_vencimiento ASC, s.nombre
LIMIT 15;

/*
 * Consulta 13: ¿Cómo cambian las citas por especialidad entre este mes y el anterior, incluidas las que solo aparecen en uno?
 * Solución: Construye dos CTE (mes_actual y mes_anterior) y los combina con FULL OUTER JOIN para no perder especialidades exclusivas de un mes.
 * Muestra de resultado:
 *    especialidad   | citas_mes_anterior | citas_mes_actual | diferencia
 * ------------------+--------------------+------------------+------------
 *  Nutrición        |                  0 |              470 |        470
 *  Psiquiatría      |                486 |                0 |       -486
 */
WITH mes_actual AS (
    SELECT id_especialidad, COUNT(*) AS citas_actual
    FROM clinica.cita
    WHERE fecha_hora >= date_trunc('month', CURRENT_DATE)
      AND fecha_hora < date_trunc('month', CURRENT_DATE) + INTERVAL '1 month'
      AND estado <> 'cancelada'
    GROUP BY id_especialidad
),
mes_anterior AS (
    SELECT id_especialidad, COUNT(*) AS citas_anterior
    FROM clinica.cita
    WHERE fecha_hora >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
      AND fecha_hora < date_trunc('month', CURRENT_DATE)
      AND estado <> 'cancelada'
    GROUP BY id_especialidad
)
SELECT
    e.nombre AS especialidad,
    COALESCE(man.citas_anterior, 0) AS citas_mes_anterior,
    COALESCE(mac.citas_actual, 0) AS citas_mes_actual,
    COALESCE(mac.citas_actual, 0) - COALESCE(man.citas_anterior, 0) AS diferencia
FROM mes_anterior man
FULL OUTER JOIN mes_actual mac ON mac.id_especialidad = man.id_especialidad
JOIN clinica.especialidad e ON e.id_especialidad = COALESCE(mac.id_especialidad, man.id_especialidad)
ORDER BY e.nombre;

/*
 * Consulta 14: ¿Cuál es el ranking de médicos por citas atendidas dentro de cada especialidad?
 * Solución: Agrupa citas con estado 'atendida' por especialidad y médico y asigna posición con DENSE_RANK() OVER (PARTITION BY e.id_especialidad).
 * Muestra de resultado:
 *    especialidad   |         medico         | citas_atendidas | posicion
 * ------------------+------------------------+-----------------+----------
 *  Cardiología      | Jorge García Flores    |            2187 |        1
 *  Dermatología     | Ana García Sánchez     |            1802 |        1
 *  Dermatología     | Paola García Gutiérrez |            1801 |        2
 */
SELECT
    e.nombre AS especialidad,
    pm.nombres || ' ' || pm.apellidos AS medico,
    COUNT(c.id_cita) AS citas_atendidas,
    DENSE_RANK() OVER (PARTITION BY e.id_especialidad ORDER BY COUNT(c.id_cita) DESC) AS posicion
FROM clinica.cita c
JOIN clinica.medico med ON med.id_persona = c.id_medico
JOIN clinica.persona pm ON pm.id_persona = med.id_persona
JOIN clinica.especialidad e ON e.id_especialidad = c.id_especialidad
WHERE c.estado = 'atendida'
GROUP BY e.id_especialidad, e.nombre, med.id_persona, pm.nombres, pm.apellidos
ORDER BY e.nombre, posicion, medico;

/*
 * Consulta 15: ¿Cuál fue la última consulta de cada paciente?
 * Solución: Numera las consultas de cada paciente de la más reciente a la más antigua con ROW_NUMBER() y filtra rn = 1.
 * Muestra de resultado:
 *  id_paciente |      paciente       | id_consulta |   fecha_consulta    |          motivo_consulta
 * -------------+---------------------+-------------+---------------------+------------------------------------
 *            1 | Carlos García Pérez |         181 | 2026-11-18 12:10:00 | Dolor de cabeza y malestar general
 *            2 | María García Díaz   |         166 | 2026-11-18 12:40:00 | Dolor lumbar agudo
 */
WITH historial AS (
    SELECT
        c.id_paciente,
        pp.nombres || ' ' || pp.apellidos AS paciente,
        co.id_consulta,
        co.fecha_consulta,
        co.motivo_consulta,
        ROW_NUMBER() OVER (PARTITION BY c.id_paciente ORDER BY co.fecha_consulta DESC, co.id_consulta DESC) AS rn
    FROM clinica.consulta co
    JOIN clinica.cita c ON c.id_cita = co.id_cita
    JOIN clinica.persona pp ON pp.id_persona = c.id_paciente
)
SELECT
    id_paciente,
    paciente,
    id_consulta,
    fecha_consulta,
    motivo_consulta
FROM historial
WHERE rn = 1
ORDER BY id_paciente
LIMIT 15;
