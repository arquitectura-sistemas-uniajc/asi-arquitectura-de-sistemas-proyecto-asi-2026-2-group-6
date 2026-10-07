## 1. ¿Qué duele hoy? (Contexto y Problema)

GestiónPyme está dirigido a una pequeña empresa que necesita realizar y
controlar operaciones fundamentales del negocio: facturación, inventario y
reportes contables.

El principal problema es que estas operaciones son críticas para el
funcionamiento diario de la empresa, pero la organización cuenta con un
presupuesto muy limitado y no dispone de personal especializado en sistemas.

Esto genera los siguientes problemas:

- La facturación debe estar disponible durante la operación diaria del negocio.
- Las ventas realizadas deben quedar registradas correctamente para evitar
  pérdidas de información.
- El inventario debe mantenerse actualizado después de las operaciones de
  venta.
- El contador necesita disponer de la información necesaria para generar el
  reporte mensual.
- Un reporte mensual pesado no puede afectar ni ralentizar las operaciones
  normales de facturación.
- La empresa necesita una solución sencilla de mantener, debido a que no
  cuenta con personal de sistemas.
- La pérdida de una factura representa un problema importante para el negocio,
  por lo que la información de facturación debe ser persistente y recuperable.

El problema arquitectónico principal no es tener muchas funcionalidades, sino
garantizar que las operaciones críticas del negocio continúen funcionando
mientras se realizan procesos más pesados, como la generación del reporte
mensual.


## 2. ¿Quién sufre ese dolor?

Los principales usuarios afectados por el problema son:

### Administrador

Es responsable de controlar la operación general de la empresa y necesita
disponer de información confiable sobre los productos, las ventas y el
inventario.

Un problema en el sistema puede dificultar el control de las operaciones
diarias y la consulta de información del negocio.

### Vendedores

Son los usuarios que realizan las operaciones de venta y emisión de facturas.

Para ellos, la disponibilidad del sistema es especialmente importante porque
una caída puede impedir registrar y emitir nuevas facturas durante la operación
comercial.

### Contador

Necesita la información generada por las operaciones del negocio para realizar
el control y los reportes contables.

Un problema con la disponibilidad o integridad de la información puede afectar
la generación del reporte mensual y la confiabilidad de los datos contables.

### Resumen de afectados

| Usuario | Principal necesidad | Impacto ante un problema |
|---|---|---|
| Administrador | Controlar productos, ventas e inventario | Pierde visibilidad sobre la operación |
| Vendedor | Registrar ventas y emitir facturas | No puede realizar normalmente las ventas |
| Contador | Consultar información y generar reportes | Se dificulta el trabajo contable |

Por lo tanto, aunque los tres perfiles utilizan el sistema de manera
diferente, todos dependen de que la información sea consistente y esté
disponible.


## 3. ¿Qué pasa si el sistema se cae una hora? (Disponibilidad)

Una caída de una hora afecta directamente la operación diaria de la empresa,
debido a que la facturación y el control del inventario son procesos
fundamentales del negocio.

Durante esa hora:

- Los vendedores podrían quedar imposibilitados para emitir nuevas facturas
  desde el sistema.
- Las ventas que se realicen durante la caída podrían quedar pendientes de
  registrar.
- El inventario podría quedar temporalmente desactualizado.
- El administrador perdería temporalmente la capacidad de consultar el estado
  de las operaciones.
- El contador no tendría acceso normal a la información generada durante ese
  periodo.
- Al restablecerse el sistema, las operaciones pendientes tendrían que
  recuperarse sin generar duplicados ni pérdida de información.

### El problema más grave: las facturas

La caída del sistema no debe provocar la pérdida de las facturas que ya fueron
registradas.

Por esta razón, el objetivo no debe ser únicamente volver a levantar el
sistema, sino garantizar que las operaciones confirmadas antes de la caída
permanezcan almacenadas y puedan recuperarse correctamente.

### Impacto de una hora de indisponibilidad

La pérdida económica exacta de una hora todavía no puede establecerse porque
el enunciado del proyecto no proporciona el número de ventas promedio por hora
ni el valor promedio de cada factura.

Por lo tanto, no se debe inventar un valor monetario. Para calcularlo
posteriormente se necesitarán datos como:

- Ventas promedio por hora.
- Valor promedio de una factura.
- Número promedio de facturas emitidas por hora.
- Horario de operación de la empresa.

Con esos datos podremos estimar cuánto dinero está potencialmente en riesgo
durante una hora de indisponibilidad.

### Pérdida máxima de datos

Para GestiónPyme, el objetivo es que una factura confirmada no se pierda.

Por lo tanto:

**Pérdida máxima aceptable de facturas: 0 facturas.**

La arquitectura deberá demostrar mediante mecanismos de persistencia,
respaldo y recuperación que una factura registrada no desaparece ante una
falla del sistema.