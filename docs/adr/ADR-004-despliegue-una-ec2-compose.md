# ADR-004 · Desplegar todo en una EC2 con Docker Compose en vez de servicios gestionados

- **Estado:** aceptado
- **Fecha:** 25-nov-2026
- **Responsables:** Grupo 6

## Contexto

Hay que publicar GestiónPyme en AWS cumpliendo el costo (RNF-09), el aislamiento de la API y la base (RNF-05) y un despliegue que el equipo de 3 personas pueda repetir sin ayuda. La cotización compara dos opciones:

| Opción | Qué incluye | Costo mensual estimado |
|---|---|---|
| **A · Todo en una instancia** | EC2 + EBS + IP pública + S3 para respaldos | **21,04 USD** |
| **B · Servicios gestionados** | RDS Multi-AZ + ElastiCache + Fargate + ALB + IPs | **115,86 USD** |

## Decisión

**Opción A.** Una instancia EC2 (Ubuntu 24.04) en la **subred pública** de una VPC propia, con Docker Compose levantando `proxy` (Nginx), `api` y `db` (y más adelante `redis` y `worker`). Solo Nginx publica un puerto. La API y la base viven en redes Docker internas y el grupo de seguridad solo abre el 80 a todos y el 22 a la IP del administrador.

## Alternativas descartadas

| Alternativa | Por qué se descarta |
|---|---|
| **Opción B · Servicios gestionados** (RDS, ElastiCache, Fargate, ALB) | Mejor disponibilidad y menos administración, pero cuesta 115,86 USD/mes: unas 5,5 veces la Opción A y más de 4 veces el límite del RNF-09. |
| **Contenedores en la subred privada con NAT Gateway** | Aísla todavía más la API y la base, pero el NAT Gateway cobra por hora (alrededor de 32 USD/mes) y además necesitaría un balanceador para entrar: rompe el RNF-09. Se logra un aislamiento equivalente con el grupo de seguridad y las redes internas de Docker (RNF-05 verificado). |

## Criterio

- **RNF-09:** 21,04 USD/mes ≤ 25 USD.
- **RNF-05:** dos barreras (grupo de seguridad + puertos no publicados), verificadas desde internet el 23-nov-2026.
- **Despliegue repetible:** el mismo `docker-compose.yml` corre igual en el computador del equipo y en la EC2.

## Consecuencias aceptadas

- **Un solo punto de falla:** si la instancia cae, cae todo. Se mitiga con el respaldo del [ADR-003](ADR-003-respaldo-wal-s3.md), que da un RTO ≤ 1 h.
- El equipo administra el servidor: parches de Ubuntu, Docker y espacio en disco.
- La subred privada queda creada pero vacía, reservada para mover la base allí si el presupuesto lo permite.

## Reversión

Se pasa a la Opción B, o a una intermedia con RDS, si la disponibilidad medida queda por debajo del 99 % (RNF-03), si se exige RPO = 0 ante la pérdida del servidor, o si el presupuesto mensual supera los 100 USD.
