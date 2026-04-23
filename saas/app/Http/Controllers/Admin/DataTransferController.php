<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use JsonException;

class DataTransferController extends Controller
{
    /**
     * Ordered by dependencies for safe insert during import.
     */
    private const SNAPSHOT_TABLES = [
        'plans',
        'currencies',
        'languages',
        'managers',
        'stores',
        'users',
        'roles',
        'permissions',
        'role_user',
        'permission_role',
        'subscriptions',
        'devices',
        'categories',
        'product_option_categories',
        'product_options',
        'products',
        'product_variants',
        'product_option_product',
        'customers',
        'payment_methods',
        'taxes',
        'discounts',
        'shipping_methods',
        'printing_services',
        'translations',
        'sales',
        'sale_items',
        'payments',
        'stock_movements',
    ];

    /**
     * Table dependencies: selecting a child table also requires these parent tables.
     *
     * @var array<string, array<int, string>>
     */
    private const TABLE_DEPENDENCIES = [
        'managers' => ['plans'],
        'stores' => ['managers', 'currencies'],
        'users' => ['managers', 'stores'],
        'roles' => ['managers'],
        'role_user' => ['roles', 'users'],
        'permission_role' => ['permissions', 'roles'],
        'subscriptions' => ['managers', 'plans'],
        'devices' => ['managers', 'stores'],
        'categories' => ['managers'],
        'product_option_categories' => ['managers'],
        'product_options' => ['managers', 'product_option_categories'],
        'products' => ['managers', 'categories', 'taxes'],
        'product_variants' => ['managers', 'products'],
        'product_option_product' => ['product_options', 'products'],
        'customers' => ['managers'],
        'payment_methods' => ['managers'],
        'taxes' => ['managers'],
        'discounts' => ['managers'],
        'shipping_methods' => ['managers'],
        'printing_services' => ['managers', 'stores'],
        'translations' => ['languages'],
        'sales' => ['managers', 'stores', 'devices', 'users', 'customers'],
        'sale_items' => ['sales', 'products', 'product_variants'],
        'payments' => ['sales', 'payment_methods'],
        'stock_movements' => ['managers', 'products', 'stores', 'users'],
    ];

    public function index()
    {
        $tables = $this->availableTables();
        $dependencies = $this->availableDependencies($tables);

        return view('admin.data_transfer.index', [
            'tables' => $tables,
            'tableCount' => count($tables),
            'dependencies' => $dependencies,
        ]);
    }

    public function export()
    {
        $available = $this->availableTables();
        $tables = $this->resolveSelectedTables(request()->input('tables'), $available);
        if (empty($tables)) {
            $tables = $available;
        }

        $payload = [
            'meta' => [
                'schema_version' => 1,
                'exported_at' => now()->toIso8601String(),
                'app' => config('app.name', 'POS SaaS'),
                'tables' => $tables,
            ],
            'data' => [],
        ];

        foreach ($tables as $table) {
            $query = DB::table($table);
            if (Schema::hasColumn($table, 'id')) {
                $query->orderBy('id');
            }

            $payload['data'][$table] = $query->get()
                ->map(static fn ($row) => (array) $row)
                ->all();
        }

        $filename = 'saas-admin-export-' . now()->format('Ymd-His') . '.json';
        $json = json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);

        return response()->streamDownload(
            static function () use ($json): void {
                echo $json ?: '{}';
            },
            $filename,
            ['Content-Type' => 'application/json; charset=utf-8']
        );
    }

    public function import(Request $request)
    {
        $available = $this->availableTables();

        $validated = $request->validate([
            'snapshot' => ['required', 'file', 'mimes:json,txt', 'max:102400'],
            'selected_tables' => ['required', 'array', 'min:1'],
            'selected_tables.*' => ['string'],
        ]);

        $raw = file_get_contents($validated['snapshot']->getRealPath());
        if ($raw === false) {
            return back()->withErrors(['snapshot' => 'Unable to read uploaded file.']);
        }

        try {
            $decoded = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException $e) {
            return back()->withErrors(['snapshot' => 'Invalid JSON file: ' . $e->getMessage()]);
        }

        if (!is_array($decoded)) {
            return back()->withErrors(['snapshot' => 'Invalid snapshot format.']);
        }

        $data = $decoded['data'] ?? $decoded;
        if (!is_array($data)) {
            return back()->withErrors(['snapshot' => 'Snapshot data section is missing or invalid.']);
        }

        $tables = $this->resolveSelectedTables($validated['selected_tables'], $available);
        if (empty($tables)) {
            return back()->withErrors(['selected_tables' => 'No valid tables selected for import.']);
        }

        DB::transaction(function () use ($tables, $data): void {
            Schema::disableForeignKeyConstraints();

            try {
                // Truncate in reverse dependency order.
                foreach (array_reverse($tables) as $table) {
                    DB::table($table)->truncate();
                }

                foreach ($tables as $table) {
                    $rows = $data[$table] ?? [];
                    if (!is_array($rows) || empty($rows)) {
                        continue;
                    }

                    $normalized = [];
                    foreach ($rows as $row) {
                        if (!is_array($row)) {
                            continue;
                        }
                        $normalized[] = $this->normalizeRow($row);
                    }

                    if (empty($normalized)) {
                        continue;
                    }

                    foreach (array_chunk($normalized, 300) as $chunk) {
                        DB::table($table)->insert($chunk);
                    }
                }
            } finally {
                Schema::enableForeignKeyConstraints();
            }
        });

        return redirect()->route('admin.data_transfer.index')
            ->with('success', 'JSON import completed successfully for ' . count($tables) . ' table(s).');
    }

    /**
     * @return array<int, string>
     */
    private function availableTables(): array
    {
        return array_values(array_filter(
            self::SNAPSHOT_TABLES,
            static fn (string $table): bool => Schema::hasTable($table)
        ));
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, mixed>
     */
    private function normalizeRow(array $row): array
    {
        foreach ($row as $key => $value) {
            if (is_array($value) || is_object($value)) {
                $row[$key] = json_encode($value, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            }
        }

        return $row;
    }

    /**
     * @param array<int, string> $available
     * @return array<string, array<int, string>>
     */
    private function availableDependencies(array $available): array
    {
        $map = array_flip($available);
        $result = [];
        foreach (self::TABLE_DEPENDENCIES as $table => $deps) {
            if (!isset($map[$table])) {
                continue;
            }

            $filtered = array_values(array_filter(
                $deps,
                static fn (string $dep): bool => isset($map[$dep])
            ));
            if (!empty($filtered)) {
                $result[$table] = $filtered;
            }
        }

        return $result;
    }

    /**
     * @param mixed $selected
     * @param array<int, string> $available
     * @return array<int, string>
     */
    private function resolveSelectedTables(mixed $selected, array $available): array
    {
        if (!is_array($selected)) {
            return [];
        }

        $map = array_flip($available);
        $selectedSet = [];
        foreach ($selected as $table) {
            if (!is_string($table)) {
                continue;
            }
            if (!isset($map[$table])) {
                continue;
            }
            $selectedSet[$table] = true;
            $this->expandDependencies($table, $selectedSet, $map);
        }

        // Preserve canonical order for FK-safe truncate/insert.
        return array_values(array_filter(
            $available,
            static fn (string $table): bool => isset($selectedSet[$table])
        ));
    }

    /**
     * @param array<string, bool> $selectedSet
     * @param array<string, int> $availableMap
     */
    private function expandDependencies(string $table, array &$selectedSet, array $availableMap): void
    {
        $deps = self::TABLE_DEPENDENCIES[$table] ?? [];
        foreach ($deps as $dep) {
            if (!isset($availableMap[$dep]) || isset($selectedSet[$dep])) {
                continue;
            }
            $selectedSet[$dep] = true;
            $this->expandDependencies($dep, $selectedSet, $availableMap);
        }
    }
}
