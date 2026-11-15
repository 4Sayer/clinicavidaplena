# Matriz de permisos por rol

Todos los roles se crean sin contraseña (`NOLOGIN`) y con acceso mínimo en el esquema `clinica` (principio de menor privilegio y cumplimiento de RN-19). Se revoca todo acceso a `PUBLIC`.

## Matriz de permisos sobre tablas y vistas

| Objeto | `rol_recepcion` | `rol_medico` | `rol_farmacia` | `rol_auditor` |
| :--- | :--- | :--- | :--- | :--- |
| `sede`, `empleado` | `SELECT` | `SELECT` | `SELECT` | `SELECT` |
| `aseguradora` | `SELECT` | `SELECT` | Sin acceso | `SELECT` |
| `persona`, `paciente` | `SELECT, INSERT, UPDATE` | `SELECT` | `SELECT` | `SELECT` |
| `medico`, `especialidad`, `medico_especialidad`, `horario_medico` | `SELECT` | `SELECT` | Sin acceso | `SELECT` (`medico`, `especialidad`) |
| `cita` | `SELECT, INSERT, UPDATE` | `SELECT` | Sin acceso | `SELECT` |
| `consulta` (notas clínicas) | **Denegado** (RN-19) | `SELECT, INSERT, UPDATE` | **Denegado** | **Denegado** |
| `consulta_diagnostico` | **Denegado** (RN-19) | `SELECT, INSERT, UPDATE` | **Denegado** | **Denegado** |
| `diagnostico_catalogo` | Sin acceso | `SELECT` | Sin acceso | Sin acceso |
| `receta` | Sin acceso | `SELECT, INSERT, UPDATE` | `SELECT, UPDATE` (estado y dispensa) | Sin acceso |
| `detalle_receta` | Sin acceso | `SELECT, INSERT, UPDATE` | `SELECT` | Sin acceso |
| `medicamento` | Sin acceso | `SELECT` | `SELECT` | Sin acceso |
| `lote_inventario`, `dispensacion_lote` | Sin acceso | Sin acceso | `SELECT, INSERT, UPDATE` | `SELECT` |
| `factura`, `detalle_factura`, `pago` | `SELECT, INSERT, UPDATE` | Sin acceso | Sin acceso | `SELECT` |
| `auditoria` | Sin acceso directo* | Sin acceso | Sin acceso | `SELECT` |
| `v_agenda_diaria` | `SELECT` | `SELECT` | Sin acceso | `SELECT` |
| `v_expediente_clinico` | **Denegado** (RN-19) | `SELECT` | **Denegado** | **Denegado** |
| `v_inventario_por_vencer` | Sin acceso | Sin acceso | `SELECT` | `SELECT` |
| `v_resumen_facturacion` | `SELECT` | Sin acceso | Sin acceso | `SELECT` |

*\*Nota sobre `auditoria`: los triggers `trg_auditar_cita` y `trg_auditar_factura` usan `SECURITY DEFINER`, por lo que registran cambios en `auditoria` automáticamente sin dar permisos directos de escritura a ningún rol.*

## Permisos sobre funciones y procedimientos

| Rutina | `rol_recepcion` | `rol_medico` | `rol_farmacia` | `rol_auditor` |
| :--- | :--- | :--- | :--- | :--- |
| `fn_disponibilidad_medico` | `EXECUTE` | `EXECUTE` | — | — |
| `sp_reservar_cita` | `EXECUTE` | — | — | — |
| `sp_cambiar_estado_cita` | `EXECUTE` | — | — | — |
| `sp_generar_factura` | `EXECUTE` (`SECURITY DEFINER`) | — | — | — |
| `sp_registrar_pago` | `EXECUTE` | — | — | — |
| `sp_dispensar_receta` | — | — | `EXECUTE` | — |

## Cumplimiento de RN-19

- `rol_recepcion` no tiene `SELECT`, `INSERT` ni `UPDATE` sobre `consulta`, `consulta_diagnostico` ni `v_expediente_clinico`. Para facturar usa `sp_generar_factura`, que opera como `SECURITY DEFINER` leyendo únicamente la tarifa y medicamentos dispensados sin exponer notas clínicas ni diagnósticos.
- `rol_medico` es el único rol con escritura en `consulta`, `consulta_diagnostico`, `receta` y `detalle_receta`.
- Las pruebas de acceso permitido y denegado por cada rol mediante `SET ROLE` están en `sql/08_transacciones.sql` y su captura en `docs/evidencias/04_permisos_roles.png`.
