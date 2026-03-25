<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
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
            if (!Schema::hasTable($table) || !Schema::hasColumn($table, 'tenant_id')) {
                continue;
            }

            Schema::table($table, function (Blueprint $tableBlueprint) {
                try {
                    $tableBlueprint->dropForeign(['tenant_id']);
                } catch (\Throwable) {
                    // Ignore if the foreign key does not exist.
                }
                $tableBlueprint->dropColumn('tenant_id');
            });
        }
    }

    public function down(): void
    {
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
            if (!Schema::hasTable($table) || Schema::hasColumn($table, 'tenant_id')) {
                continue;
            }

            Schema::table($table, function (Blueprint $tableBlueprint) {
                $tableBlueprint->unsignedBigInteger('tenant_id')->nullable()->after('manager_id');
            });
        }
    }
};
