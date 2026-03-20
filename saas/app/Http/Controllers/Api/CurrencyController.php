<?php

namespace App\Http\Controllers\Api;

use App\Models\Currency;
use Illuminate\Http\Request;

class CurrencyController extends BaseApiController
{
    public function index(Request $request)
    {
        $currencies = Currency::where('is_active', true)
            ->orderBy('name')
            ->get();

        return response()->json($currencies);
    }
}
