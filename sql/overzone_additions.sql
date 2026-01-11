-- overzone_additions.sql
-- Agrega campos para la economía (coins = Petro) y licencias

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS coins INT DEFAULT 0,
    ADD COLUMN IF NOT EXISTS licenses INT DEFAULT 0;

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS nivel INT DEFAULT 1,
    ADD COLUMN IF NOT EXISTS exp INT DEFAULT 0;

-- Si la tabla no existe, este es un esquema base sugerido:
-- CREATE TABLE usuarios (
--   id INT AUTO_INCREMENT PRIMARY KEY,
--   nombre VARCHAR(50) UNIQUE,
--   clave VARCHAR(129),
--   correo VARCHAR(64),
--   edad INT,
--   genero INT,
--   skin INT,
--   x FLOAT,
--   y FLOAT,
--   z FLOAT,
--   a FLOAT,
--   dinero INT DEFAULT 0,
--   coins INT DEFAULT 0,
--   licenses INT DEFAULT 0,
--   vida FLOAT DEFAULT 100.0,
--   chaleco FLOAT DEFAULT 0.0,
--   admin INT DEFAULT 0
-- );
