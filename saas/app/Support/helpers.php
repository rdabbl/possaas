<?php

use App\Services\TranslationService;

if (!function_exists('t')) {
    function t(string $key, ?string $fallback = null, string $scope = 'saas'): string
    {
        /** @var TranslationService $service */
        $service = app(TranslationService::class);
        return $service->get($key, null, $scope, $fallback);
    }
}
