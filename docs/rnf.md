# Requisitos No Funcionales (RNF) · GestiónPyme

**Grupo 6 · Arquitectura de Sistemas · UNIAJC · 2026-2**
**Sistema:** facturación e inventario para una pyme con presupuesto muy limitado y sin personal de sistemas. *"Facturar sin que el reporte del mes frene la caja."*

Cada RNF tiene **atributo, métrica, umbral, condición de carga y forma de verificarlo**. Se cubren los 7 atributos que exige el curso: disponibilidad, rendimiento, escalabilidad, seguridad, recuperación, observabilidad y costo.

## Carga de referencia

| Dato | Valor | Origen |
|---|---|---|
| Usuarios del sistema | Administrador, vendedores, contador | Enunciado del proyecto |
| Usuarios concurrentes en hora pico | **20** (vendedores facturando al mismo tiempo) | Supuesto del equipo para una pyme |
| Horario de operación | 7:00 a 21:00, todos los días (420 h al mes) | Supuesto del equipo |
| Momento más exigente | Cierre de mes: el contador genera el reporte mensual mientras los vendedores siguen facturando | Reto del proyecto |

## Resumen de los 9 RNF

| ID | Atributo | Métrica | Umbral | Condición de carga | Cómo se verifica |
|---|---|---|---|---|---|
| RNF-01 | Rendimiento | Latencia p95 de `GET /api/items` | **< 300 ms** | 20 usuarios concurrentes durante 5 min | Prueba de carga con **k6** |
| RNF-02 | Rendimiento bajo reporte | Latencia p95 de `POST /api/registros` (facturar) y tasa de error | **< 500 ms** y **< 1 % de errores** | 20 usuarios facturando **mientras** se genera el reporte mensual | k6 sobre facturación con el reporte lanzado en paralelo |
| RNF-03 | Disponibilidad | Tiempo en servicio y minutos de caída | **≥ 99 % mensual** = máximo **252 min** de caída al mes | Horario de operación (420 h/mes) | Consulta a `/api/health` cada minuto |
| RNF-04 | Escalabilidad | Factor de crecimiento soportado | **×2** (de 20 a 40 usuarios) con p95 < 500 ms | 40 usuarios concurrentes facturando | k6 con 1 réplica y con 2 réplicas de la API detrás de Nginx |
| RNF-05 | Seguridad | Puertos internos expuestos, secretos en el repositorio, vulnerabilidades críticas en la imagen | **0 / 0 / 0** | Siempre, en local y en AWS | `curl` desde internet, revisión del repositorio y escaneo de la imagen con Trivy |
| RNF-06 | Recuperación · durabilidad | Facturas confirmadas perdidas | **0 facturas** | Caída o reinicio de los contenedores `api` y `db` | Contar facturas antes y después de matar los contenedores |
| RNF-07 | Recuperación · desastre | RTO / RPO | **RTO ≤ 1 h · RPO ≤ 5 min** | Pérdida total del servidor EC2 | Restaurar el respaldo en una instancia nueva y cronometrar |
| RNF-08 | Observabilidad | Tiempo para detectar un incidente | **≤ 2 min** desde la caída hasta la alerta | Se detiene la API a propósito | Prometheus + Grafana: cronometrar desde `docker compose stop api` hasta que llega la alerta |
| RNF-09 | Costo | Techo de gasto mensual en AWS | **≤ 25 USD/mes** | Operación normal del semestre | AWS Pricing Calculator y factura real (Billing) |

## Estado de verificación

| ID | Estado | Evidencia o momento |
|---|---|---|
| RNF-01 | Pendiente | Hito 3: prueba de carga |
| RNF-02 | Pendiente | Requiere el worker de reportes ([ADR-0002](adr/0002-reporte-en-worker.md)) |
| RNF-03 | Pendiente | Monitor de `/api/health` (hito 3) |
| RNF-04 | Pendiente | Requiere 2 réplicas de la API detrás de Nginx |
| RNF-05 | **Parcial** | ✅ 0 puertos internos expuestos (verificado el 23-nov, [despliegue.md](despliegue.md)) · ✅ `.env` fuera del repositorio · ✅ API sin usuario root · ⏳ escaneo de imagen, autenticación y TLS |
| RNF-06 | Pendiente | Prueba de fallo inyectado (hito 2) |
| RNF-07 | Pendiente | Prueba de respaldo y restauración ([ADR-0003](adr/0003-respaldo-wal-s3.md)) |
| RNF-08 | Pendiente | Hito 3: observabilidad |
| RNF-09 | Estimado: **21,04 USD/mes** | [Cotización AWS, Opción A](estimacion/cotizacion-aws-gestionpyme.pdf) |

---

## Detalle de cada RNF

### RNF-01 · Rendimiento de lectura

- **Escenario:** 20 vendedores consultan el catálogo de productos al mismo tiempo.
- **Umbral:** el 95 % de las respuestas de `GET /api/items` tarda menos de 300 ms.
- **Verificación:** script de k6 con 20 usuarios virtuales durante 5 minutos contra la IP pública de la EC2. Se guarda el resultado `http_req_duration p(95)`.

### RNF-02 · Rendimiento de la facturación mientras se genera el reporte

- **Escenario:** cierre de mes. El contador lanza el reporte mensual y, al mismo tiempo, 20 vendedores facturan.
- **Umbral:** p95 de `POST /api/registros` < 500 ms y menos del 1 % de solicitudes con error.
- **Verificación:** la misma prueba de k6 **sin** reporte y **con** el reporte corriendo en paralelo. Con reporte, el p95 debe seguir dentro del umbral.
- **Es el reto central del proyecto.** Lo resuelve el [ADR-0002](adr/0002-reporte-en-worker.md).

### RNF-03 · Disponibilidad

- **Umbral:** ≥ 99 % en el horario de operación. Con 420 horas de operación al mes, el 1 % tolerado son **252 minutos** (4 h 12 min) de caída al mes.
- **Verificación:** un monitor consulta `/api/health` cada minuto y se calcula el porcentaje de respuestas `200`.

### RNF-04 · Escalabilidad

- **Umbral:** soportar el **doble** de la carga de referencia (40 usuarios concurrentes) con p95 de facturación < 500 ms.
- **Mecanismo:** escalado horizontal de la API, con **2 réplicas** detrás de Nginx (balanceo y verificación de salud). Es posible porque la API no guarda estado: todo vive en PostgreSQL y Redis.
- **Verificación:** k6 con 40 usuarios, primero con 1 réplica y luego con 2. Se compara el p95 y se identifica el punto de saturación.

### RNF-05 · Seguridad

**Datos sensibles identificados:**

| Dato | Por qué es sensible |
|---|---|
| Facturas (montos, fechas, productos) | Información contable y tributaria del negocio |
| Datos de clientes en la factura (nombre, documento) | Datos personales |
| Contraseña de la base (`DB_PASSWORD`) | Da acceso a toda la información |
| Llave SSH del servidor (`.pem`) | Da acceso al servidor |

**Controles y umbral:**

| Control | Umbral | Estado |
|---|---|---|
| La API (3000) y la base (5432) no son alcanzables desde internet: grupo de seguridad + puertos no publicados ([red.md](arquitectura/red.md)) | 0 puertos internos expuestos | ✅ Verificado el 23-nov-2026 |
| Secretos fuera del repositorio: `.env` y `*.pem` en `.gitignore`, solo se versiona `.env.example` | 0 secretos en el repositorio | ✅ Cumplido |
| Contenedor de la API sin usuario root (`USER app` en el Dockerfile) | 0 contenedores propios como root | ✅ Cumplido |
| Imagen escaneada con Trivy en el pipeline | 0 vulnerabilidades críticas | ⏳ Pendiente (hito 3) |
| Autenticación por rol (administrador, vendedor, contador) | 100 % de los endpoints de escritura protegidos | ⏳ Pendiente |
| Cifrado en tránsito (HTTPS en Nginx) | 0 páginas o API servidas por HTTP en producción | ⏳ Pendiente |

### RNF-06 · Recuperación: durabilidad de las facturas

- **Regla del negocio:** *el negocio no puede perder ninguna factura.*
- **Umbral:** 0 facturas confirmadas perdidas cuando caen o se reinician los contenedores.
- **Cómo se cumple:** la factura se guarda dentro de una transacción (`BEGIN … COMMIT`) en PostgreSQL. Cuando la API responde "guardada", el `COMMIT` ya se escribió en disco, en el volumen persistente `datos`, que no vive dentro del contenedor.
- **Verificación (fallo inyectado):**
  1. Registrar facturas y contar con `SELECT count(*) FROM registros;`.
  2. Ejecutar `docker compose kill db` y luego `docker compose up -d`.
  3. Volver a contar. El número debe ser igual.

### RNF-07 · Recuperación ante la pérdida total del servidor

- **Umbral:** RTO ≤ 1 hora (tiempo hasta volver a facturar) y RPO ≤ 5 minutos (máximo de facturas perdidas).
- **Cómo se cumple:** respaldo base diario y archivado continuo del WAL de PostgreSQL en S3 ([ADR-0003](adr/0003-respaldo-wal-s3.md)).
- **Verificación:** terminar la instancia, crear una nueva, restaurar desde S3, cronometrar y comparar las facturas antes y después.
- **Riesgo asumido:** ante la pérdida **total** del servidor se pueden perder hasta 5 minutos de facturas. Llegar a 0 en ese escenario exige una base replicada en otra máquina, y eso supera el techo de costo (RNF-09). Está justificado en el ADR-0003.

### RNF-08 · Observabilidad

- **Umbral:** un incidente (la API deja de responder) se detecta y genera una alerta en **2 minutos o menos**.
- **Cómo se cumple:** Prometheus consulta las métricas de la API cada 15 s y una regla de alerta se dispara si `/api/health` falla durante 1 minuto. Grafana muestra un tablero con al menos 4 paneles: solicitudes por segundo, p95 de latencia, tasa de error y CPU/memoria.
- **Verificación:** `docker compose stop api` y cronometrar hasta que aparece la alerta.

### RNF-09 · Costo

- **Umbral:** techo de **25 USD al mes** en operación normal.
- **Estimación actual:** 21,04 USD/mes con la Opción A (todo en una instancia). La Opción B (servicios gestionados) cuesta 115,86 USD/mes y queda descartada ([ADR-0004](adr/0004-despliegue-una-ec2-compose.md)).
- **Verificación:** AWS Pricing Calculator ([cotización](estimacion/cotizacion-aws-gestionpyme.pdf)) y la factura real en *Billing* durante el semestre.

---

## Supuestos pendientes de validar

| Supuesto | Valor | Se valida con |
|---|---|---|
| Usuarios concurrentes en hora pico | 20 | Prueba de carga (punto de saturación) |
| Horario de operación | 7:00 a 21:00 | Conversación con el negocio |
| Tamaño de la base en un año | < 5 GB | Medición después de cargar datos de prueba |
| Precio de la instancia en Ohio | Igual al estimado en `us-east-1` | Factura real en `us-east-2`, la región habilitada en la cuenta del curso |

Los umbrales se revisan después de las primeras pruebas de carga. Si un umbral cambia, se actualiza esta tabla y el ADR que dependa de él.
