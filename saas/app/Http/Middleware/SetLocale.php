<?php

namespace App\Http\Middleware;

use App\Models\Language;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SetLocale
{
    public function handle(Request $request, Closure $next): Response
    {
        $locale = $request->query('lang')
            ?? $request->header('X-Lang')
            ?? $request->session()->get('lang');

        if (!$locale) {
            $default = Language::where('is_default', true)->first();
            $locale = $default?->code ?? config('app.locale');
        }

        if ($locale) {
            app()->setLocale($locale);
            $request->session()->put('lang', $locale);
        }

        return $next($request);
    }
}
