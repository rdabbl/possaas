<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('customers', function (Blueprint $table) {
            $table->unsignedInteger('loyalty_points_balance')->default(0)->after('note');
            $table->unsignedInteger('loyalty_points_earned_total')->default(0)->after('loyalty_points_balance');
            $table->unsignedInteger('loyalty_points_redeemed_total')->default(0)->after('loyalty_points_earned_total');
        });
    }

    public function down(): void
    {
        Schema::table('customers', function (Blueprint $table) {
            $table->dropColumn([
                'loyalty_points_balance',
                'loyalty_points_earned_total',
                'loyalty_points_redeemed_total',
            ]);
        });
    }
};
