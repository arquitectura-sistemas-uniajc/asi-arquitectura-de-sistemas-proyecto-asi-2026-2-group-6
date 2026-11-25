# ASI-2026-Repo - GestionPyme
# Jason Steven Caicedo Correa
# Kevin Landazury Guerrero
# yeiler alvarez rodriguez

**Facturación e inventario para una pyme.** *Facturar sin que el reporte del mes frene la caja.*

## Configuración de AWS
- **Región de trabajo:** us-east-1 (N. Virginia) para la estimación de costos; el despliegue se hizo en **us-east-2 (Ohio)**, la región habilitada en la cuenta del curso.
- **Política de etiquetado obligatoria:**
  - `Proyecto`: ASI-G06-GestionPyme
  - `Owner`: Usuario o nombre del integrante que crea el recurso

## Documentación

| Documento | Contenido |
|---|---|
| [docs/contexto.md](docs/contexto.md) | Retos arquitectónicos del proyecto |
| [docs/rnf.md](docs/rnf.md) | 8 requisitos no funcionales medibles |
| [docs/arquitectura/](docs/arquitectura/README.md) | Modelo C4 (niveles 1, 2 y 3) |
| [docs/arquitectura/red.md](docs/arquitectura/red.md) | Plan de red: VPC, subredes, rutas y reglas |
| [docs/adr/](docs/adr/README.md) | Decisiones de arquitectura (ADR-001 a ADR-004) |
| [docs/despliegue.md](docs/despliegue.md) | Evidencia del despliegue en local y en AWS |
| [docs/estimacion/](docs/estimacion/cotizacion-aws-gestionpyme.pdf) | Cotización de AWS |
| [MANUAL.md](MANUAL.md) | Manual de ejecución local y despliegue (del curso) |

## Ejecutar en local

```bash
cp .env.example .env      # cambiar DB_PASSWORD
docker compose up -d --build
```

Abrir `http://localhost:8080`.
