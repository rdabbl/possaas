<?php

namespace App\Http\Controllers\Manager;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Models\ProductOption;
use App\Models\ProductOptionCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use JsonException;

class CatalogTransferController extends Controller
{
    public function index()
    {
        return view('manager.catalog_transfer.index');
    }

    public function export(Request $request)
    {
        $managerId = (int) $request->user()->manager_id;

        $optionCategoryRows = ProductOptionCategory::query()
            ->where('manager_id', $managerId)
            ->orderBy('id')
            ->get()
            ->map(static fn ($row) => $row->getAttributes())
            ->all();
        $optionCategoryIds = array_column($optionCategoryRows, 'id');

        $categoryRows = Category::query()
            ->where('manager_id', $managerId)
            ->orderBy('id')
            ->get()
            ->map(static fn ($row) => $row->getAttributes())
            ->all();

        $optionRows = ProductOption::query()
            ->where('manager_id', $managerId)
            ->orderBy('id')
            ->get()
            ->map(static fn ($row) => $row->getAttributes())
            ->all();
        $optionIds = array_column($optionRows, 'id');

        $productRows = Product::query()
            ->where('manager_id', $managerId)
            ->orderBy('id')
            ->get()
            ->map(static fn ($row) => $row->getAttributes())
            ->all();
        $productIds = array_column($productRows, 'id');

        $variantRows = DB::table('product_variants')
            ->where('manager_id', $managerId)
            ->orderBy('id')
            ->get()
            ->map(static fn ($row) => (array) $row)
            ->all();

        $pivotRows = [];
        if (!empty($productIds) && !empty($optionIds)) {
            $pivotRows = DB::table('product_option_product')
                ->whereIn('product_id', $productIds)
                ->whereIn('product_option_id', $optionIds)
                ->orderBy('id')
                ->get()
                ->map(static fn ($row) => (array) $row)
                ->all();
        }

        $payload = [
            'meta' => [
                'schema_version' => 1,
                'type' => 'manager_catalog',
                'manager_id' => $managerId,
                'exported_at' => now()->toIso8601String(),
            ],
            'data' => [
                'product_option_categories' => $optionCategoryRows,
                'categories' => $categoryRows,
                'product_options' => $optionRows,
                'products' => $productRows,
                'product_variants' => $variantRows,
                'product_option_product' => $pivotRows,
            ],
            'counts' => [
                'product_option_categories' => count($optionCategoryIds),
                'categories' => count($categoryRows),
                'product_options' => count($optionRows),
                'products' => count($productRows),
                'product_variants' => count($variantRows),
                'product_option_product' => count($pivotRows),
            ],
        ];

        $json = json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $filename = 'manager-catalog-' . $managerId . '-' . now()->format('Ymd-His') . '.json';

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
        $managerId = (int) $request->user()->manager_id;

        $validated = $request->validate([
            'snapshot' => ['required', 'file', 'mimes:json,txt', 'max:51200'],
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

        $optionCategoryRows = $this->asRows($data['product_option_categories'] ?? []);
        $categoryRows = $this->asRows($data['categories'] ?? []);
        $optionRows = $this->asRows($data['product_options'] ?? []);
        $productRows = $this->asRows($data['products'] ?? []);
        $variantRows = $this->asRows($data['product_variants'] ?? []);
        $pivotRows = $this->asRows($data['product_option_product'] ?? []);

        DB::transaction(function () use (
            $managerId,
            $optionCategoryRows,
            $categoryRows,
            $optionRows,
            $productRows,
            $variantRows,
            $pivotRows
        ): void {
            $existingProductIds = DB::table('products')->where('manager_id', $managerId)->pluck('id')->all();
            $existingOptionIds = DB::table('product_options')->where('manager_id', $managerId)->pluck('id')->all();

            if (!empty($existingProductIds) || !empty($existingOptionIds)) {
                DB::table('product_option_product')
                    ->when(!empty($existingProductIds), fn ($q) => $q->orWhereIn('product_id', $existingProductIds))
                    ->when(!empty($existingOptionIds), fn ($q) => $q->orWhereIn('product_option_id', $existingOptionIds))
                    ->delete();
            }

            DB::table('product_variants')->where('manager_id', $managerId)->delete();
            DB::table('products')->where('manager_id', $managerId)->delete();
            DB::table('product_options')->where('manager_id', $managerId)->delete();
            DB::table('categories')->where('manager_id', $managerId)->delete();
            DB::table('product_option_categories')->where('manager_id', $managerId)->delete();

            $categoryMap = [];
            $optionCategoryMap = [];
            $optionMap = [];
            $productMap = [];

            foreach ($optionCategoryRows as $row) {
                $oldId = (int) ($row['id'] ?? 0);
                unset($row['id']);
                $row['manager_id'] = $managerId;
                $newId = ProductOptionCategory::query()->insertGetId($this->normalizeRow($row));
                if ($oldId > 0) {
                    $optionCategoryMap[$oldId] = $newId;
                }
            }

            $pendingCategoryParents = [];
            foreach ($categoryRows as $row) {
                $oldId = (int) ($row['id'] ?? 0);
                $oldParentId = (int) ($row['parent_id'] ?? 0);
                unset($row['id']);
                $row['manager_id'] = $managerId;
                $row['parent_id'] = null;
                $newId = Category::query()->insertGetId($this->normalizeRow($row));
                if ($oldId > 0) {
                    $categoryMap[$oldId] = $newId;
                    if ($oldParentId > 0) {
                        $pendingCategoryParents[] = ['new_id' => $newId, 'old_parent_id' => $oldParentId];
                    }
                }
            }

            foreach ($pendingCategoryParents as $pending) {
                $newParentId = $categoryMap[$pending['old_parent_id']] ?? null;
                if ($newParentId) {
                    Category::query()->whereKey($pending['new_id'])->update(['parent_id' => $newParentId]);
                }
            }

            foreach ($optionRows as $row) {
                $oldId = (int) ($row['id'] ?? 0);
                $oldCategoryId = (int) ($row['product_option_category_id'] ?? 0);
                unset($row['id']);
                $row['manager_id'] = $managerId;
                $row['product_option_category_id'] = $optionCategoryMap[$oldCategoryId] ?? null;
                $newId = ProductOption::query()->insertGetId($this->normalizeRow($row));
                if ($oldId > 0) {
                    $optionMap[$oldId] = $newId;
                }
            }

            foreach ($productRows as $row) {
                $oldId = (int) ($row['id'] ?? 0);
                $oldCategoryId = (int) ($row['category_id'] ?? 0);
                unset($row['id']);
                $row['manager_id'] = $managerId;
                $row['category_id'] = $categoryMap[$oldCategoryId] ?? null;
                $newId = Product::query()->insertGetId($this->normalizeRow($row));
                if ($oldId > 0) {
                    $productMap[$oldId] = $newId;
                }
            }

            $variantInserts = [];
            foreach ($variantRows as $row) {
                $oldProductId = (int) ($row['product_id'] ?? 0);
                $newProductId = $productMap[$oldProductId] ?? null;
                if (!$newProductId) {
                    continue;
                }
                unset($row['id']);
                $row['manager_id'] = $managerId;
                $row['product_id'] = $newProductId;
                $variantInserts[] = $this->normalizeRow($row);
            }

            if (!empty($variantInserts)) {
                foreach (array_chunk($variantInserts, 300) as $chunk) {
                    DB::table('product_variants')->insert($chunk);
                }
            }

            $inserts = [];
            foreach ($pivotRows as $row) {
                $oldOptionId = (int) ($row['product_option_id'] ?? 0);
                $oldProductId = (int) ($row['product_id'] ?? 0);
                $newOptionId = $optionMap[$oldOptionId] ?? null;
                $newProductId = $productMap[$oldProductId] ?? null;
                if (!$newOptionId || !$newProductId) {
                    continue;
                }

                $inserts[] = [
                    'product_option_id' => $newOptionId,
                    'product_id' => $newProductId,
                    'quantity' => $row['quantity'] ?? 1,
                    'created_at' => $row['created_at'] ?? now(),
                    'updated_at' => $row['updated_at'] ?? now(),
                ];
            }

            if (!empty($inserts)) {
                foreach (array_chunk($inserts, 300) as $chunk) {
                    DB::table('product_option_product')->insert($chunk);
                }
            }
        });

        return redirect()->route('manager.catalog_transfer.index')
            ->with('success', 'Catalog import completed successfully.');
    }

    /**
     * @param mixed $input
     * @return array<int, array<string, mixed>>
     */
    private function asRows(mixed $input): array
    {
        if (!is_array($input)) {
            return [];
        }

        $rows = [];
        foreach ($input as $row) {
            if (!is_array($row)) {
                continue;
            }
            $rows[] = $row;
        }

        return $rows;
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
