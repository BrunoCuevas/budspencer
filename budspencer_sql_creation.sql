DROP SCHEMA IF EXISTS budspencer ;
CREATE SCHEMA budspencer	;
USE budspencer				;
DROP TABLE IF EXISTS articulos	;
CREATE TABLE articulos (
	titulo VARCHAR(500),
    fecha  DATE,
    pubmed_id VARCHAR(20),
    autor_principal VARCHAR(100),
    fuente VARCHAR(100),
	year INT,
    PRIMARY KEY (pubmed_id)
) ;
DROP TABLE IF EXISTS autores	;
CREATE TABLE autores (
	nombre VARCHAR(100),
    PRIMARY KEY (nombre)
);
DROP TABLE IF EXISTS escrito_por	;
CREATE TABLE escrito_por (
	pubmed VARCHAR(20) NOT NULL REFERENCES articulos(pubmed_id),
    autor VARCHAR(100) NOT NULL REFERENCES autores(nombre),	
    index fk_pubmed(pubmed),
    index fk_autor(autor),
    primary key (pubmed, autor)
);