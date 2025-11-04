/* ==========================================================
   Medicinalis - L.Falcon
   
   -- Script de creación de base de datos y tablas
   -- PROYECTO: Medicinalis  
========================================================== */

CREATE DATABASE medicinalis;
USE medicinalis;

-- ######################################
-- 1. CREACIÓN DE TABLAS
-- ######################################

-- Tabla 1. Paciente
CREATE TABLE Paciente (
    id_paciente INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NULL,
    sexo VARCHAR(10) NULL,
    PRIMARY KEY (id_paciente) 
);

-- Tabla 2. Estudio
CREATE TABLE Estudio (
    id_estudio INT AUTO_INCREMENT,
    tipo_estudio VARCHAR(50) NOT NULL,
    fecha_estudio DATE NULL,
    PRIMARY KEY (id_estudio) 
);

-- Tabla 3. Biomarcador
CREATE TABLE Biomarcador (
    id_biomarcador INT AUTO_INCREMENT,
    nombre_biomarcador VARCHAR(50) NOT NULL,
    unidad_medida VARCHAR(10) NULL,
    PRIMARY KEY (id_biomarcador) 
);

-- Tabla 4. Resultado (Contiene las FK a Paciente, Estudio y Biomarcador)
CREATE TABLE Resultado (
    id_resultado INT AUTO_INCREMENT,
    id_paciente INT NOT NULL, 
    id_estudio INT NOT NULL,
    id_biomarcador INT NOT NULL, 
    valor_resultado FLOAT NOT NULL,
    rango_min FLOAT NULL,
    rango_max FLOAT NULL,
    PRIMARY KEY (id_resultado), 
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente), 
    FOREIGN KEY (id_estudio) REFERENCES Estudio(id_estudio), 
    FOREIGN KEY (id_biomarcador) REFERENCES Biomarcador(id_biomarcador) 
);

-- Tabla 5. Condición
CREATE TABLE Condicion (
    id_condicion INT AUTO_INCREMENT,
    nombre_condicion VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_condicion) 
);

-- Tabla 6. Recomendación (Contiene la FK a Condición)
CREATE TABLE Recomendacion (
    id_recomendacion INT AUTO_INCREMENT,
    id_condicion INT NOT NULL, 
    producto_recomendado VARCHAR(255) NULL,
    descripcion_recomendacion VARCHAR(255) NULL,
    PRIMARY KEY (id_recomendacion), 
    FOREIGN KEY (id_condicion) REFERENCES Condicion(id_condicion)
);

-- ######################################
-- 2. TABLA DE ENLACE RELACIONAL
-- ######################################

-- Tabla 7. Resultado_Condicion (Resuelve la conexión N:N entre Resultado y Condición)
-- Esta tabla vincula un resultado específico de un paciente a la condición generada.
CREATE TABLE Resultado_Condicion (
    id_resultado INT NOT NULL,
    id_condicion INT NOT NULL,
    PRIMARY KEY (id_resultado, id_condicion), 
    FOREIGN KEY (id_resultado) REFERENCES Resultado(id_resultado), 
    FOREIGN KEY (id_condicion) REFERENCES Condicion(id_condicion)
);