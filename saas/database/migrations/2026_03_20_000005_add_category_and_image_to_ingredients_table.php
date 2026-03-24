<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('ingredients', function (Blueprint $table) {
            $table->foreignId('ingredient_category_id')->nullable()->after('manager_id')
                ->constrained('ingredient_categories')->nullOnDelete();
            $table->string('image_path')->nullable()->after('name');
            $table->index(['manager_id', 'ingredient_category_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('ingredients', function (Blueprint $table) {
            $table->dropIndex(['manager_id', 'ingredient_category_id']);
            $table->dropConstrainedForeignId('ingredient_category_id');
            $table->dropColumn('image_path');
        });
    }
};
