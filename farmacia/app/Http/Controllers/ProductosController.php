<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProductosController extends Controller
{
    public function index()
    {
        $productos = DB::select('select * from productos');
        return $productos;
    }
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        DB::insert('insert into productos (nombre,descripcion,precio,stock,categoria_id)
            values (?, ?, ?, ?, ?)',
            [
                $request->nombre,
                $request->descripcion,
                $request->precio,
                $request->stock,
                $request->categoria_id
            ]
        );
        return $request;
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $productos = DB::select('select * from productos where id = :id', ['id' => $id]);
        return $productos;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $producto = DB::select('select * from productos where id = :id', ['id' => $id]);
        DB::update('update productos set nombre = ?, descripcion = ?, precio = ?, stock = ? WHERE id = ?',
            [
                $request->nombre,
                $request->descripcion,
                $request->precio,
                $request->stock,
                $id
            ]);

        return 'producto actualizado';
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        return DB::delete('delete from productos where id = ?', [$id]);
    }
}
