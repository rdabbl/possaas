<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use Illuminate\Http\Request;

class SaleController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $sales = Sale::where('manager_id', $managerId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('manager.sales.index', compact('sales'));
    }

    public function show(Request $request, Sale $sale)
    {
        $managerId = $request->user()->manager_id;

        if ($sale->manager_id !== $managerId) {
            abort(403);
        }

        $sale->load(['items', 'payments.paymentMethod']);

        return view('manager.sales.show', compact('sale'));
    }
}
