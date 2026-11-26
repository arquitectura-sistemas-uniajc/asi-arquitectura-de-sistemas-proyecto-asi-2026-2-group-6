# ADR-0001 · Monolito modular en vez de microservicios

- **Estado:** aceptado
- **Fecha:** 25-nov-2026
- **Responsables:** Grupo 6 (Jason Caicedo, Kevin Landazury, Yeiler Álvarez)

## Contexto

GestiónPyme es la facturación e inventario de **una** pyme sin personal de sistemas y con presupuesto muy limitado (RNF-09: ≤ 25 USD/mes). El equipo tiene **3 personas** y un solo dominio de negocio: productos, inventario, facturación, auditoría y reportes, que comparten los mismos datos (una factura descuenta inventario en la misma transacción).

## Decisión

Una sola API (Node.js + Express) organizada en **módulos internos separados**: Productos e inventario, Facturación, Auditoría y Reportes. Se despliega como un único contenedor, con la opción de correr 2 réplicas detrás de Nginx.

## Alternativas descartadas

| Alternativa | Por qué se descarta |
|---|---|
| **Microservicios** (un servicio por módulo, unos 5 despliegues) | 5 imágenes, 5 despliegues y una red interna entre ellos para 3 personas. La factura y el descuento de inventario quedarían en servicios distintos y necesitarían transacciones distribuidas. En AWS gestionado se acerca a la Opción B de la cotización (115,86 USD/mes) y rompe el RNF-09. |
| **Serverless** (AWS Lambda por endpoint) | Arranque en frío justo en el pico de facturación (RNF-01 y RNF-02) y la conexión a PostgreSQL necesitaría un proxy adicional. Además, el reporte mensual puede superar el tiempo máximo de ejecución de una función. |

## En números

El enunciado del proyecto pide defender esta decisión *"con números de costo y tamaño de equipo"*:

| Concepto | Monolito modular | Microservicios (5 servicios) |
|---|---|---|
| Imágenes, pipelines y despliegues que mantener | 1 API (+ el worker, con el mismo código) | 5 |
| Servicios por integrante (equipo de 3) | 1 compartido por todos | ~1,7 por persona, cada uno con su propio despliegue |
| Bases de datos | 1 PostgreSQL, con transacciones locales | 1 por servicio o una compartida (que anula la independencia) |
| Emitir una factura | 1 transacción `BEGIN … COMMIT` | Varias llamadas por red entre Facturación e Inventario, con reintentos y compensaciones |
| Costo mensual en AWS (cotización) | **21,04 USD** (Opción A) | **115,86 USD** (Opción B: Fargate, ALB, RDS, ElastiCache) |
| ¿Cumple el techo de 25 USD (RNF-09)? | ✅ Sí | ❌ No: 4,6 veces el techo |

## Criterio

- **RNF-09 (costo ≤ 25 USD/mes):** un solo contenedor de API cabe en una EC2 pequeña.
- **RNF-06 (0 facturas perdidas):** facturar y descontar inventario ocurre en **una** transacción de PostgreSQL, sin coordinación entre servicios.
- **Tamaño del equipo:** 3 personas pueden operar un despliegue, no cinco.

## Consecuencias aceptadas

- Un despliegue lo saca todo: un error en el módulo de Reportes obliga a redesplegar también la Facturación.
- Todos los módulos escalan juntos, aunque solo uno necesite más recursos.
- Hay que cuidar los límites entre módulos dentro del código para que no se mezclen (cada módulo con su propia carpeta y sin acceder directo a las tablas de otro).

## Reversión

Se reconsidera si **un módulo necesita escalar aparte**, por ejemplo si el p95 de facturación supera 500 ms de forma sostenida con más de 200 usuarios concurrentes aun con 2 réplicas, o si otro equipo pasa a ser dueño de un módulo. En ese caso se extrae primero ese módulo, no todos.
