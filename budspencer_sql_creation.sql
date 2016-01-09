DROP DATABASE IF EXISTS budspencer ;
CREATE DATABASE budspencer	;
USE budspencer;
DROP TABLE IF EXISTS articulos	;
CREATE TABLE articulos (
	titulo VARCHAR(500),

    pubmed_id VARCHAR(20) UNIQUE NOT NULL,
    autor_principal VARCHAR(100),
    fuente VARCHAR(100),
    volumen VARCHAR(10),
    issue VARCHAR(10),
	year INT,
    id INT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id)
) AUTO_INCREMENT = 1;
DROP TABLE IF EXISTS autores	;
CREATE TABLE autores (
	nombre VARCHAR(100),
    PRIMARY KEY (nombre)
);
DROP TABLE IF EXISTS escrito_por	;
CREATE TABLE escrito_por (
	pubmed VARCHAR(20) ,
    autor VARCHAR(100) ,
    PRIMARY KEY (pubmed, autor),
    INDEX (pubmed),
    FOREIGN KEY (pubmed)
    REFERENCES articulos(pubmed_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX(autor),
    FOREIGN KEY (autor)
    REFERENCES autores(nombre)
    ON DELETE RESTRICT ON UPDATE CASCADE
);
GRANT USAGE ON *.* TO 'budspencer_user'@'localhost';
DROP USER 'budspencer_user'@'localhost';
CREATE USER 'budspencer_user'@'localhost' IDENTIFIED BY 'bud_spencer_123';


GRANT SELECT ON budspencer.* TO 'budspencer_user'@'localhost' ;
GRANT INSERT ON budspencer.* TO 'budspencer_user'@'localhost' ;
