-- houses.sql - tabla de casas para OverZone RP

USE `overzone`;

CREATE TABLE IF NOT EXISTS `houses` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(64) NOT NULL,
  `x` FLOAT DEFAULT 0,
  `y` FLOAT DEFAULT 0,
  `z` FLOAT DEFAULT 0,
  `a` FLOAT DEFAULT 0,
  `price` INT DEFAULT 0, -- precio en coins
  `owner` VARCHAR(50) DEFAULT NULL,
  `open24` TINYINT DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ejemplos de casas
INSERT INTO houses (name, x, y, z, a, price, open24) VALUES
('Casa Centro', 245.0, -1700.0, 13.0, 0.0, 10, 1),
('Casa Suburbio', 1200.0, -1700.0, 13.0, 90.0, 5, 1),
('Departamento Lujoso', -1500.0, 600.0, 7.0, 180.0, 50, 1);
