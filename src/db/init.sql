-- Base de datos de GestiónPyme: Facturación e inventario para una pyme.
-- Se ejecuta solo la primera vez que PostgreSQL arranca con el volumen vacio.

-- Productos
CREATE TABLE IF NOT EXISTS items (
  id        SERIAL PRIMARY KEY,
  nombre    TEXT NOT NULL,          -- Producto
  detalle   TEXT NOT NULL,          -- Bodega y precio
  categoria TEXT NOT NULL,          -- Línea
  cantidad  NUMERIC(14,2) NOT NULL CHECK (cantidad >= 0)  -- Unidades
);

-- Facturas
CREATE TABLE IF NOT EXISTS registros (
  id      SERIAL PRIMARY KEY,
  item_id INTEGER REFERENCES items(id),
  persona TEXT NOT NULL,            -- Cliente
  monto   NUMERIC(14,2),
  fecha   TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO items (nombre, detalle, categoria, cantidad) VALUES
  ('Resma papel carta', 'Bodega principal · $18.500', 'Papelería', 60),
  ('Tóner impresora', 'Bodega principal · $210.000', 'Tecnología', 8),
  ('Silla ergonómica', 'Bodega 2 · $480.000', 'Mobiliario', 5),
  ('Cuaderno argollado', 'Bodega principal · $9.000', 'Papelería', 120),
  ('Mouse inalámbrico', 'Bodega 2 · $45.000', 'Tecnología', 30);
