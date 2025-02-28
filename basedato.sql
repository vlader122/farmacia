drop schema if exists public cascade;
create schema public;
set search_path to public;

create table clientes (
	id SERIAL primary key,
	nombre VARCHAR(150) not null,
	email VARCHAR(150) unique,
	telefono varchar(20),
	direccion text
);

create table categorias(
	id SERIAL primary key,
	nombre varchar(150) not null,
	descripcion text
);

create table proveedores(
	id SERIAL primary key,
	nombre VARCHAR(150) not null,
	contacto varchar(150) not null,
	email VARCHAR(150) unique,
	telefono varchar(20),
	direccion text
);

create table productos(
	id SERIAL primary key,
	nombre varchar(150) not null,
	descripcion text,
	precio decimal(10,2) not null check (precio >=0),
	stock int not null default 0,
	categoria_id int,
	FOREIGN KEY (categoria_id) references categorias(id) on delete set null
);

create table ventas(
	id SERIAL primary key,
	cliente_id int,
	fecha timestamp default current_timestamp,
	total decimal(10,2) not null check (total >=0),
	nro_factura int,
	FOREIGN KEY (cliente_id) references clientes(id) on delete set null
);

create table detalle_ventas(
	id SERIAL primary key,
	venta_id int,
	producto_id int,
	cantidad int not null default 1 check (cantidad >0),
	precio_unitario decimal(10,2) not null check (precio_unitario >=0),
	subtotal decimal(10,2) not null check (subtotal >=0),
	FOREIGN KEY (venta_id) references ventas(id) on delete set null,
	FOREIGN KEY (producto_id) references productos(id) on delete set null
);

create table compras(
	id SERIAL primary key,
	proveedor_id int,
	fecha timestamp default current_timestamp,
	total decimal(10,2) not null check (total >=0),
	FOREIGN KEY (proveedor_id) references proveedores(id) on delete set null
);

create table detalle_compras(
	id SERIAL primary key,
	compra_id int,
	producto_id int,
	cantidad int not null default 1 check (cantidad >0),
	precio_unitario decimal(10,2) not null check (precio_unitario >=0),
	subtotal decimal(10,2) not null check (subtotal >=0),
	FOREIGN KEY (compra_id) references compras(id) on delete set null,
	FOREIGN KEY (producto_id) references productos(id) on delete set null
);

create table inventarios(
	id SERIAL primary key,
	producto_id int not null,
	fecha_vencimiento timestamp default current_timestamp,
	detalle_compra_id int not null unique,
	estado varchar(20),
	cantidad int,
	precio decimal(10,2),
	fecha_compra timestamp default current_timestamp,
	FOREIGN KEY (producto_id) references productos(id) on delete set null
);