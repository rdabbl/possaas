<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('managers', function (Blueprint $table) {
            if (!Schema::hasColumn('managers', 'username')) {
                $table->string('username')->nullable()->after('name');
                $table->unique('username');
            }
        });
    }

    public function down(): void
    {
        Schema::table('managers', function (Blueprint $table) {
            if (Schema::hasColumn('managers', 'username')) {
                $table->dropUnique(['username']);
                $table->dropColumn('username');
            }
        });
    }
};
