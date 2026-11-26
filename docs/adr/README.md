# Registro de decisiones de arquitectura (ADR) · GestiónPyme

Cada ADR responde: **contexto, decisión, alternativas (mínimo dos, con su razón), criterio (el RNF que decide), consecuencias y reversión**.

| ADR | Decisión | Estado | RNF que la decide |
|---|---|---|---|
| [ADR-0001](0001-monolito-modular.md) | Monolito modular en vez de microservicios | Aceptado | RNF-09, RNF-06 |
| [ADR-0002](0002-reporte-en-worker.md) | El reporte mensual en un worker con cola en Redis | Aceptado (pendiente de implementar) | RNF-02, RNF-09 |
| [ADR-0003](0003-respaldo-wal-s3.md) | Respaldo base diario + WAL continuo en S3 | Aceptado (pendiente de implementar) | RNF-07, RNF-09 |
| [ADR-0004](0004-despliegue-una-ec2-compose.md) | Todo en una EC2 con Docker Compose (Opción A) | Aceptado | RNF-09, RNF-05 |

Los requisitos están en [../rnf.md](../rnf.md).

## Próximas decisiones (para llegar a las 8 del expediente final)

El curso exige **mínimo ocho ADR** al final del semestre. Estas son las decisiones que vienen con los siguientes hitos:

| ADR | Pregunta a decidir | Hito |
|---|---|---|
| ADR-0005 | ¿Qué consulta se guarda en caché de Redis, con qué tiempo de expiración y cómo se invalida al facturar? | 2 |
| ADR-0006 | ¿Cómo se maneja la autenticación por rol (administrador, vendedor, contador)? | 2 |
| ADR-0007 | ¿Cómo se termina TLS (HTTPS) en Nginx y con qué certificado? | 2 |
| ADR-0008 | ¿Con qué herramienta de infraestructura como código se recrea el entorno? | 3 |
| ADR-0009 | ¿Qué verifica el pipeline de CI (estilo, pruebas, construcción y escaneo de la imagen)? | 3 |

## Cómo agregar un ADR nuevo

1. Copiar uno existente y numerarlo en orden: `0005-titulo-corto.md`.
2. Llenar las seis partes. Una decisión sin alternativas descartadas no es un ADR.
3. Agregarlo a esta tabla.
4. Si una decisión cambia, **no se borra**: se marca como `Reemplazado por ADR-00X` y se escribe uno nuevo.
