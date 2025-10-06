/* ==========================================================
   Medicinalis - L.Falcon
   
   Script de creación de base de datos y tablas 
========================================================== */

CREATE DATABASE medicinalis;
USE medicinalis;

-- creacion tablas
CREATE TABLE paciente (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_nacimiento DATE,
    sexo VARCHAR(10)
);

CREATE TABLE estudio (
    id_estudio INT AUTO_INCREMENT PRIMARY KEY,
    tipo_estudio VARCHAR(50),
    fecha_estudio DATE
);

CREATE TABLE biomarcador (
    id_biomarcador INT AUTO_INCREMENT PRIMARY KEY,
    nombre_biomarcador VARCHAR(50),
    unidad_medida VARCHAR(10)
);

CREATE TABLE resultado (
    id_resultado INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT,
	id_estudio INT,
    id_biomarcador INT, 
    rango_min INT,
    rango_max INT,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_estudio) REFERENCES estudio(id_estudio),
    FOREIGN KEY (id_biomarcador) REFERENCES biomarcador(id_biomarcador)
);

CREATE TABLE condicion (
    id_condicion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_condicion VARCHAR(50)
);

CREATE TABLE recomendacion (
    id_recomendacion INT AUTO_INCREMENT PRIMARY KEY,
	id_condicion INT,
    producto_recomendado VARCHAR(50),
    descripcion_recomendacion VARCHAR(100),
    FOREIGN KEY (id_condicion) REFERENCES condicion(id_condicion)
);
