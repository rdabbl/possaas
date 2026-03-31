<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('managers', function (Blueprint $table) {
            $table->boolean('loyalty_enabled')->default(false)->after('plan_id');
            $table->unsignedInteger('loyalty_points_per_order')->default(0)->after('loyalty_enabled');
            $table->unsignedInteger('loyalty_points_per_item')->default(0)->after('loyalty_points_per_order');
            $table->decimal('loyalty_amount_per_point', 12, 2)->default(0)->after('loyalty_points_per_item');
            $table->decimal('loyalty_point_value', 12, 2)->default(0)->after('loyalty_amount_per_point');
        });
    }

    public function down(): void
    {
        Schema::table('managers', function (Blueprint $table) {
            $table->dropColumn([
                'loyalty_enabled',
                'loyalty_points_per_order',
                'loyalty_points_per_item',
                'loyalty_amount_per_point',
                'loyalty_point_value',
            ]);
        });
    }
};
