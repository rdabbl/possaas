<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Rename ingredient categories table.
        if (Schema::hasTable('ingredient_categories') && !Schema::hasTable('product_option_categories')) {
            Schema::rename('ingredient_categories', 'product_option_categories');
        }

        // Rename ingredients table + category column.
        if (Schema::hasTable('ingredients') && !Schema::hasTable('product_options')) {
            if (Schema::hasColumn('ingredients', 'ingredient_category_id')) {
                Schema::table('ingredients', function (Blueprint $table) {
                    try {
                        $table->dropForeign(['ingredient_category_id']);
                    } catch (\Throwable) {
                        // Ignore missing FK.
                    }
                });
                Schema::table('ingredients', function (Blueprint $table) {
                    $table->renameColumn('ingredient_category_id', 'product_option_category_id');
                });
            }

            Schema::rename('ingredients', 'product_options');
        }

        // Re-add FK after rename.
        if (Schema::hasTable('product_options') &&
            Schema::hasTable('product_option_categories') &&
            Schema::hasColumn('product_options', 'product_option_category_id')) {
            Schema::table('product_options', function (Blueprint $table) {
                try {
                    $table->foreign('product_option_category_id')
                        ->references('id')
                        ->on('product_option_categories')
                        ->nullOnDelete();
                } catch (\Throwable) {
                    // Ignore if FK already exists.
                }
            });
        }

        // Rename pivot table and columns.
        if (Schema::hasTable('ingredient_product') && !Schema::hasTable('product_option_product')) {
            Schema::table('ingredient_product', function (Blueprint $table) {
                try {
                    $table->dropForeign(['ingredient_id']);
                } catch (\Throwable) {
                }
                try {
                    $table->dropForeign(['product_id']);
                } catch (\Throwable) {
                }
            });

            if (Schema::hasColumn('ingredient_product', 'ingredient_id')) {
                Schema::table('ingredient_product', function (Blueprint $table) {
                    $table->renameColumn('ingredient_id', 'product_option_id');
                });
            }

            Schema::rename('ingredient_product', 'product_option_product');
        }

        if (Schema::hasTable('product_option_product')) {
            // Drop old unique index if it still exists.
            if ($this->indexExists('product_option_product', 'ingredient_product_ingredient_id_product_id_unique')) {
                Schema::table('product_option_product', function (Blueprint $table) {
                    $table->dropUnique('ingredient_product_ingredient_id_product_id_unique');
                });
            }
            if (!$this->indexExists('product_option_product', 'product_option_product_product_option_id_product_id_unique')) {
                Schema::table('product_option_product', function (Blueprint $table) {
                    $table->unique(['product_option_id', 'product_id']);
                });
            }
            Schema::table('product_option_product', function (Blueprint $table) {
                try {
                    $table->foreign('product_option_id')->references('id')->on('product_options')->cascadeOnDelete();
                } catch (\Throwable) {
                }
                try {
                    $table->foreign('product_id')->references('id')->on('products')->cascadeOnDelete();
                } catch (\Throwable) {
                }
            });
        }

        // Rename JSON/text columns.
        if (Schema::hasTable('products') && Schema::hasColumn('products', 'ingredients') && !Schema::hasColumn('products', 'options')) {
            Schema::table('products', function (Blueprint $table) {
                $table->renameColumn('ingredients', 'options');
            });
        }

        if (Schema::hasTable('sale_items') && Schema::hasColumn('sale_items', 'ingredients') && !Schema::hasColumn('sale_items', 'options')) {
            Schema::table('sale_items', function (Blueprint $table) {
                $table->renameColumn('ingredients', 'options');
            });
        }
    }

    public function down(): void
    {
        // Reverse column renames first.
        if (Schema::hasTable('products') && Schema::hasColumn('products', 'options') && !Schema::hasColumn('products', 'ingredients')) {
            Schema::table('products', function (Blueprint $table) {
                $table->renameColumn('options', 'ingredients');
            });
        }
        if (Schema::hasTable('sale_items') && Schema::hasColumn('sale_items', 'options') && !Schema::hasColumn('sale_items', 'ingredients')) {
            Schema::table('sale_items', function (Blueprint $table) {
                $table->renameColumn('options', 'ingredients');
            });
        }

        if (Schema::hasTable('product_option_product') && !Schema::hasTable('ingredient_product')) {
            Schema::table('product_option_product', function (Blueprint $table) {
                try {
                    $table->dropForeign(['product_option_id']);
                } catch (\Throwable) {
                }
                try {
                    $table->dropForeign(['product_id']);
                } catch (\Throwable) {
                }
            });
            if (Schema::hasColumn('product_option_product', 'product_option_id')) {
                Schema::table('product_option_product', function (Blueprint $table) {
                    $table->renameColumn('product_option_id', 'ingredient_id');
                });
            }
            Schema::rename('product_option_product', 'ingredient_product');
        }

        if (Schema::hasTable('product_options') && !Schema::hasTable('ingredients')) {
            if (Schema::hasColumn('product_options', 'product_option_category_id')) {
                Schema::table('product_options', function (Blueprint $table) {
                    try {
                        $table->dropForeign(['product_option_category_id']);
                    } catch (\Throwable) {
                    }
                });
                Schema::table('product_options', function (Blueprint $table) {
                    $table->renameColumn('product_option_category_id', 'ingredient_category_id');
                });
            }
            Schema::rename('product_options', 'ingredients');
        }

        if (Schema::hasTable('product_option_categories') && !Schema::hasTable('ingredient_categories')) {
            Schema::rename('product_option_categories', 'ingredient_categories');
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
