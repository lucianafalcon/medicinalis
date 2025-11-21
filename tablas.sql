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


-- ######################################
-- 2. TABLA DE IMPLEMENTACION
-- ######################################

-- TABLA 8 — Hecho: ResultadosNutricionales
CREATE TABLE Hecho_ResultadosNutricionales (
    id_hecho INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT,
    id_estudio INT,
    id_biomarcador INT,
    valor_resultado FLOAT,
    diferencia_min FLOAT,
    diferencia_max FLOAT,
    fecha_estudio DATE,
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente),
    FOREIGN KEY (id_estudio) REFERENCES Estudio(id_estudio),
    FOREIGN KEY (id_biomarcador) REFERENCES Biomarcador(id_biomarcador)
);


-- TABLA 9 — Transaccional: TransaccionEstudio
CREATE TABLE Transaccion_Estudio (
    id_transaccion_estudio INT AUTO_INCREMENT PRIMARY KEY,
    id_estudio INT,
    fecha_transaccion DATETIME,
    accion VARCHAR(50),
    FOREIGN KEY (id_estudio) REFERENCES Estudio(id_estudio)
);

-- TABLA 10 — UnidadMedida
CREATE TABLE UnidadMedida (
    id_unidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_unidad VARCHAR(20)
);

-- TABLA 11 — CategoriaBiomarcador
CREATE TABLE CategoriaBiomarcador (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50)
);

-- TABLA 12 — Biomarcador_Categoria 
CREATE TABLE Biomarcador_Categoria (
    id_biomarcador INT,
    id_categoria INT,
    PRIMARY KEY (id_biomarcador, id_categoria),
    FOREIGN KEY (id_biomarcador) REFERENCES Biomarcador(id_biomarcador),
    FOREIGN KEY (id_categoria) REFERENCES CategoriaBiomarcador(id_categoria)
);

-- TABLA 13 — CategoriaRecomendacion
CREATE TABLE CategoriaRecomendacion (
    id_categoria_reco INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50)
);


-- TABLA 14 — Recomendacion_Categoria 
CREATE TABLE Recomendacion_Categoria (
    id_recomendacion INT,
    id_categoria_reco INT,
    PRIMARY KEY (id_recomendacion, id_categoria_reco),
    FOREIGN KEY (id_recomendacion) REFERENCES Recomendacion(id_recomendacion),
    FOREIGN KEY (id_categoria_reco) REFERENCES CategoriaRecomendacion(id_categoria_reco)
);
