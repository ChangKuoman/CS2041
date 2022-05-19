
SET search_path TO pre_pc2;

-- c
CREATE TABLE IF NOT EXISTS profesor(
    dni VARCHAR(8) PRIMARY KEY,
    nombre VARCHAR(8) NOT NULL,
    especialidad VARCHAR(50) NOT NULL
);

ALTER TABLE programa ADD COLUMN dni_profesor VARCHAR(8);

ALTER TABLE programa ADD CONSTRAINT dni_profesor_fk FOREIGN KEY (dni_profesor) REFERENCES profesor(dni);

INSERT INTO profesor VALUES('00000000', 'Profesor Nulo', 'Nula');

UPDATE programa SET dni_profesor = '00000000' WHERE dni_profesor IS NULL;

ALTER TABLE programa ALTER COLUMN dni_profesor SET NOT NULL;

CREATE OR REPLACE FUNCTION aforo_maximo() RETURNS TRIGGER AS $$
    begin
        IF ((SELECT COUNT(dni) FROM asistencia WHERE pid = NEW.pid GROUP BY pid) < 10) THEN
            RETURN NEW;
        ELSE
            RETURN NULL;
        END IF;
    end;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_aforo_maximo
BEFORE INSERT ON asistencia
FOR EACH ROW EXECUTE PROCEDURE aforo_maximo();


INSERT INTO asistencia VALUES
(5,'192928789','2019-01-10 08:47:00.000000'),
(5,'192928790','2019-01-10 08:47:00.000000'),
(5,'192928791','2019-01-10 08:47:00.000000'),
(5,'192928792','2019-01-10 08:47:00.000000'),
(5,'192928793','2019-01-10 08:47:00.000000'),
(5,'192928794','2019-01-10 08:47:00.000000'),
(5,'192928795','2019-01-10 08:47:00.000000'),
(5,'192928796','2019-01-10 08:47:00.000000'),
(5,'192928797','2019-01-10 08:47:00.000000'),
(5,'192928798','2019-01-10 08:47:00.000000');


INSERT INTO asistencia VALUES
(5,'121824399','2019-01-10 08:47:00.000000');

SELECT COUNT(dni) FROM asistencia GROUP BY pid;

-- d
SELECT actividad, horario, count(*)
FROM programa 
NATURAL JOIN asistencia
GROUP BY actividad, horario
HAVING actividad = 'RoboRally';

-- e
SELECT nombre
FROM interesado
EXCEPT
SELECT nombre
FROM interesado NATURAL JOIN programa NATURAL JOIN asistencia
WHERE carrera = 'Ciencia Computacion';

SELECT dni, nombre
FROM interesado
WHERE dni NOT IN (
    SELECT dni
    FROM interesado NATURAL JOIN asistencia NATURAL JOIN programa
    WHERE carrera = 'Ciencia Computacion'
);

-- f

/*

\pi colegio (\sigma hora < 10am(Interesado \bowtie Asistencia))

*/

-- g

/*



*/

-- h

SELECT nombre
FROM asistencia 
NATURAL JOIN interesado
NATURAL JOIN programa
WHERE actividad = 'RoboRally'
INTERSECT
SELECT nombre
FROM asistencia 
NATURAL JOIN interesado
NATURAL JOIN programa
WHERE actividad = 'Pensamiento Computacional';

-- i

/*
\pi _{R-S} (r) - \pi _{R-S} (\pi _{R-S}(r) x (s)) - \pi _{R-S, S}(r)
*/

SELECT pid, dni
FROM interesado NATURAL JOIN asistencia
WHERE pid IN (
    SELECT pid
    FROM programa
    WHERE carrera = 'Ciencia Computacion'
);

/* / */

SELECT pid
FROM programa
WHERE carrera = 'Ciencia Computacion';

INSERT INTO asistencia(pid, dni, hora) VALUES
(1,'181055499','1/10/2019 08:00:00'),
(2,'181055499','1/10/2019 08:00:00'),
(3,'152666099','1/10/2019 08:10:00'),
(4,'181055499','1/10/2019 08:12:00'),
(1,'192928799','1/10/2019 08:15:00'),
(2,'103092199','1/10/2019 08:30:00'),
(2,'121824399','1/10/2019 08:33:00'),
(3,'181055499','1/10/2019 08:35:00'),
(5,'181055499','1/10/2019 08:45:00'),
(4,'192928799','1/10/2019 08:47:00');