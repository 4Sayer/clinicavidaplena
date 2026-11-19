# Rendimiento: planes de ejecución antes y después de índices

Pruebas realizadas sobre PostgreSQL 18.7 con `50,000` filas en `clinica.cita`, `15,000` en `clinica.consulta`, `15,000` en `clinica.factura` y `155` en `clinica.lote_inventario`, ejecutando `ANALYZE` antes y después de aplicar `sql/03_vistas_indices.sql`.

## Resumen comparativo

| Consulta | Plan ANTES | Tiempo ANTES | Buffers ANTES | Plan DESPUÉS | Tiempo DESPUÉS | Buffers DESPUÉS |
| :--- | :--- | ---: | ---: | :--- | ---: | ---: |
| **Q1** (citas por sede y rango de fechas) | `Seq Scan` en `cita` (49,220 descartadas) | `6.087 ms` | `530` | `Bitmap Index Scan` en `idx_cita_sede_fecha` | `1.026 ms` | `44` |
| **Q4** (especialidades > 20 citas/mes último año) | `Seq Scan` en `cita` + `HashAggregate` | `31.849 ms` | `520` | `Seq Scan` en `cita` + `HashAggregate` | `22.895 ms` | `520` |
| **Q12** (lotes por vencer en 90 días) | `Seq Scan` en `lote_inventario` | `0.283 ms` | `7` | `Seq Scan` en `lote_inventario` | `0.146 ms` | `7` |
| **Q14** (ranking `DENSE_RANK` médicos atendidos) | `Seq Scan` en `cita` + `Hash Join` | `59.713 ms` | `532` | `Index Scan` en `idx_cita_medico_estado` | `23.793 ms` | `7,429` |
| **Q15** (última consulta por paciente) | `Hash Join` + `Sort` + `WindowAgg` | `31.592 ms` | `850` | `Hash Join` + `Sort` + `WindowAgg` | `17.534 ms` | `850` |

## Detalle de planes observados (`EXPLAIN (ANALYZE, BUFFERS)`)

### Q1 — Citas por sede en rango de 7 días
- **Antes:** `Seq Scan on cita c` con `Rows Removed by Filter: 49220` (`Execution Time: 6.087 ms`, `shared hit=530`).
- **Después:** `Bitmap Heap Scan on cita c` usando `Bitmap Index Scan on idx_cita_sede_fecha` (`Heap Blocks: exact=24`, `Execution Time: 1.026 ms`, `shared hit=41 read=3`). Reducción del **83%** en tiempo y **91%** en bloques leídos.

### Q4 — Especialidades con más de 20 citas por mes (último año)
- **Antes:** `Execution Time: 31.849 ms` (`shared hit=520`).
- **Después:** `Execution Time: 22.895 ms` (`shared hit=520`). Como el rango de 1 año cubre ~66% de la tabla (`33,080` de `50,000` filas), el optimizador elige correctamente `Seq Scan`.

### Q12 — Lotes próximos a vencer (90 días)
- **Antes:** `Execution Time: 0.283 ms` (`shared hit=7`).
- **Después:** `Execution Time: 0.146 ms` (`shared hit=7`). Con `155` filas en 2 páginas de disco, el planificador prefiere lectura secuencial; el índice parcial `idx_lote_vencimiento` (`WHERE stock > 0`) escalará cuando el inventario crezca a miles de lotes.

### Q14 — Ranking de médicos por citas atendidas
- **Antes:** `Seq Scan on cita c` (`Filter: estado = 'atendida'`, `14,796` descartadas) + `Hash Join` (`Execution Time: 59.713 ms`).
- **Después:** `Nested Loop` con `Index Scan using idx_cita_medico_estado on cita c` (`Execution Time: 23.793 ms`). Reducción del **60%** en tiempo de ejecución.

### Q15 — Última consulta de cada paciente
- **Antes:** `Hash Join` (`cita` + `consulta`) -> `Sort (c.id_paciente, co.fecha_consulta DESC)` -> `WindowAgg (Run Condition: row_number() <= 1)` (`Execution Time: 31.592 ms`).
- **Después:** Mismo plan optimizado en memoria (`Execution Time: 17.534 ms`), beneficiado por la memoria caché caliente y estadísticas actualizadas con `ANALYZE`.
