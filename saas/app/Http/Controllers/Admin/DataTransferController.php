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

    public function index()
    {
        $tables = $this->availableTables();

        return view('admin.data_transfer.index', [
            'tables' => $tables,
            'tableCount' => count($tables),
        ]);
    }

    public function export()
    {
        $tables = $this->availableTables();

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
        $validated = $request->validate([
            'snapshot' => ['required', 'file', 'mimes:json,txt', 'max:102400'],
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

        $tables = $this->availableTables();

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
            ->with('success', 'JSON import completed successfully.');
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
}
