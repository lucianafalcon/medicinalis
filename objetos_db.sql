/* ==========================================================
   Medicinalis - L.Falcon

    -- SCRIPT DE CREACIÓN DE VISTAS, FUNCIONES, STORED PROCEDURES
    Y TRIGGERS
    -- PROYECTO: Medicinalis  
========================================================== */

USE Medicinalis;

-- ######################################
-- 1. FUNCIONES PERSONALIZADAS
-- ######################################

-- Función para calcular la edad del paciente
DELIMITER $$
CREATE FUNCTION fn_CalcularEdad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
END$$
DELIMITER ;

-- Función para determinar el estado de un resultado
DELIMITER $$
CREATE FUNCTION fn_EstadoResultado(p_id_resultado INT)
RETURNS VARCHAR(10)
READS SQL DATA
BEGIN
    DECLARE v_valor FLOAT;
    DECLARE v_min FLOAT;
    DECLARE v_max FLOAT;

    SELECT valor_resultado, rango_min, rango_max
    INTO v_valor, v_min, v_max
    FROM Resultado
    WHERE id_resultado = p_id_resultado;

    IF v_valor IS NULL THEN
        RETURN 'NULL';
    ELSEIF v_valor < v_min THEN
        RETURN 'Bajo';
    ELSEIF v_valor > v_max THEN
        RETURN 'Alto';
    ELSE
        RETURN 'Normal';
    END IF;
END$$
DELIMITER ;

-- ######################################
-- 2. STORED PROCEDURES (SP)
-- ######################################

-- SP para generar una Condición (llamado por el Trigger)
DELIMITER $$
CREATE PROCEDURE sp_GenerarCondicion(p_id_resultado INT)
BEGIN
    DECLARE v_estado VARCHAR(10);
    DECLARE v_id_biomarcador INT;
    DECLARE v_condicion_id INT;

    -- Obtener estado y biomarcador
    SET v_estado = fn_EstadoResultado(p_id_resultado);
    SELECT id_biomarcador INTO v_id_biomarcador FROM Resultado WHERE id_resultado = p_id_resultado;

    -- Lógica simple: Si es 'Bajo' o 'Alto', intentar generar una condición.
    IF v_estado IN ('Bajo', 'Alto') THEN
        
        -- la lógica real es compleja, buscando una condición específica
        -- Por simplicidad, asumimos una Condición base para la demostración:
        IF v_estado = 'Bajo' THEN
            SET v_condicion_id = 1; 
        ELSE
            SET v_condicion_id = 2; 
        END IF;

        -- Registrar la Condición generada en la tabla de enlace N:N
        INSERT INTO Resultado_Condicion (id_resultado, id_condicion)
        VALUES (p_id_resultado, v_condicion_id)
        ON DUPLICATE KEY UPDATE id_resultado = id_resultado; -- Previene duplicados si se llama dos veces
        
    END IF;
END$$
DELIMITER ;

-- SP para registrar un nuevo estudio completo (Estudio + Resultados)
DELIMITER $$
CREATE PROCEDURE sp_RegistrarNuevoEstudio(
    IN p_id_paciente INT,
    IN p_tipo_estudio VARCHAR(50),
    IN p_fecha_estudio DATE,
    IN p_id_biomarcador_1 INT, IN p_valor_1 FLOAT, IN p_min_1 FLOAT, IN p_max_1 FLOAT,
    IN p_id_biomarcador_2 INT, IN p_valor_2 FLOAT, IN p_min_2 FLOAT, IN p_max_2 FLOAT
    -- Se pueden añadir más parámetros para más resultados
)
BEGIN
    DECLARE v_id_estudio INT;
    DECLARE v_id_resultado_1 INT;
    DECLARE v_id_resultado_2 INT;
    
    START TRANSACTION;

    -- 1. Insertar el nuevo estudio
    INSERT INTO Estudio (tipo_estudio, fecha_estudio) VALUES (p_tipo_estudio, p_fecha_estudio);
    SET v_id_estudio = LAST_INSERT_ID();

    -- 2. Insertar Resultados (Resultado 1)
    INSERT INTO Resultado (id_paciente, id_estudio, id_biomarcador, valor_resultado, rango_min, rango_max)
    VALUES (p_id_paciente, v_id_estudio, p_id_biomarcador_1, p_valor_1, p_min_1, p_max_1);
    SET v_id_resultado_1 = LAST_INSERT_ID();

    -- 3. Insertar Resultados (Resultado 2)
    INSERT INTO Resultado (id_paciente, id_estudio, id_biomarcador, valor_resultado, rango_min, rango_max)
    VALUES (p_id_paciente, v_id_estudio, p_id_biomarcador_2, p_valor_2, p_min_2, p_max_2);
    SET v_id_resultado_2 = LAST_INSERT_ID();

    COMMIT;
    
END$$
DELIMITER ;

-- ######################################
-- 3. VISTAS (VIEWS)
-- ######################################

-- 3.1. Vista: Historial Nutricional Completo
CREATE VIEW vw_HistorialNutricional AS
SELECT
    P.id_paciente, P.nombre, P.apellido, P.fecha_nacimiento, fn_CalcularEdad(P.fecha_nacimiento) AS edad,
    E.id_estudio, E.tipo_estudio, E.fecha_estudio,
    R.id_resultado, B.nombre_biomarcador, R.valor_resultado, R.rango_min, R.rango_max,
    fn_EstadoResultado(R.id_resultado) AS estado_resultado,
    C.nombre_condicion
FROM Paciente P
JOIN Resultado R ON P.id_paciente = R.id_paciente
JOIN Estudio E ON R.id_estudio = E.id_estudio
JOIN Biomarcador B ON R.id_biomarcador = B.id_biomarcador
LEFT JOIN Resultado_Condicion RC ON R.id_resultado = RC.id_resultado
LEFT JOIN Condicion C ON RC.id_condicion = C.id_condicion;

-- 3.2. Vista: Recomendaciones Pendientes
CREATE VIEW vw_RecomendacionesPendientes AS
SELECT
    C.nombre_condicion,
    Rec.producto_recomendado,
    Rec.descripcion_recomendacion
FROM Condicion C
JOIN Recomendacion Rec ON C.id_condicion = Rec.id_condicion;

-- 3.3. Vista: Biomarcadores Fuera de Rango
CREATE VIEW vw_BiomarcadoresFueraRango AS
SELECT
    P.nombre, P.apellido,
    E.fecha_estudio,
    B.nombre_biomarcador, B.unidad_medida,
    R.valor_resultado, R.rango_min, R.rango_max,
    fn_EstadoResultado(R.id_resultado) AS Estado
FROM Resultado R
JOIN Paciente P ON R.id_paciente = P.id_paciente
JOIN Estudio E ON R.id_estudio = E.id_estudio
JOIN Biomarcador B ON R.id_biomarcador = B.id_biomarcador
WHERE fn_EstadoResultado(R.id_resultado) IN ('Bajo', 'Alto');

-- 3.4. Vista: Mostrar un resumen compacto por paciente (estudios tiene, restados cargados y condiciones detectadas)
CREATE VIEW vw_ResumenEstudios AS
SELECT 
    p.id_paciente,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente,
    COUNT(DISTINCT e.id_estudio) AS total_estudios,
    COUNT(DISTINCT r.id_resultado) AS total_resultados,
    COUNT(DISTINCT rc.id_condicion) AS total_condiciones
FROM Paciente p
LEFT JOIN Estudio e ON p.id_paciente = e.id_paciente
LEFT JOIN Resultado r ON e.id_estudio = r.id_estudio
LEFT JOIN Resultado_Condicion rc ON r.id_resultado = rc.id_resultado
GROUP BY p.id_paciente;

-- 3.5. Vista: Mostrar que condiciones se generan con cada biomarcador + los valores y rangos
CREATE VIEW vw_CondicionesPorBiomarcador AS
SELECT 
    b.nombre_biomarcador,
    r.valor_resultado,
    r.rango_min,
    r.rango_max,
    c.nombre_condicion,
    p.nombre AS nombre_paciente,
    p.apellido AS apellido_paciente
FROM Biomarcador b
JOIN Resultado r ON b.id_biomarcador = r.id_biomarcador
JOIN Paciente p ON p.id_paciente = r.id_paciente
LEFT JOIN Resultado_Condicion rc ON r.id_resultado = rc.id_resultado
LEFT JOIN Condicion c ON c.id_condicion = rc.id_condicion;
Con estas dos ya tenés:

-- ######################################
-- 4. TRIGGERS
-- ######################################

-- Trigger 1: para ejecutar el diagnóstico automáticamente después de un INSERT en Resultado
DELIMITER $$
CREATE TRIGGER tr_after_insert_resultado
AFTER INSERT ON Resultado
FOR EACH ROW
BEGIN
    -- Llamar al SP que genera la condición inmediatamente después de cargar un resultado
    CALL sp_GenerarCondicion(NEW.id_resultado);
END$$
DELIMITER ;

-- Trigger 2: por si alguien vuelve a cargar un valor corregido en un análisis, el sistema recalcula automáticamente si debe crear o actualizar condiciones,garantizando coherencia clínica
CREATE TRIGGER tr_after_update_resultado
AFTER UPDATE ON Resultado
FOR EACH ROW
BEGIN
    CALL sp_GenerarCondicion(NEW.id_resultado);
END;
