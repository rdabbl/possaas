<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $fixes = [
            ['stores', 'stores_tenant_id_code_unique', ['manager_id', 'code']],
            ['discounts', 'discounts_tenant_id_name_unique', ['manager_id', 'name']],
            ['categories', 'categories_tenant_id_name_unique', ['manager_id', 'name']],
            ['ingredients', 'ingredients_tenant_id_name_unique', ['manager_id', 'name']],
            ['products', 'products_tenant_id_sku_unique', ['manager_id', 'sku']],
            ['products', 'products_tenant_id_barcode_unique', ['manager_id', 'barcode']],
            ['roles', 'roles_tenant_id_name_unique', ['manager_id', 'name']],
            ['ingredient_categories', 'ingredient_categories_tenant_id_name_unique', ['manager_id', 'name']],
            ['payment_methods', 'payment_methods_tenant_id_name_unique', ['manager_id', 'name']],
            ['taxes', 'taxes_tenant_id_name_unique', ['manager_id', 'name']],
            ['product_variants', 'product_variants_tenant_id_sku_unique', ['manager_id', 'sku']],
            ['product_variants', 'product_variants_tenant_id_barcode_unique', ['manager_id', 'barcode']],
        ];

        foreach ($fixes as [$table, $oldIndex, $newColumns]) {
            $this->fixUniqueIndex($table, $oldIndex, $newColumns);
        }
    }

    public function down(): void
    {
        // No-op: we don't restore tenant_id indexes.
    }

    private function fixUniqueIndex(string $table, string $oldIndex, array $newColumns): void
    {
        if (!Schema::hasTable($table)) {
            return;
        }

        if ($this->indexExists($table, $oldIndex)) {
            $hasTenantId = Schema::hasColumn($table, 'tenant_id');
            if ($hasTenantId) {
                Schema::table($table, function (Blueprint $tableBlueprint) {
                    try {
                        $tableBlueprint->dropForeign(['tenant_id']);
                    } catch (\Throwable) {
                        // Ignore if foreign key does not exist.
                    }
                });
            }
            Schema::table($table, function (Blueprint $tableBlueprint) use ($oldIndex) {
                $tableBlueprint->dropUnique($oldIndex);
            });
        }

        $newIndex = $table . '_' . implode('_', $newColumns) . '_unique';
        if (!$this->indexExists($table, $newIndex)) {
            Schema::table($table, function (Blueprint $tableBlueprint) use ($newColumns) {
                $tableBlueprint->unique($newColumns);
            });
        }
    }

    private function indexExists(string $table, string $indexName): bool
    {
        $result = DB::select(
            'SELECT 1 FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = ? AND index_name = ? LIMIT 1',
            [$table, $indexName]
        );
        return !empty($result);
    }
};
