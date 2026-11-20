# Clínica Vida Plena — Base de datos en PostgreSQL

Base de datos centralizada en el esquema `clinica` para gestionar sedes, personal, horarios, citas, consultas, diagnósticos, recetas, inventario por lote, facturación, pagos, auditoría y control de acceso por roles.

## Integrantes

- **Sayer** — Modelado E-R, normalización, scripts SQL (`01` a `08`), pruebas de concurrencia/seguridad, respaldo y documentación.

## Requisitos e instalación

- PostgreSQL 16 o superior (probado en PostgreSQL 18.7) con `psql`, `pg_dump` y `pg_restore`.
- Ejecutar el proyecto completo sobre una base de datos vacía:

```bash
createdb clinica_vida_plena
psql -d clinica_vida_plena -f ejecutar_todo.sql
```

`ejecutar_todo.sql` ejecuta en orden los scripts `sql/01_esquema.sql` a `sql/08_transacciones.sql` con `ON_ERROR_STOP` activo.

Para restaurar desde el respaldo incluido:

```bash
createdb clinica_restaurada
pg_restore -d clinica_restaurada respaldo/clinica.dump
```

## Estructura del repositorio

- `ejecutar_todo.sql`: script maestro para reconstruir la base desde cero.
- `sql/01_esquema.sql`: esquema `clinica`, 24 tablas, llaves primarias, foráneas, `CHECK`, `UNIQUE` e índices únicos parciales.
- `sql/02_datos.sql`: carga inicial con 3 sedes, 20 médicos, 500 pacientes y 50,000 citas válidas usando `generate_series`.
- `sql/03_vistas_indices.sql`: 4 vistas operativas y 10 índices de rendimiento.
- `sql/04_funciones_procedimientos.sql`: funciones y procedimientos para disponibilidad, citas, dispensación FEFO, facturación y pagos.
- `sql/05_triggers.sql`: validaciones de reglas de negocio, control de saldos y auditoría automática.
- `sql/06_seguridad.sql`: roles `rol_recepcion`, `rol_medico`, `rol_farmacia` y `rol_auditor` sin contraseñas (`NOLOGIN`).
- `sql/07_consultas.sql`: las 15 consultas de negocio con explicación y muestra de resultados.
- `sql/08_transacciones.sql`: pruebas automáticas de reservas, dispensación atómica, pagos y permisos con `SET ROLE`.
- `docs/`: diagrama E-R (`modelo_er.pdf`), esquema relacional (`esquema_relacional.pdf`), normalización (`normalizacion.md`), planes de ejecución (`rendimiento.md`), matriz de permisos (`permisos.md`) y capturas (`evidencias/`).
- `respaldo/clinica.dump`: respaldo en formato personalizado generado con `pg_dump -Fc`.

## Supuestos documentados

1. **Bloques de cita (RN-06):** Todas las citas duran 30 minutos exactos e inician en punto (`:00`) o a la media hora (`:30`), dentro de un bloque definido en `horario_medico`.
2. **Responsable de menores (RN-02):** Se considera menor de edad a toda persona menor de 18 años; su `id_responsable` debe apuntar a otro paciente mayor de edad.
3. **Subtipos de empleado (RN-03):** Un empleado pertenece exactamente a un subtipo (`medico`, `recepcionista` o `farmaceutico`), validado por trigger.
4. **Cobertura de aseguradora (RN-16):** El porcentaje de cobertura se guarda en `factura` al momento de emitirla para que cambios posteriores en el catálogo de aseguradoras no alteren facturas previas. La suma `monto_seguro + monto_paciente` siempre iguala `total`.
5. **Dispensación FEFO (RN-14):** Al dispensar una receta en una sede se descuentan primero los lotes vigentes (`fecha_vencimiento >= CURRENT_DATE`) más próximos a vencer usando `SELECT ... FOR UPDATE`. Si falta stock en cualquier línea, se revierte toda la receta.
6. **Seguridad sin contraseñas:** Los roles se definen con `NOLOGIN` para usar `SET ROLE` y asignar usuarios reales solo al desplegar en producción.

## Reparto de trabajo

| Área | Responsable | Entregables |
| :--- | :--- | :--- |
| Modelado y normalización | Sayer | `docs/modelo_er.pdf`, `docs/esquema_relacional.pdf`, `docs/normalizacion.md` |
| Esquema, datos e índices | Sayer | `sql/01_esquema.sql`, `sql/02_datos.sql`, `sql/03_vistas_indices.sql`, `docs/rendimiento.md` |
| Lógica en servidor y consultas | Sayer | `sql/04_funciones_procedimientos.sql`, `sql/05_triggers.sql`, `sql/07_consultas.sql` |
| Transacciones, seguridad y respaldo | Sayer | `sql/06_seguridad.sql`, `sql/08_transacciones.sql`, `docs/permisos.md`, `docs/evidencias/`, `respaldo/clinica.dump` |
