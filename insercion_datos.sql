/* ==========================================================
   Medicinalis - L.Falcon

   -- SCRIPT DE INSERCIÓN DE DATOS
   -- PROYECTO: Medicinalis
========================================================== */


USE Medicinalis; -- Reemplazar con el nombre real de tu base de datos

-- 1. Insertar Pacientes
INSERT INTO Paciente (nombre, apellido, fecha_nacimiento, sexo) VALUES
('Ana', 'Gomez', '1990-05-15', 'Femenino'),       
('Luis', 'Perez', '1985-11-20', 'Masculino'),     
('Maria', 'Lopez', '2000-01-01', 'Femenino');     

-- 2. Insertar Biomarcadores
INSERT INTO Biomarcador (nombre_biomarcador, unidad_medida) VALUES
('Hierro', 'ug/dL'),        
('Glucosa', 'mg/dL'),       
('Vitamina D', 'ng/mL');    

-- 3. Insertar Condiciones (Necesarias para el SP y Trigger)
INSERT INTO Condicion (id_condicion, nombre_condicion) VALUES
(1, 'Déficit Nutricional'),  
(2, 'Nivel Elevado'),        
(3, 'Hipoglucemia');         

-- 4. Insertar Recomendaciones
INSERT INTO Recomendacion (id_condicion, producto_recomendado, descripcion_recomendacion) VALUES
(1, 'Suplemento de Hierro', 'Tomar 1 cápsula diaria con alimentos ricos en Vitamina C.'),
(2, 'Dieta Baja en Azúcares', 'Aumentar el consumo de fibra y reducir carbohidratos simples.'),
(1, 'Consumo de Sol', 'Exposición diaria de 15 minutos a la luz solar.');


-- 5. Insertar Estudios (Usando el SP para demostrar su funcionalidad)
-- Resultado 1: Hierro BAJO (Activa Condición 1: Déficit Nutricional)
-- Resultado 2: Glucosa NORMAL (No activa condición)
CALL sp_RegistrarNuevoEstudio(
    1,                       -- p_id_paciente: Ana Gomez
    'Análisis General',      -- p_tipo_estudio
    '2025-10-01',            -- p_fecha_estudio
    1, 40.0, 60.0, 150.0,    -- B1: Hierro, Valor: 40.0 (BAJO) - Rango [60, 150]
    2, 95.0, 70.0, 100.0     -- B2: Glucosa, Valor: 95.0 (NORMAL) - Rango [70, 100]
); -- Esto insertará 1 Estudio (PK 1) y 2 Resultados (PK 1 y PK 2). El Trigger genera una Condición para el Resultado 1.

CALL sp_RegistrarNuevoEstudio(
    2,                       
    'Control Nutricional',  
    '2025-10-15',            
    3, 110.0, 20.0, 80.0,   
    2, 65.0, 70.0, 100.0     
); 

-- 6. Consultas de Verificación
SELECT * FROM Resultado_Condicion; -- Verifica el funcionamiento del Trigger y SP
SELECT * FROM vw_HistorialNutricional WHERE id_paciente = 1; -- Verifica la Vista
SELECT * FROM vw_BiomarcadoresFueraRango; -- Verifica la Vista
