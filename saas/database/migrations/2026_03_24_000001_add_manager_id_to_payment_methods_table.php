<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('payment_methods', 'manager_id')) {
            return;
        }

        $driver = DB::getDriverName();
        Schema::table('payment_methods', function (Blueprint $table) use ($driver) {
            if (in_array($driver, ['mysql', 'pgsql'], true)) {
                $table->foreignId('manager_id')->nullable()
                    ->constrained('managers')->nullOnDelete()
                    ->after('id');
            } else {
                // SQLite (and others) can't always add FK constraints after the fact.
                $table->unsignedBigInteger('manager_id')->nullable()->after('id');
                $table->index(['manager_id']);
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasColumn('payment_methods', 'manager_id')) {
            return;
        }

        $driver = DB::getDriverName();
        Schema::table('payment_methods', function (Blueprint $table) use ($driver) {
            if (in_array($driver, ['mysql', 'pgsql'], true)) {
                $table->dropConstrainedForeignId('manager_id');
            } else {
                $table->dropIndex(['manager_id']);
                $table->dropColumn('manager_id');
            }
        });
    }
};
