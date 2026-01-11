-- overzone.sql - esquema para OverZone RP (tabla usuarios)

CREATE DATABASE IF NOT EXISTS `overzone`;
USE `overzone`;

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
  `vida` FLOAT DEFAULT 100.0,
  `chaleco` FLOAT DEFAULT 0.0,
  `admin` INT DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ejemplo: insertar un usuario de prueba
-- INSERT INTO usuarios (nombre, clave, correo, edad, genero, skin, x, y, z, a, dinero, coins, licenses, nivel, exp) VALUES ('TestUser', '12345', 'test@example.com', 25, 0, 60, 0, 0, 3, 0, 1000, 0, 0, 1, 0);
