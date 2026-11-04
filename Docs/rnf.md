# Requisitos No Funcionales (RNF) - GestiónPyme

## 1. Introducción

El presente documento establece los requisitos no funcionales del sistema GestiónPyme, una solución de facturación e inventario dirigida a pequeñas empresas.

El objetivo es definir las condiciones de rendimiento, disponibilidad, seguridad, recuperación, escalabilidad y mantenimiento que debe cumplir el sistema para garantizar su correcto funcionamiento.

Estos requisitos servirán como referencia para diseñar la arquitectura, seleccionar la infraestructura, realizar pruebas de carga y evaluar los costos de operación.

## 2. Requisitos de disponibilidad

El sistema debe permanecer disponible durante la operación diaria de la empresa, permitiendo que los usuarios puedan gestionar productos, registrar ventas, emitir facturas y consultar información.

Se establecen los siguientes criterios:

- La aplicación debe contar con mecanismos para detectar fallos en las instancias de la API.
- Nginx debe distribuir las solicitudes entre dos instancias de la API.
- Si una instancia presenta problemas, el sistema debe poder continuar atendiendo solicitudes mediante la instancia disponible.
- La base de datos debe contar con almacenamiento persistente para evitar la pérdida de información ante el reinicio de los contenedores.

**Objetivo inicial:**

Se propone una disponibilidad mensual del 99 %, como meta preliminar que deberá evaluarse durante las pruebas y el desarrollo del proyecto.

## 3. Requisitos de rendimiento

GestiónPyme debe responder adecuadamente a las operaciones habituales de los usuarios, especialmente aquellas relacionadas con la facturación y el inventario.

Se consideran operaciones críticas:

- Consultar productos.
- Registrar ventas.
- Emitir facturas.
- Actualizar inventario.
- Consultar información de ventas.

La generación del reporte mensual puede requerir mayor procesamiento, por lo que no debe afectar de manera significativa el rendimiento de las operaciones diarias.

**Objetivos iniciales:**

- Mantener un tiempo de respuesta inferior a 500 milisegundos para el 95 % de las solicitudes habituales, bajo la carga de referencia definida para las pruebas.
- Permitir que las operaciones de facturación e inventario continúen funcionando mientras se genera el reporte mensual.
- Procesar los reportes pesados de manera independiente mediante trabajos en segundo plano.
- Utilizar Redis para apoyar el almacenamiento temporal de resultados y la gestión de trabajos.

Estos valores son objetivos iniciales y deberán validarse mediante pruebas de carga.

## 4. Requisitos de escalabilidad

El sistema debe permitir atender el crecimiento de las operaciones de la empresa sin necesidad de modificar completamente su arquitectura.

Para esto se establecen los siguientes criterios:

- La API debe poder ejecutarse en dos instancias detrás de Nginx.
- Nginx debe distribuir las solicitudes y realizar comprobaciones de salud de las instancias.
- Los componentes deben poder ejecutarse mediante contenedores.
- La arquitectura debe permitir aumentar los recursos asignados cuando la demanda lo requiera.
- La generación de reportes debe mantenerse separada de las solicitudes normales de los usuarios.

La solución utilizará inicialmente una arquitectura de monolito modular, evitando la complejidad adicional de implementar microservicios que no se justifican por las necesidades actuales del negocio.

## 5. Requisitos de seguridad

El sistema debe proteger la información del negocio y evitar modificaciones no autorizadas.

Se establecen los siguientes criterios:

- La comunicación entre los usuarios y la aplicación debe utilizar HTTPS cuando se encuentre desplegada en un entorno de producción.
- Las credenciales y configuraciones sensibles no deben almacenarse directamente en el código fuente.
- El acceso a las funcionalidades debe respetar los roles y permisos de los usuarios.
- La base de datos no debe exponerse directamente al acceso público.
- Los servicios internos deben comunicarse mediante una red controlada.
- Las operaciones importantes, especialmente la anulación de facturas, deben conservar un registro de auditoría.
- La información almacenada debe contar con mecanismos de protección y respaldo.

## 6. Requisitos de recuperación e integridad de datos

La información de facturación es crítica para el negocio. Por esta razón, el sistema debe garantizar que las facturas confirmadas no se pierdan ante una falla.

Se establecen los siguientes criterios:

- PostgreSQL debe utilizar almacenamiento persistente.
- La información de las facturas debe permanecer disponible después de reiniciar los contenedores.
- Se deben implementar copias de seguridad de la base de datos.
- Debe existir un procedimiento documentado para restaurar los respaldos.
- La restauración debe probarse y verificarse periódicamente.
- Las facturas anuladas deben conservar su registro de auditoría.
- La recuperación debe garantizar la integridad de la información almacenada.

### Objetivo de pérdida máxima de datos

Para las facturas confirmadas, la pérdida máxima aceptable es de cero facturas.

**RPO objetivo: 0 para las facturas confirmadas.**

Esto significa que una factura confirmada correctamente no debe desaparecer ante una falla.

El cumplimiento de este objetivo deberá demostrarse mediante pruebas de persistencia, recuperación y verificación de los registros.

Se debe tener en cuenta que disponer de copias de seguridad no garantiza por sí solo un RPO de cero. Será necesario implementar y comprobar un mecanismo que proteja las transacciones confirmadas.

## 7. Requisitos de observabilidad y monitoreo

El sistema debe permitir conocer su estado de funcionamiento y detectar problemas antes de que afecten gravemente la operación.

Se establecen los siguientes criterios:

- La API debe disponer de endpoints de salud y disponibilidad.
- Se deben recopilar métricas sobre el funcionamiento de la aplicación.
- Prometheus se utilizará para recolectar métricas.
- Grafana permitirá visualizar el comportamiento de los componentes.
- Se deben monitorear el uso de CPU y memoria.
- Se debe observar el comportamiento de las instancias de la API.
- Se deben identificar errores y tiempos de respuesta.
- Se deben generar alertas cuando se presenten problemas importantes de disponibilidad o rendimiento.

La observabilidad permitirá obtener evidencia del comportamiento del sistema durante las pruebas de carga.

## 8. Requisitos de costos y mantenimiento

La solución está dirigida a una pequeña empresa con presupuesto muy limitado y sin personal especializado en sistemas.

Por esta razón, la arquitectura debe evitar costos innecesarios y facilitar las actividades de mantenimiento.

Se establecen los siguientes criterios:

- La infraestructura debe utilizar recursos acordes con la demanda estimada.
- Se debe evitar incorporar servicios independientes que aumenten innecesariamente los costos.
- La arquitectura debe ser sencilla de desplegar y mantener.
- Se debe calcular el costo mensual estimado de infraestructura.
- Se deben evaluar diferentes escenarios de carga para identificar cómo varían los costos.
- El sistema debe poder iniciarse mediante un procedimiento automatizado.
- Los cambios del proyecto deben poder integrarse y desplegarse mediante un proceso de CI/CD.

## 9. Requisitos de pruebas y validación

Los requisitos no funcionales deben comprobarse mediante pruebas y evidencias.

Se establecen las siguientes actividades:

- Realizar pruebas de carga para medir la capacidad de atención del sistema.
- Medir los tiempos de respuesta de las operaciones habituales.
- Evaluar el comportamiento de la facturación mientras se genera el reporte mensual.
- Comprobar la distribución de solicitudes entre las dos instancias de la API.
- Simular fallos de componentes y verificar la recuperación.
- Realizar respaldos y comprobar que pueden restaurarse correctamente.
- Verificar que las facturas confirmadas permanezcan disponibles después de las pruebas de recuperación.
- Registrar las métricas obtenidas para respaldar las decisiones arquitectónicas.

## 10. Supuestos y valores pendientes de validación

Algunos valores de rendimiento, disponibilidad y capacidad todavía no cuentan con mediciones reales.

Por esta razón, se identifican como objetivos iniciales o supuestos que deberán verificarse durante el desarrollo.

| Elemento | Valor inicial | Tipo |
|---|---|---|
| Integrantes del equipo | 3 | Dato del proyecto |
| Disponibilidad mensual | 99 % | Supuesto |
| Tiempo de respuesta habitual (p95) | Menor a 500 ms | Supuesto |
| Pérdida máxima de facturas confirmadas | 0 facturas | Requisito del negocio |
| Instancias de API | 2 | Requisito arquitectónico |
| Base de datos | PostgreSQL | Requisito arquitectónico |
| Caché y trabajos | Redis | Requisito arquitectónico |
| Métricas | Prometheus | Requisito arquitectónico |
| Visualización y monitoreo | Grafana | Requisito arquitectónico |

Los valores de rendimiento y disponibilidad deberán revisarse después de realizar las primeras pruebas de carga y evaluar la infraestructura seleccionada.

## 11. Conclusión

Los requisitos no funcionales de GestiónPyme buscan garantizar que el sistema sea confiable, seguro, mantenible y adecuado para las necesidades de una pequeña empresa.

La arquitectura deberá priorizar la disponibilidad de la facturación, la integridad de las facturas, el aislamiento de los reportes pesados y el control de los costos de infraestructura.

Estos requisitos servirán como base para las decisiones arquitectónicas y para las actividades de estimación, implementación y validación del proyecto.