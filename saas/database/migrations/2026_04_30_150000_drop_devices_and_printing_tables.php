<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('sales') && Schema::hasColumn('sales', 'device_id')) {
            Schema::table('sales', function (Blueprint $table) {
                $table->dropForeign(['device_id']);
                $table->dropColumn('device_id');
            });
        }

        Schema::dropIfExists('device_sync_logs');
        Schema::dropIfExists('devices');
        Schema::dropIfExists('printing_services');
    }

    public function down(): void
    {
        if (!Schema::hasTable('devices')) {
            Schema::create('devices', function (Blueprint $table) {
                $table->id();
                $table->foreignId('manager_id')->constrained()->cascadeOnDelete();
                $table->foreignId('store_id')->nullable()->constrained()->nullOnDelete();
                $table->string('name');
                $table->string('uuid')->unique();
                $table->string('platform')->nullable();
                $table->string('app_version')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamp('last_seen_at')->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
        }

        if (!Schema::hasTable('device_sync_logs')) {
            Schema::create('device_sync_logs', function (Blueprint $table) {
                $table->id();
                $table->foreignId('device_id')->constrained()->cascadeOnDelete();
                $table->string('direction');
                $table->string('status');
                $table->string('payload_hash')->nullable();
                $table->text('error_message')->nullable();
                $table->timestamp('synced_at')->nullable();
                $table->timestamps();
                $table->index(['device_id', 'direction', 'status']);
            });
        }

        if (!Schema::hasTable('printing_services')) {
            Schema::create('printing_services', function (Blueprint $table) {
                $table->id();
                $table->foreignId('manager_id')->constrained()->cascadeOnDelete();
                $table->foreignId('store_id')->nullable()->constrained()->nullOnDelete();
                $table->string('name');
                $table->string('service_type')->default('network');
                $table->string('endpoint')->nullable();
                $table->unsignedInteger('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
                $table->softDeletes();
            });
        }

        if (Schema::hasTable('sales') && !Schema::hasColumn('sales', 'device_id')) {
            Schema::table('sales', function (Blueprint $table) {
                $table->foreignId('device_id')->nullable()->after('store_id')->constrained()->nullOnDelete();
            });
        }
    }
};
