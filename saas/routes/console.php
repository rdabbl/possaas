<?php

use App\Models\Language;
use App\Models\Translation;
use App\Services\TranslationService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('translations:sync {--lang= : Language code (default = default language)} {--scope=all : saas|flutter|all} {--dry-run : Show summary without writing} {--fill-empty : Fill empty existing values with the key}', function () {
    $scopeOption = strtolower(trim($this->option('scope') ?? 'all'));
    $validScopes = ['saas', 'flutter', 'all'];
    if (!in_array($scopeOption, $validScopes, true)) {
        $this->error('Invalid scope. Use saas, flutter, or all.');
        return 1;
    }

    $lang = $this->option('lang');
    $languageQuery = Language::query();
    if ($lang) {
        $languageQuery->where('code', strtolower(trim($lang)));
    } else {
        $languageQuery->where('is_default', true);
    }
    $language = $languageQuery->first();
    if (!$language) {
        $this->error('Language not found. Create a language first.');
        return 1;
    }

    $scopes = $scopeOption === 'all' ? ['saas', 'flutter'] : [$scopeOption];
    $repoRoot = dirname(base_path());
    $saasViewsPath = base_path('resources/views');
    $flutterLibPath = $repoRoot . '/pos/lib';

    $extractKeys = function (string $path, string $pattern, string $extension) {
        $keys = [];
        if (!is_dir($path)) {
            return $keys;
        }
        $iterator = new \RecursiveIteratorIterator(
            new \RecursiveDirectoryIterator($path, \FilesystemIterator::SKIP_DOTS)
        );
        foreach ($iterator as $file) {
            if (!$file->isFile()) {
                continue;
            }
            if (!Str::endsWith($file->getFilename(), $extension)) {
                continue;
            }
            $content = file_get_contents($file->getPathname());
            if ($content === false) {
                continue;
            }
            if (preg_match_all($pattern, $content, $matches)) {
                foreach ($matches[2] as $raw) {
                    $key = stripcslashes($raw);
                    if (trim($key) === '') {
                        continue;
                    }
                    $keys[$key] = true;
                }
            }
        }
        return array_keys($keys);
    };

    $keysByScope = [];
    if (in_array('saas', $scopes, true)) {
        $keysByScope['saas'] = $extractKeys(
            $saasViewsPath,
            '/\bt\(\s*([\'"])((?:\\\\.|(?!\1).)*)\1/s',
            '.blade.php'
        );
    }
    if (in_array('flutter', $scopes, true)) {
        $keysByScope['flutter'] = $extractKeys(
            $flutterLibPath,
            '/\btr\(\s*([\'"])((?:\\\\.|(?!\1).)*)\1/s',
            '.dart'
        );
    }

    $dryRun = (bool) $this->option('dry-run');
    $fillEmpty = (bool) $this->option('fill-empty');

    foreach ($keysByScope as $scope => $keys) {
        $keys = array_values(array_unique($keys));
        sort($keys);

        $existing = Translation::where('language_id', $language->id)
            ->where('scope', $scope)
            ->pluck('id', 'key')
            ->toArray();

        $missing = array_values(array_diff($keys, array_keys($existing)));
        $this->info(sprintf(
            '[%s] %d keys found, %d missing',
            $scope,
            count($keys),
            count($missing)
        ));

        if ($dryRun) {
            if (!empty($missing)) {
                $this->line('Missing sample: ' . implode(', ', array_slice($missing, 0, 10)));
            }
            continue;
        }

        $now = now();
        $insertRows = [];
        foreach ($missing as $key) {
            $insertRows[] = [
                'language_id' => $language->id,
                'scope' => $scope,
                'key' => $key,
                'value' => $key,
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }
        if (!empty($insertRows)) {
            foreach (array_chunk($insertRows, 500) as $chunk) {
                Translation::insert($chunk);
            }
        }

        if ($fillEmpty) {
            Translation::where('language_id', $language->id)
                ->where('scope', $scope)
                ->whereIn('key', $keys)
                ->where(function ($q) {
                    $q->whereNull('value')->orWhere('value', '');
                })
                ->update([
                    'value' => DB::raw('`key`'),
                    'updated_at' => $now,
                ]);
        }

        app(TranslationService::class)->forget($language->code, $scope);
    }

    $this->info('Translation sync completed.');
    return 0;
})->purpose('Sync translation keys from t()/tr() into the database');
