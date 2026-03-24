<?php

namespace App\Http\Controllers\Api;

use App\Models\Language;
use Illuminate\Http\Request;

class LanguageController extends BaseApiController
{
    public function index(Request $request)
    {
        $languages = Language::where('is_active', true)
            ->orderByDesc('is_default')
            ->orderBy('name')
            ->get(['code', 'name', 'native_name', 'direction', 'is_default']);

        return response()->json($languages);
    }
}
