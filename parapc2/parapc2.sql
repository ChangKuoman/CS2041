
-- 2.a. Publicación más antigua
SELECT username, fecha, ubicacion, descripcion
FROM publicacion
EXCEPT 
SELECT p1.username, p1.fecha, p1.ubicacion, p1.descripcion FROM publicacion p1, publicacion p2
WHERE p1.fecha > p2.fecha;

-- 2.b. Fotos que no tienen tags
SELECT username, fecha, numerodearchivo
FROM Foto
EXCEPT
SELECT username, fecha, numerodearchivo
FROM Foto NATURAL JOIN Tag;

-- 2.c. Link de los usuarios con cuenta privada
SELECT link
FROM Usuario
NATURAL JOIN Personal
WHERE privado = 'True';

-- 2.d. Comentarios del usuario "FuentesA0597" escritos en publicaciones del usuario "Clementien"
SELECT C.texto, C.fecha 
FROM comentario C
INNER JOIN (
    SELECT username, fecha
    FROM publicacion
    WHERE username = 'FuentesA0597'
) B
ON C.username_publicacion = B.username
AND C.fecha_publicacion = B.fecha
AND C.username_usuario = 'Clementien';

SELECT *
FROM comentario
WHERE username_publicacion = 'FuentesA0597'
AND username_usuario = 'Clementien';

-- 2.e. Usuarios que se siguen mutuamente
SELECT username_seguidor username1, username_seguido username2
FROM Sigue s1, Sigue s2
WHERE s1.username_seguidor = s2.username_seguido
AND s1.username_seguido = s2.username_seguidor;

-- 2.f. Usuarios que nunca le han dado like a una publicación

SELECT username
FROM usuario
EXCEPT
SELECT username_usuario username
FROM likee;


-- sin except:
SELECT username
FROM usuario
WHERE username NOT IN (
  SELECT username_usuario
  FROM likee
);

SELECT *
FROM usuario U
WHERE NOT EXISTS(
  SELECT username_usuario
  FROM likee
  WHERE likee.username_usurio = U.username
)

-- 2.g. Usuarios etiquetados (tageados) en publicaciones cuya ubicacion es 'Cl. Mariana Armenta 4474 Piso 9'
SELECT DISTINCT username_usuario
FROM tag
WHERE (username_multimedia, fecha, numerodearchivo) IN (
  SELECT username, fecha, numerodearchivo
  FROM multimedia
  WHERE (username, fecha, numerodearchivo) IN (
    SELECT username, fecha, numerodearchivo
    FROM publicacion
    WHERE ubicacion = 'Cl. Mariana Armenta # 4474 Piso 9'
  )
);

-- 2.h. Usuarios con cuentas privadas y al menos una publicacion con más de 10 likes
SELECT link
FROM Usuario
NATURAL JOIN Personal
WHERE privado = 'True'
AND (publicacion con mas de 10 likes);

