# ADR-002 · El reporte mensual se genera en un proceso aparte (worker con Redis)

- **Estado:** aceptado (implementación pendiente)
- **Fecha:** 25-nov-2026
- **Responsables:** Grupo 6

## Contexto

El reto del proyecto es *"facturar sin que el reporte del mes frene la caja"*. El reporte mensual recorre todas las facturas del mes, agrupa y suma. Si se calcula **dentro** de la petición HTTP de la API, ocupa la CPU y las conexiones a la base que necesitan los vendedores para facturar. En el cierre de mes las dos cosas pasan al mismo tiempo.

## Decisión

El reporte se genera **fuera de la API**, en un **worker**: un proceso del mismo código (mismo monolito, otro punto de entrada) que corre en su propio contenedor.

1. El Contador pide el reporte: la API solo deja un trabajo en una cola de **Redis** y responde de inmediato (`202 Accepted`) con un identificador.
2. El worker toma el trabajo, consulta PostgreSQL con una conexión propia y limitada, y guarda el resultado.
3. El Contador consulta el estado con el identificador y descarga el reporte cuando está listo.

## Alternativas descartadas

| Alternativa | Por qué se descarta |
|---|---|
| **Calcular el reporte dentro de la API** (síncrono) | Es lo más simple, pero compite con la facturación por CPU y conexiones justo en el pico. No cumple el RNF-02 y una petición larga puede cortarse por el `proxy_read_timeout` de 15 s de Nginx. |
| **Réplica de lectura de PostgreSQL** para el reporte | Aísla la base, pero no la CPU de la API. Exige una segunda base (en RDS, unos +14 a 28 USD/mes), lo que rompe el RNF-09. |
| **Reporte programado** (calcularlo de noche con un cron) | Evita el choque, pero el Contador no puede pedir el reporte cuando lo necesita y los datos del día quedan por fuera. Se puede agregar después sobre el mismo worker. |

## Criterio

- **RNF-02:** p95 de facturación < 500 ms con 20 usuarios **mientras** se genera el reporte.
- **RNF-09:** Redis y el worker corren como contenedores en la misma EC2, sin costo adicional de servicios gestionados.

## Consecuencias aceptadas

- Se agregan dos contenedores (`redis` y `worker`) al Compose, en las redes internas, sin puertos publicados.
- El reporte ya no es instantáneo: el Contador espera a que el trabajo termine.
- Si Redis se reinicia, se pueden perder trabajos en cola. No se pierden facturas, porque estas viven en PostgreSQL; basta con volver a pedir el reporte.

## Reversión

Si las pruebas muestran que el reporte en la API **no** afecta la facturación (p95 < 500 ms con reporte síncrono y 20 usuarios), se elimina el worker y se simplifica. Si el reporte sigue afectando la base aun desde el worker, se evalúa la réplica de lectura y se revisa el RNF-09.
