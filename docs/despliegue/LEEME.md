# Capturas del despliegue en AWS

Las capturas que enlaza [../despliegue.md](../despliegue.md). En todas las pruebas debe verse la IP pública.

| Archivo | Qué muestra |
|---|---|
| `resource-map.png` | VPC → pestaña **Mapa de recursos** |
| `compose-ps.png` | `docker compose ps` dentro de la EC2 (solo el proxy con `0.0.0.0:80->80/tcp`) |
| `prueba-health.png` | `curl -i http://IP/api/health` → `200 OK` |
| `prueba-3000.png` | `curl -m 5 http://IP:3000/api/health` → timeout |
| `prueba-5432.png` | `Test-NetConnection IP -Port 5432` → `TcpTestSucceeded : False` |
| `stopped.png` | La instancia en estado **Detenida** (no terminada) |
