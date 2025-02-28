<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ClientesController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $clientes = DB::select('select * from clientes');
        return $clientes;
    }
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        DB::insert('insert into clientes (nombre,email,telefono,direccion) values (?, ?, ?, ?)', [$request->nombre,$request->email,$request->telefono,$request->direccion]);
        return $request;
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $clientes = DB::select('select * from clientes where id = :id', ['id' => $id]);
        return $clientes;
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $cliente = DB::select('select * from clientes where id = :id', ['id' => $id]);
        DB::update('update clientes set nombre = ?, email = ?, telefono = ?, direccion = ? WHERE id = ?', [$request->nombre,$request->email,$request->telefono,$request->direccion,$id]);

        return 'Cliente actualizado';
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        return DB::delete('delete from clientes where id = ?', [$id]);
    }
}
