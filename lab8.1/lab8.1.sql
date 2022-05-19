
-- SET search_path TO petrogas202110074;

-- 2a
CREATE OR REPLACE FUNCTION get_venta_by_dayyear(p_mes INTEGER, p_anhio INTEGER)
RETURNS TABLE(
  dia numeric,
  totalventa double precision,
  cantidadventa double precision) AS 
$$
  BEGIN
  RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha) AS dia, SUM(cantidad * preciounitario) as totalventa, SUM(cantidad) as cantidadventa
    FROM venta
    WHERE EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anhio
    GROUP BY dia;
END;
$$ LANGUAGE plpgsql;

SELECT get_venta_by_dayyear(5, 2022);

INSERT INTO venta 
VALUES (16,'000001', '4214154','S001','A',(SELECT now() - interval '1 day'),1,12,12);

-- 2b
UPDATE deposito SET abastecido = 40 WHERE id = '3';
UPDATE deposito SET abastecido = 20 WHERE id = '1';

CREATE FUNCTION ActualizaStock() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS
    (
      SELECT * 
      FROM
      Surtidor S
      INNER JOIN Deposito D ON S.depositoid = D.id
      WHERE S.nroserie = NEW.nroserie AND S.lado = NEW.lado 
    )
  THEN
    UPDATE Deposito 
    SET abastecido = abastecido - NEW.cantidad 
    WHERE id = (
      SELECT D.id
      FROM
      Surtidor S
      INNER JOIN Deposito D ON S.depositoid = D.id
      WHERE S.nroserie = NEW.nroserie AND S.lado = NEW.lado 
    );
  END IF;
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ActualizaStock
AFTER INSERT ON venta
FOR EACH ROW EXECUTE PROCEDURE ActualizaStock();


INSERT INTO venta
VALUES (40, '000001', '4214154', 'S001', 'A', (SELECT now()), 1, 12, 12);


-- 2c

create table logged_actions(
  schema_name text not null,
  table_name text not null,
  user_name text,
  action_tstamp timestamp with time zone not null default current_timestamp,
  action TEXT NOT NULL check (action in ('I','D','U')),
  original_data text,
  new_data text,
  query text
);

CREATE OR REPLACE FUNCTION func_auditoria() RETURNS trigger AS $body$
DECLARE
    v_old_data TEXT;
    v_new_data TEXT;
BEGIN 

    if (TG_OP = 'UPDATE') then
        v_old_data := ROW(OLD.*);
        v_new_data := ROW(NEW.*);
        insert into logged_actions (schema_name,table_name,user_name,action,original_data,new_data,query) 
        values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data,v_new_data, current_query());
        RETURN NEW;
    elsif (TG_OP = 'DELETE') then
        v_old_data := ROW(OLD.*);
        insert into logged_actions (schema_name,table_name,user_name,action,original_data,query)
        values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data, current_query());
        RETURN OLD;
    elsif (TG_OP = 'INSERT') then
        v_new_data := ROW(NEW.*);
        insert into logged_actions (schema_name,table_name,user_name,action,new_data,query)
        values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_new_data, current_query());
        RETURN NEW;
    else
        RAISE WARNING '[IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
        RETURN NULL;
    end if;

EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;
    WHEN unique_violation THEN
        RAISE WARNING '[IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;
    WHEN others THEN
        RAISE WARNING '[IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
        RETURN NULL;
END;
$body$
LANGUAGE plpgsql


CREATE TRIGGER auditoria_venta
AFTER INSERT OR UPDATE OR DELETE ON venta
FOR EACH ROW EXECUTE PROCEDURE func_auditoria();

INSERT INTO venta VALUES (8,'000001', '4214154','S001','A',(SELECT now()),1,12,12);

-- 2.d

-- 2.e
CREATE OR REPLACE FUNCTION insetar_cliente(
  nro_documento varchar
)
RETURNS void AS $$
  BEGIN
    INSERT INTO cliente(nrodocumento)
    VALUES (nro_documento);
  END;
$$ LANGUAGE plpgsql;

SELECT insetar_cliente('12345678');

-- 2.f
CREATE OR REPLACE FUNCTION obtener_cliente(
  nro_documento varchar
)
RETURNS TABLE(
  nro BIGINT,
  fecha DATE,
  cantidad DOUBLE PRECISION,
  montototal DOUBLE PRECISION) AS 
$$
  BEGIN
    RETURN QUERY
    SELECT v.nro, v.fecha, v.cantidad, v.montototal
    FROM cliente c
    JOIN venta v ON nrodocumentocli = nrodocumento;
  END;
$$ LANGUAGE plpgsql;

SELECT obtener_cliente('000001');

-- 2.g

-- ALTER TABLE venta ADD COLUMN igv DOUBLE PRECISION;

CREATE OR REPLACE FUNCTION calcular_igv() RETURNS TRIGGER AS $$
    BEGIN
        NEW.igv = NEW.montototal * 0.18;
        RETURN NEW;
    end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calcular_igv_total(montototal DOUBLE PRECISION ) RETURNS DOUBLE PRECISION AS $$
    BEGIN
        RETURN montototal * 0.18;
    end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calcular_igv
AFTER INSERT OR UPDATE OF montototal ON venta
FOR EACH ROW EXECUTE PROCEDURE calcular_igv();

UPDATE venta SET igv = calcular_igv_total(montototal) WHERE igv IS NULL;

-- 2.h

CREATE OR REPLACE FUNCTION calcular_total_venta() RETURNS TRIGGER AS $$
    BEGIN
        NEW.montototal = NEW.cantidad * NEW.preciounitario;
        NEW.igv = NEW.montototal * 0.18;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calcular_monto_igv
BEFORE INSERT OR UPDATE ON venta
FOR EACH ROW EXECUTE PROCEDURE calcular_total_venta();

INSERT INTO venta VALUES (16, '000001', '4214154', 'S001', 'A', (SELECT now()), 10, 30);
INSERT INTO venta VALUES (17, '000001', '4214154', 'S001', 'A', (SELECT now()), 12, 25);

UPDATE venta SET preciounitario = 25 where nro = 17;
