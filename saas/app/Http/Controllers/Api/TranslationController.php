<?php

namespace App\Http\Controllers\Api;

use App\Models\Language;
use App\Services\TranslationService;
use Illuminate\Http\Request;

class TranslationController extends BaseApiController
{
    public function index(Request $request, TranslationService $service)
    {
        $scope = $request->query('scope', 'flutter');
        $lang = $request->query('lang');

        if (!$lang) {
            $language = Language::where('is_default', true)->first();
            $lang = $language?->code ?? config('app.locale');
        }

        $map = $service->getMap($lang, $scope);

        return response()->json([
            'lang' => $lang,
            'scope' => $scope,
            'translations' => $map,
        ]);
    }
}
