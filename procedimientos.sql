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
        insert into ventas (cliente_id,fecha,total,nro_factura)
    END LOOP;
    RAISE NOTICE 'Se insertaron % clientes', p;
END;
$$;

DROP PROCEDURE crear_venta;
CREATE PROCEDURE crear_venta(pcliente_id varchar,pnro_factura varchar,detalle_venta jsonb)
LANGUAGE plpgsql
AS $$
DECLARE
    dtotal DECIMAL(10,2);
    nueva_venta_id INT;
BEGIN
    FOR detalle_venta IN SELECT * FROM jsonb_array_elements(detalle_venta) LOOP
        dtotal = dtotal + detalle_venta->>'cantidad' * detalle_venta->>'precio'
    END LOOP;

    insert into ventas (cliente_id,fecha,total,nro_factura)
    VALUES (pcliente_id, NOW(), dtotal ,pnro_factura)
    RETURNING id INTO nueva_venta_id;

    FOR detalle_venta IN SELECT * FROM jsonb_array_elements(detalle_venta) LOOP
        insert into detalle_ventas (venta_id,producto_id,cantidad,precio_unitario,subtotal)
        VALUES (nueva_venta_id, detalle_venta->>'producto_id', detalle_venta->>'cantidad', detalle_venta->>'precio_unitario', detalle_venta->>'cantidad' * detalle_venta->>'precio_unitario');
    END LOOP;
END;
$$;

DROP PROCEDURE crear_venta;
CREATE PROCEDURE crear_venta(pcliente_id INT, pnro_factura INT,detalle_venta jsonb)
LANGUAGE plpgsql
AS $$
DECLARE
    dtotal DECIMAL(10,2) := 0;
    nueva_venta_id INT;
    detalle JSONB;
    lotes RECORD;
    cantidad_descontar INT;
    cantidad_vendida INT;
BEGIN
    -- Sumar los totales de la venta
    FOR detalle IN SELECT * FROM jsonb_array_elements(detalle_venta) LOOP
        dtotal := dtotal + ((detalle->>'cantidad')::INT * (detalle->>'precio_unitario')::DECIMAL);
        IF EXISTS (
            SELECT 1
            FROM productos
            WHERE id = (detalle->>'producto_id')::INT AND (stock - (detalle->>'cantidad')::INT) < 0
        ) THEN
            RAISE EXCEPTION 'Stock insuficiente para uno o más productos.';
        END IF;

    END LOOP;

    -- Insertar en la tabla ventas
    INSERT INTO ventas (cliente_id, fecha, total, nro_factura)
    VALUES (pcliente_id, NOW(), dtotal, pnro_factura)
    RETURNING id INTO nueva_venta_id;

    -- Insertar en la tabla detalle_ventas
    FOR detalle IN SELECT * FROM jsonb_array_elements(detalle_venta) LOOP
        INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
        VALUES (nueva_venta_id, (detalle->>'producto_id')::INT, (detalle->>'cantidad')::INT, 
                (detalle->>'precio_unitario')::DECIMAL, 
                (detalle->>'cantidad')::INT * (detalle->>'precio_unitario')::DECIMAL);

        UPDATE productos
        SET stock = stock - COALESCE((detalle->>'cantidad')::INT, 0)
        WHERE id = (detalle->>'producto_id')::INT;

        cantidad_vendida = (detalle->>'cantidad')::INT;
        FOR lote IN
            SELECT id, cantidad
            FROM inventarios
            WHERE producto_id = (detalle->>'producto_id')::INT
            ORDER BY fecha_compra ASC
        LOOP
            cantidad_descontar := LEAST(lote.cantidad, cantidad_vendida);

            UPDATE inventarios
            SET cantidad = cantidad - cantidad_descontar
            WHERE id = lote.id;

            cantidad_vendida := cantidad_vendida - cantidad_descontar;

            EXIT WHEN cantidad_vendida = 0;
        END LOOP
    END LOOP;
END;
$$;

call crear_venta(35,1,'[{"producto_id":1,"cantidad":2,"precio_unitario":10},{"producto_id":2,"cantidad":2,"precio_unitario":52}]'::jsonb)

DROP PROCEDURE crear_compra;
CREATE PROCEDURE crear_compra(pproveedor INT, detalle_compra jsonb)
LANGUAGE plpgsql
AS $$
DECLARE
    dtotal DECIMAL(10,2) := 0;
    nueva_compra_id INT;
    detalle JSONB;
    new_detalle_compra_id INT;
BEGIN
    -- Sumar los totales de la compra
    FOR detalle IN SELECT * FROM jsonb_array_elements(detalle_compra) LOOP
        dtotal := dtotal + ((detalle->>'cantidad')::INT * (detalle->>'precio_unitario')::DECIMAL);
    END LOOP;

    -- Insertar en la tabla compras
    INSERT INTO compras (proveedor_id, fecha, total)
    VALUES (pproveedor, NOW(), dtotal)
    RETURNING id INTO nueva_compra_id;

    -- Insertar en la tabla detalle_compras
    FOR detalle IN SELECT * FROM jsonb_array_elements(detalle_compra) LOOP
        INSERT INTO detalle_compras (compra_id, producto_id, cantidad, precio_unitario, subtotal)
        VALUES (nueva_compra_id, (detalle->>'producto_id')::INT, (detalle->>'cantidad')::INT, 
                (detalle->>'precio_unitario')::DECIMAL, 
                (detalle->>'cantidad')::INT * (detalle->>'precio_unitario')::DECIMAL)
        RETURNING id INTO new_detalle_compra_id;
        UPDATE productos
        SET stock = stock + COALESCE((detalle->>'cantidad')::INT, 0), precio = (detalle->>'precio_unitario')::DECIMAL + ((detalle->>'precio_unitario')::DECIMAL * 0.10)
        WHERE id = (detalle->>'producto_id')::INT;

        IF EXISTS (
            SELECT 1
            FROM inventarios
            WHERE estado = 'ACTIVO' and producto_id = (detalle->>'producto_id')::INT
        ) THEN
            INSERT INTO inventarios (producto_id, fecha_vencimiento, detalle_compra_id, estado, cantidad, precio)
            VALUES ((detalle->>'producto_id')::INT, TO_DATE(detalle->>'fecha_vencimiento', 'DD-MM-YYYY'), new_detalle_compra_id, 'LISTO PARA VENTA', (detalle->>'cantidad')::INT, (detalle->>'precio_unitario')::DECIMAL);
        ELSE
            INSERT INTO inventarios (producto_id, fecha_vencimiento, detalle_compra_id, estado, cantidad, precio)
            VALUES ((detalle->>'producto_id')::INT, TO_DATE(detalle->>'fecha_vencimiento', 'DD-MM-YYYY'), new_detalle_compra_id, 'ACTIVO', (detalle->>'cantidad')::INT, (detalle->>'precio_unitario')::DECIMAL);
        END IF;
    END LOOP;
END;
$$;

ALTER TABLE productos
ADD CONSTRAINT check_cantidad_positive CHECK (cantidad >= 0);

CREATE FUNCTION actualizar_estado_inventarios(id) return varchar
    BEGIN
        
        RETURN 'hola mundo';
    END;
$$ LANGUAGE plpgsql;