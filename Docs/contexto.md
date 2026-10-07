# Retos arquitectónicos de GestiónPyme

## 1. ¿Por qué NO microservicios?

Para GestiónPyme se propone utilizar una arquitectura de **monolito modular** en lugar de una arquitectura basada en microservicios.

La principal razón es que el proyecto está orientado a una pequeña empresa con un **presupuesto muy limitado**, una cantidad de funcionalidades definida y un equipo de desarrollo de **3 integrantes**. En este contexto, utilizar microservicios introduciría una complejidad técnica y operativa que no se encuentra justificada por las necesidades actuales del sistema.

Un monolito modular permite mantener una arquitectura sencilla de desarrollar, desplegar, monitorear y mantener, separando internamente las responsabilidades del sistema sin necesidad de convertir cada funcionalidad en un servicio independiente.

### Problemas que se evitan al no utilizar microservicios

- Mayor cantidad de componentes que administrar.
- Mayor complejidad en los despliegues.
- Comunicación entre diferentes servicios.
- Mayor dificultad para monitorear y diagnosticar fallos.
- Mayor complejidad para manejar errores de comunicación.
- Incremento potencial de los costos de infraestructura.
- Mayor carga de mantenimiento para un equipo pequeño.
- Necesidad de administrar diferentes servicios cuando el sistema no requiere actualmente ese nivel de distribución.

En cambio, el **monolito modular** permite organizar el sistema en módulos con responsabilidades claramente definidas, por ejemplo:

- Gestión de productos.
- Facturación.
- Inventario.
- Auditoría.
- Reportes.

Estos módulos pueden mantenerse separados a nivel lógico sin necesidad de desplegarlos como aplicaciones independientes.

### Costo y tamaño del equipo

El proyecto cuenta con **3 integrantes**, por lo que la complejidad operativa debe mantenerse acorde con la capacidad del equipo.

Además, el proyecto establece que la empresa tiene un **presupuesto muy limitado** y no dispone de una persona especializada en sistemas. Por esta razón, agregar múltiples servicios, infraestructura y mecanismos de comunicación entre ellos aumentaría los costos y la dificultad de mantenimiento.

No se establece en el enunciado un valor monetario concreto para comparar ambas arquitecturas, por lo que **no se debe inventar un costo exacto**. Estos valores deberán calcularse posteriormente a partir de la infraestructura seleccionada y los costos reales de operación.

### Conclusión

La decisión de no utilizar microservicios se basa en que **la complejidad adicional no se justifica para el tamaño del proyecto, el tamaño del equipo y las restricciones económicas de la empresa**.

Por lo tanto, GestiónPyme utilizará un **monolito modular**, buscando obtener una solución sencilla, mantenible y suficiente para cumplir los requisitos del negocio.

## 2. ¿Cómo aíslan el reporte pesado para que no bloquee la operación diaria?

Uno de los principales retos arquitectónicos de GestiónPyme es la generación del **reporte mensual**, debido a que esta operación puede requerir una cantidad considerable de procesamiento y consultas sobre la información almacenada.

El sistema debe permitir que el reporte mensual se genere sin afectar las operaciones críticas que se realizan diariamente, especialmente la **facturación y la actualización del inventario**.

El objetivo es evitar que una operación pesada consuma todos los recursos disponibles y provoque que los vendedores tengan problemas para registrar nuevas ventas o emitir facturas.

### Separación de la operación diaria

La arquitectura propuesta debe separar el procesamiento del reporte de las operaciones normales del sistema.

Para esto, la generación del reporte puede manejarse como un **trabajo independiente**, utilizando mecanismos como una cola de trabajos y Redis para evitar que el procesamiento pesado bloquee directamente las solicitudes normales de los usuarios.

El flujo sería aproximadamente:

    Usuario solicita reporte
            ↓
    Se registra la solicitud
            ↓
    Trabajo de generación del reporte
            ↓
    Procesamiento independiente
            ↓
    Reporte generado

Mientras este proceso se ejecuta, las operaciones normales pueden continuar:

    Vendedor
       ↓
    Facturación
       ↓
    Actualización de inventario

De esta manera, la generación del reporte no debe detener la operación diaria.

### Optimización de las consultas

Además de separar el procesamiento, las consultas utilizadas para generar los reportes deberán optimizarse para reducir el impacto sobre la base de datos.

Se podrán utilizar mecanismos como:

- Consultas optimizadas.
- Índices adecuados.
- Redis para almacenar o reutilizar información cuyo cálculo resulte costoso.
- Procesamiento independiente de la solicitud del usuario.
- Control de los recursos utilizados por la generación del reporte.

La solución definitiva se determinará durante el desarrollo y las pruebas del proyecto.

### ¿Cómo se demuestra?

Esta decisión no debe quedarse solamente como una explicación teórica.

Se realizarán **pruebas de carga** para comparar el comportamiento del sistema bajo diferentes condiciones:

- Operación normal de facturación.
- Generación simultánea del reporte mensual.
- Operación de facturación mientras se ejecutan procesos pesados.

Se deberán medir aspectos como:

- Tiempo de respuesta.
- Cantidad de solicitudes procesadas.
- Uso de CPU.
- Uso de memoria.
- Comportamiento de la API.
- Tiempo necesario para generar el reporte.

El objetivo será demostrar mediante mediciones que la generación del reporte mensual **no degrada de manera inaceptable las operaciones críticas de facturación e inventario**.

### Conclusión

GestiónPyme mantendrá un **monolito modular**, pero aislará el procesamiento pesado del reporte mediante mecanismos de ejecución independiente, optimización de consultas y utilización de Redis cuando corresponda.

La efectividad de esta decisión será comprobada mediante pruebas de carga y métricas obtenidas durante el funcionamiento del sistema.

## 3. El negocio no puede perder ninguna factura. ¿Cuál es su pérdida máxima de datos y cómo la demuestran?

Para GestiónPyme, la información relacionada con las facturas es crítica para el funcionamiento del negocio.

El proyecto establece que **el negocio no puede perder ninguna factura**, por lo que la arquitectura debe garantizar que las facturas que hayan sido registradas correctamente puedan recuperarse ante una falla.

### Pérdida máxima de datos

La pérdida máxima aceptable para las facturas confirmadas es:

**Pérdida máxima: 0 facturas.**

Esto significa que una factura que haya sido confirmada y almacenada correctamente no debe desaparecer como consecuencia de una falla del sistema.

En términos de recuperación de datos, el objetivo será trabajar con un **RPO de 0 para las facturas confirmadas**.

### ¿Cómo se garantiza?

La información de facturación deberá almacenarse en una base de datos con **persistencia**, evitando que los datos dependan únicamente de los componentes temporales de la aplicación.

Para esto se utilizará PostgreSQL con almacenamiento persistente.

Además, se implementarán mecanismos de:

- Persistencia de la información.
- Respaldo de la base de datos.
- Restauración de los respaldos.
- Verificación de la información después de una recuperación.
- Registro de las operaciones necesarias para mantener la trazabilidad de las facturas.

El objetivo no es solamente crear un respaldo, sino demostrar que dicho respaldo puede utilizarse efectivamente para recuperar la información.

### ¿Cómo se demuestra?

Se realizará una prueba controlada de recuperación.

El procedimiento será:

    1. Registrar facturas de prueba
              ↓
    2. Confirmar que fueron almacenadas
              ↓
    3. Realizar el respaldo correspondiente
              ↓
    4. Simular una falla o pérdida del componente
              ↓
    5. Restaurar la información
              ↓
    6. Verificar las facturas

Después de la restauración se comprobará que las facturas registradas antes de la falla continúan disponibles y que su información permanece íntegra.

La evidencia deberá incluir:

- Facturas existentes antes de la prueba.
- Respaldo realizado.
- Procedimiento de recuperación.
- Restauración de PostgreSQL.
- Facturas disponibles después de la recuperación.
- Comparación de los datos antes y después de la falla.

### Resultado esperado

La prueba deberá demostrar que:

    Facturas confirmadas antes de la falla
                        =
    Facturas recuperadas después de la recuperación

Por lo tanto:

**Pérdida máxima aceptable de facturas = 0.**

### Conclusión

La arquitectura de GestiónPyme debe priorizar la **integridad y recuperación de la información de facturación**.

No será suficiente afirmar que existen copias de seguridad. El proyecto deberá demostrar mediante una prueba reproducible que, ante una falla, las facturas confirmadas pueden recuperarse correctamente y que la pérdida de información es de **0 facturas**.