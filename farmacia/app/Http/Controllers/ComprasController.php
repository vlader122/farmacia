<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ComprasController extends Controller
{
    public function index()
    {
        $compras = DB::select('select * from compras');
        return $compras;
    }
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        DB::statement('CALL crear_compra(?,?)',[
            $request->proveedor_id,
            json_encode($request->detalle_compra)
        ]);
        return $request->detalle_compra;
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $compras = DB::select('select * from compras where id = :id', ['id' => $id]);
        return $compras;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        return DB::delete('delete from compras where id = ?', [$id]);
    }
}
