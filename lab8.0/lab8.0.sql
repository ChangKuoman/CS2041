CREATE OR REPLACE FUNCTION get_cliente_by_ruc(p_ruc varchar)
RETURNS TABLE(clienteid INTEGER, fechaorden date) AS
$$
  BEGIN
  RETURN QUERY
    SELECT O.clienteid, O.fechaorden
    FROM clientes C, ordenes O
    where C.clienteid =O.clienteid 
    AND C.cedula_ruc = p_ruc;
  END;
$$ LANGUAGE plpgsql;

SELECT get_cliente_by_ruc('1298765477');

CREATE OR REPLACE FUNCTION SP_CLIENTE_INS(
  p_id int,
  p_ruc varchar,
  p_nombre varchar,
  p_contacto varchar,
  p_direccion varchar
)
RETURNS void AS $$
  BEGIN
    INSERT INTO clientes(clienteid, cedula_ruc, nombrecia, nombrecontacto, direccioncli)
    VALUES (p_id, p_ruc, p_nombre,p_contacto,p_direccion);
  END;
$$ LANGUAGE plpgsql;