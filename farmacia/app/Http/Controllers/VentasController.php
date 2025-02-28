<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class VentasController extends Controller
{
    public function index()
    {
        $ventas = DB::select('select * from ventas');
        return $ventas;
    }
    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        DB::statement('CALL crear_venta(?,?,?)',[
            $request->cliente_id,
            $request->nro_factura,
            json_encode($request->detalle_venta)
        ]);
        return $request->detalle_venta;
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $ventas = DB::select('select * from ventas where id = :id', ['id' => $id]);
        return $ventas;
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        return DB::delete('delete from ventas where id = ?', [$id]);
    }
}
