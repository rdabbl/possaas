<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Product;
use App\Models\Sale;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $tenantId = $request->user()->tenant_id;

        $stats = [
            'products' => Product::where('tenant_id', $tenantId)->count(),
            'customers' => Customer::where('tenant_id', $tenantId)->count(),
            'sales' => Sale::where('tenant_id', $tenantId)->count(),
        ];

        return view('tenant.dashboard', compact('stats'));
    }
}
