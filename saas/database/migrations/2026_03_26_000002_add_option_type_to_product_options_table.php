<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_options', function (Blueprint $table) {
            if (!Schema::hasColumn('product_options', 'option_type')) {
                $table->string('option_type', 20)->default('boolean')->after('name');
            }
            if (!Schema::hasColumn('product_options', 'step_action')) {
                $table->string('step_action', 20)->nullable()->after('option_type');
            }
            if (!Schema::hasColumn('product_options', 'step_value')) {
                $table->unsignedInteger('step_value')->nullable()->after('step_action');
            }
        });
    }

    public function down(): void
    {
        Schema::table('product_options', function (Blueprint $table) {
            if (Schema::hasColumn('product_options', 'step_value')) {
                $table->dropColumn('step_value');
            }
            if (Schema::hasColumn('product_options', 'step_action')) {
                $table->dropColumn('step_action');
            }
            if (Schema::hasColumn('product_options', 'option_type')) {
                $table->dropColumn('option_type');
            }
        });
    }
};
