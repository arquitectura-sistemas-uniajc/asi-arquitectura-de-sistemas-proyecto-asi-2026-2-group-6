# ADR-0003 · Respaldo de PostgreSQL con archivado continuo del WAL en S3

- **Estado:** aceptado (implementación pendiente para la semana "La nube a prueba")
- **Fecha:** 25-nov-2026
- **Responsables:** Grupo 6

## Contexto

*El negocio no puede perder ninguna factura.* Hoy la base vive en el volumen Docker `datos`, dentro del disco de **una sola** EC2. Eso protege ante el reinicio de contenedores (RNF-06), pero si se pierde la instancia o su disco, se pierden todas las facturas. Se necesita una copia **fuera** del servidor que permita recuperar dentro del RNF-07 (RTO ≤ 1 h, RPO ≤ 5 min) y sin romper el RNF-09 (≤ 25 USD/mes).

## Decisión

1. **Respaldo base diario** de PostgreSQL (`pg_basebackup`) subido a un bucket de **S3**.
2. **Archivado continuo del WAL** (el registro de cambios de PostgreSQL) a S3, con `archive_timeout = 300` (cada 5 minutos como máximo).
3. **Prueba de restauración** documentada y cronometrada: instancia nueva, restaurar base y WAL, y comparar el conteo de facturas.

## Alternativas descartadas

| Alternativa | Por qué se descarta |
|---|---|
| **Solo `pg_dump` diario a S3** | Es lo más simple, pero el RPO es de hasta 24 horas: se podría perder un día entero de facturas. No cumple el RNF-07. |
| **RDS PostgreSQL Multi-AZ** | Da RPO casi 0 y conmutación automática, pero cuesta unos 27,96 USD/mes solo la base (según la cotización): rompe el RNF-09. |
| **Réplica síncrona de PostgreSQL en una segunda EC2** (otra zona) | Da RPO = 0 incluso si se pierde el servidor principal, sin pagar RDS. Pero suma otra instancia, otro disco y otra IP, duplica la administración para 3 personas y lleva el total por encima de los 25 USD. Además, si la réplica cae, la escritura síncrona puede bloquear la facturación. |
| **Snapshots diarios del volumen EBS** | Recupera el disco completo, pero con RPO de 24 h, igual que el `pg_dump`. Sirve como capa extra, no como solución. |

## Criterio

- **RNF-07:** RPO ≤ 5 min y RTO ≤ 1 h ante la pérdida total del servidor.
- **RNF-09:** S3 para respaldos y WAL cuesta unos **0,17 USD/mes** en la cotización (5 GB).

## Consecuencias aceptadas

- **Ante la pérdida total del servidor se pueden perder hasta 5 minutos de facturas.** Es una diferencia frente a la regla "ninguna factura": se acepta porque llegar a 0 cuesta más que todo el presupuesto mensual.
- La instancia necesita permiso para escribir en S3, mediante un **rol de IAM**; nunca con llaves dentro del `.env` ni del código.
- Hay que probar la restauración de verdad: un respaldo que nunca se restauró no cuenta.

## Reversión

Si el negocio exige **RPO = 0 incluso ante la pérdida total del servidor**, o si el presupuesto sube a más de 50 USD/mes, se migra la base a **RDS Multi-AZ** y se actualiza el RNF-09.
