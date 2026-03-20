<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use Illuminate\Http\Request;

class SaleController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $sales = Sale::where('tenant_id', $tenantId)
            ->orderBy('id', 'desc')
            ->paginate(20);

        return view('tenant.sales.index', compact('sales'));
    }

    public function show(Request $request, Sale $sale)
    {
        $tenantId = $request->user()->tenant_id;

        if ($sale->tenant_id !== $tenantId) {
            abort(403);
        }

        $sale->load(['items', 'payments.paymentMethod']);

        return view('tenant.sales.show', compact('sale'));
    }
}
