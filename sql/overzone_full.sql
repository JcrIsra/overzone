-- overzone_full.sql
-- Esquema completo + datos de prueba para OverZone RP
-- Ejecutar en MySQL/MariaDB: mysql -u root -p < overzone_full.sql

-- El script recrea la base para pruebas (DROP opcional)
DROP DATABASE IF EXISTS `overzone`;
CREATE DATABASE `overzone` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `overzone`;

-- Tabla: usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL UNIQUE,
  `clave` VARCHAR(129) NOT NULL,
  `correo` VARCHAR(64) DEFAULT NULL,
  `edad` INT DEFAULT 0,
  `genero` INT DEFAULT 0,
  `skin` INT DEFAULT 0,
  `x` FLOAT DEFAULT 0,
  `y` FLOAT DEFAULT 0,
  `z` FLOAT DEFAULT 0,
  `a` FLOAT DEFAULT 0,
  `dinero` INT DEFAULT 0,
  `coins` INT DEFAULT 0,
  `licenses` INT DEFAULT 0,
  `nivel` INT DEFAULT 1,
  `exp` INT DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `last_login` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `vida` FLOAT DEFAULT 100.0,
  `chaleco` FLOAT DEFAULT 0.0,
  `admin` INT DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: houses
CREATE TABLE IF NOT EXISTS `houses` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(64) NOT NULL,
  `x` FLOAT DEFAULT 0,
  `y` FLOAT DEFAULT 0,
  `z` FLOAT DEFAULT 0,
  `a` FLOAT DEFAULT 0,
  `price` INT DEFAULT 0,
  `owner` VARCHAR(50) DEFAULT NULL,
  `open24` TINYINT DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO usuarios (nombre, clave, correo, edad, genero, skin, x, y, z, a, dinero, coins, licenses, nivel, exp, created_at, last_login, vida, chaleco, admin)
VALUES
('TestUser', '12345', 'test@example.com', 25, 0, 60, 0.0, 0.0, 3.0, 0.0, 1000000, 10, 0, 1, 0, NOW(), NOW(), 100.0, 0.0, 5),
('Player1', 'password', 'player1@vzla.test', 30, 0, 60, 245.0, -1700.0, 13.0, 0.0, 500000, 2, 1, 1, 0, NOW(), NOW(), 100.0, 0.0, 0);

-- Datos de prueba: houses
INSERT INTO houses (name, x, y, z, a, price, open24) VALUES
('Casa Centro', 245.0, -1700.0, 13.0, 0.0, 10, 1),
('Casa Suburbio', 1200.0, -1700.0, 13.0, 90.0, 5, 1),
('Departamento Lujoso', -1500.0, 600.0, 7.0, 180.0, 50, 1);

-- Índices útiles
CREATE INDEX idx_usuarios_nombre ON usuarios(nombre);
CREATE INDEX idx_houses_owner ON houses(owner);

-- Fin del script
