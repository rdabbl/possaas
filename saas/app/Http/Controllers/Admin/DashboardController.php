<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Device;
use App\Models\Product;
use App\Models\Sale;
use App\Models\Store;
use App\Models\Tenant;
use App\Models\User;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $stats = [
            'tenants' => Tenant::count(),
            'stores' => Store::count(),
            'devices' => Device::count(),
            'users' => User::count(),
            'products' => Product::count(),
            'sales' => Sale::count(),
        ];

        return view('admin.dashboard', compact('stats'));
    }
}
