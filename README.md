# GestiónPyme

**Sistema de facturación e inventario para una pyme** con presupuesto limitado y sin personal de sistemas. Su reto es facturar sin que el reporte del mes frene la caja, sin perder ninguna factura y con un costo de nube de máximo 25 USD al mes.

Proyecto del curso **Arquitectura de Sistemas Computacionales** · UNIAJC · 2026-2 · Grupo 6.

## Integrantes

| Nombre | Usuario de GitHub |
|---|---|
| Jason Steven Caicedo Correa | [@Jason-Caicedo](https://github.com/Jason-Caicedo) |
| Kevin Landazury Guerrero | [@KevinLandazury](https://github.com/KevinLandazury) |
| Yeiler Álvarez Rodríguez | [@yeirodri](https://github.com/yeirodri) |

## Documentación

| Documento | Contenido |
|---|---|
| [docs/rnf.md](docs/rnf.md) | Requisitos no funcionales medibles (atributo, métrica, umbral, carga y verificación) |
| [docs/contexto.md](docs/contexto.md) | Los retos arquitectónicos del proyecto |
| [docs/arquitectura/](docs/arquitectura/README.md) | Todos los diagramas, en draw.io |
| [docs/adr/](docs/adr/README.md) | Decisiones de arquitectura |
| [docs/despliegue.md](docs/despliegue.md) | Evidencia del despliegue en AWS |
| [docs/estimacion/](docs/estimacion/cotizacion-aws-gestionpyme.pdf) | Cotización de AWS |
| [MANUAL.md](MANUAL.md) | Manual de ejecución local y despliegue (del curso) |

### Diagramas (draw.io: `.drawio` + `.png`)

| Diagrama | Fuente | Imagen |
|---|---|---|
| C4 nivel 1 · Contexto | [c1-contexto.drawio](docs/arquitectura/c1-contexto.drawio) | [c1-contexto.png](docs/arquitectura/c1-contexto.png) |
| C4 nivel 2 · Contenedores | [c2-contenedores.drawio](docs/arquitectura/c2-contenedores.drawio) | [c2-contenedores.png](docs/arquitectura/c2-contenedores.png) |
| C4 nivel 3 · Componentes de la API | [c3-componentes.drawio](docs/arquitectura/c3-componentes.drawio) | [c3-componentes.png](docs/arquitectura/c3-componentes.png) |
| Arquitectura de despliegue | [despliegue.drawio](docs/arquitectura/despliegue.drawio) | [despliegue.png](docs/arquitectura/despliegue.png) |
| Plan de red | [red.drawio](docs/arquitectura/red.drawio) | [red.png](docs/arquitectura/red.png) · [red.md](docs/arquitectura/red.md) |

### Decisiones de arquitectura (ADR)

| ADR | Decisión |
|---|---|
| [0001](docs/adr/0001-monolito-modular.md) | Monolito modular en vez de microservicios (reto del proyecto) |
| [0002](docs/adr/0002-reporte-en-worker.md) | El reporte mensual en un worker con cola en Redis (reto del proyecto) |
| [0003](docs/adr/0003-respaldo-wal-s3.md) | Respaldo diario + WAL continuo en S3 (reto del proyecto) |
| [0004](docs/adr/0004-despliegue-una-ec2-compose.md) | Todo en una EC2 con Docker Compose |

## Configuración de AWS

- **Región:** us-east-2 (Ohio), la habilitada en la cuenta del curso. La estimación de costos se hizo con precios de us-east-1.
- **Etiquetas obligatorias:** `Proyecto = ASI-G06-GestionPyme` y `Owner = <integrante que crea el recurso>`.
- **Estado:** la instancia queda **detenida** entre clases. Ver [docs/despliegue.md](docs/despliegue.md).

## Ejecutar en local

```bash
cp .env.example .env      # y cambiar DB_PASSWORD
docker compose up -d --build
```

Abrir `http://localhost:8080`.
