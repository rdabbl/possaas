<?php

namespace App\Services;

use App\Models\Language;
use App\Models\Translation;
use Illuminate\Support\Facades\Cache;

class TranslationService
{
    public function get(string $key, ?string $locale = null, string $scope = 'saas', ?string $fallback = null): string
    {
        $locale = $locale ?: app()->getLocale();
        $map = $this->getMap($locale, $scope);
        return $map[$key] ?? $fallback ?? $key;
    }

    public function getMap(string $locale, string $scope = 'saas'): array
    {
        $cacheKey = $this->cacheKey($locale, $scope);
        return Cache::remember($cacheKey, 600, function () use ($locale, $scope) {
            $language = Language::where('code', $locale)->first();
            if (!$language) {
                $language = Language::where('is_default', true)->first();
            }
            if (!$language) {
                return [];
            }
            return Translation::where('language_id', $language->id)
                ->where('scope', $scope)
                ->pluck('value', 'key')
                ->toArray();
        });
    }

    public function forget(string $locale, string $scope = 'saas'): void
    {
        Cache::forget($this->cacheKey($locale, $scope));
    }

    private function cacheKey(string $locale, string $scope): string
    {
        return 'translations.' . $locale . '.' . $scope;
    }
}
