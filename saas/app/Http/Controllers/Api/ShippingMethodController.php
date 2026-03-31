<?php

namespace App\Http\Controllers\Api;

use App\Models\ShippingMethod;
use Illuminate\Http\Request;

class ShippingMethodController extends BaseApiController
{
    public function index(Request $request)
    {
        $manager = $this->managerOrFail($request);

        $methods = ShippingMethod::where('manager_id', $manager->id)
            ->where('is_active', true)
            ->orderBy('id', 'desc')
            ->get();

        return response()->json($methods);
    }
}
