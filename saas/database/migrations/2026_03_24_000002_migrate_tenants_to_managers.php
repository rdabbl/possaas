<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Copy tenants into managers if managers table exists and tenants has data.
        if (Schema::hasTable('tenants') && Schema::hasTable('managers')) {
            DB::statement(<<<'SQL'
                INSERT INTO managers (
                    id, name, slug, is_active, max_stores, max_devices,
                    currency, timezone, plan_name, plan_id,
                    created_at, updated_at, deleted_at
                )
                SELECT
                    t.id, t.name, t.slug, t.is_active, t.max_stores, t.max_devices,
                    t.currency, t.timezone, t.plan_name, t.plan_id,
                    t.created_at, t.updated_at, t.deleted_at
                FROM tenants t
                WHERE NOT EXISTS (
                    SELECT 1 FROM managers m WHERE m.id = t.id
                )
            SQL);
        }

        $tables = [
            'categories',
            'customers',
            'devices',
            'discounts',
            'ingredient_categories',
            'ingredients',
            'product_variants',
            'products',
            'roles',
            'sales',
            'stock_movements',
            'stores',
            'taxes',
            'users',
        ];

        foreach ($tables as $table) {
            $this->addManagerIdColumn($table);

            if (Schema::hasColumn($table, 'manager_id') && Schema::hasColumn($table, 'tenant_id')) {
                DB::statement(sprintf(
                    'UPDATE `%s` SET manager_id = tenant_id WHERE manager_id IS NULL',
                    $table
                ));
            }
        }

        // Payment methods are global now: keep manager_id NULL.
        $this->addManagerIdColumn('payment_methods');
        if (Schema::hasColumn('payment_methods', 'manager_id')) {
            DB::statement('UPDATE `payment_methods` SET manager_id = NULL WHERE manager_id IS NOT NULL');
        }
    }

    public function down(): void
    {
        // Intentionally no-op to avoid data loss.
    }

    private function addManagerIdColumn(string $table): void
    {
        if (!Schema::hasTable($table) || Schema::hasColumn($table, 'manager_id')) {
            return;
        }

        $after = Schema::hasColumn($table, 'tenant_id') ? 'tenant_id' : 'id';

        Schema::table($table, function (Blueprint $tableBlueprint) use ($after) {
            $tableBlueprint->foreignId('manager_id')
                ->nullable()
                ->constrained('managers')
                ->nullOnDelete()
                ->after($after);
        });
    }
};
