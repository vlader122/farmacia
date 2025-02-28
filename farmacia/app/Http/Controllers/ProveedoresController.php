<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProveedoresController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $proveedores = DB::select('select * from proveedores');
        return $proveedores;
    }
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        DB::insert('insert into proveedores (nombre,contacto,email,telefono,direccion)
            values (?, ?, ?, ?, ?)',
            [
                $request->nombre,
                $request->contacto,
                $request->email,
                $request->telefono,
                $request->direccion
            ]
        );
        return $request;
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $proveedores = DB::select('select * from proveedores where id = :id', ['id' => $id]);
        return $proveedores;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $proveedor = DB::select('select * from proveedores where id = :id', ['id' => $id]);
        DB::update('update proveedores set nombre = ?, contacto = ?, email = ?, telefono = ?, direccion = ? WHERE id = ?', [$request->nombre,$request->contacto,$request->email,$request->telefono,$request->direccion,$id]);

        return 'Proveedor actualizado';
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        return DB::delete('delete from proveedores where id = ?', [$id]);
    }
}
