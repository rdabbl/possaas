<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Product;
use App\Models\Sale;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $managerId = $request->user()->manager_id;

        $stats = [
            'products' => Product::where('manager_id', $managerId)->count(),
            'customers' => Customer::where('manager_id', $managerId)->count(),
            'sales' => Sale::where('manager_id', $managerId)->count(),
        ];

        return view('manager.dashboard', compact('stats'));
    }
}
