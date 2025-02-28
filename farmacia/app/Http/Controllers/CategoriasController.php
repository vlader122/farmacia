<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CategoriasController extends Controller
{
        /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $categorias = DB::select('select * from categorias');
        return $categorias;
    }
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        DB::insert('insert into categorias (nombre,descripcion)
            values (?, ?)',
            [
                $request->nombre,
                $request->descripcion,
            ]
        );
        return $request;
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $categorias = DB::select('select * from categorias where id = :id', ['id' => $id]);
        return $categorias;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $proveedor = DB::select('select * from categorias where id = :id', ['id' => $id]);
        DB::update('update categorias set nombre = ?, descripcion = ? WHERE id = ?', [$request->nombre,$request->descripcion,$id]);

        return 'Proveedor actualizado';
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        return DB::delete('delete from categorias where id = ?', [$id]);
    }
}
