DROP PROCEDURE crear_clientes;
CREATE PROCEDURE crear_clientes(pnombre varchar,pemail varchar,ptelefono varchar,pdireccion varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    IF length(pnombre)>5 THEN
        RAISE EXCEPTION 'La longitud minima es 5 caracteres.';
    END IF;
    
    IF pemail !~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' THEN
        RAISE EXCEPTION 'Email no valido.';
    END IF;
    INSERT INTO clientes (nombre,email,telefono,direccion)
    VALUES (pnombre,pemail,ptelefono,pdireccion);
    RAISE NOTICE 'Insercion Correcta';
END;
$$;

DROP PROCEDURE actualizar_clientes;
CREATE PROCEDURE actualizar_clientes(pid int,pnombre varchar,pemail varchar,ptelefono varchar,pdireccion varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM clientes where id = pid) THEN
        RAISE EXCEPTION 'El cliente no existe.';
    END IF;

    UPDATE clientes
    SET nombre = pnombre, email= pemail, telefono = ptelefono, direccion = pdireccion
    WHERE id = pid;
    RAISE NOTICE 'Actualizacion Correcta';
END;
$$;

DROP PROCEDURE eliminar_clientes;
CREATE PROCEDURE eliminar_clientes(pid int)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM clientes where id = pid) THEN
        RAISE EXCEPTION 'El cliente no existe.';
    END IF;

    DELETE FROM clientes
    WHERE id = pid;
    RAISE NOTICE 'Eliminacion Correcta';
END;
$$;

DROP PROCEDURE llenar_clientes;
CREATE PROCEDURE llenar_clientes(p int)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..p LOOP 
        INSERT INTO clientes (nombre,email,telefono,direccion)
        VALUES ('jjjtest','a@a' || i,'12345678','prueba');
    END LOOP;
    RAISE NOTICE 'Se insertaron % clientes', p;
END;
$$;