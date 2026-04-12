<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'username')) {
                $table->string('username')->nullable()->after('name');
            }
        });

        DB::table('users')
            ->select(['id', 'name', 'email', 'username'])
            ->orderBy('id')
            ->chunkById(100, function ($users): void {
                foreach ($users as $user) {
                    if (!empty($user->username)) {
                        continue;
                    }

                    $base = '';
                    if (!empty($user->email) && str_contains($user->email, '@')) {
                        $base = Str::before($user->email, '@');
                    }
                    if ($base === '') {
                        $base = Str::slug($user->name ?: 'user', '_');
                    }
                    if ($base === '') {
                        $base = 'user';
                    }

                    $candidate = Str::lower($base);
                    while (
                        DB::table('users')
                            ->where('username', $candidate)
                            ->where('id', '!=', $user->id)
                            ->exists()
                    ) {
                        $candidate = Str::lower($base . '_' . Str::random(6));
                    }

                    DB::table('users')
                        ->where('id', $user->id)
                        ->update(['username' => $candidate]);
                }
            });

        Schema::table('users', function (Blueprint $table) {
            $table->unique('username');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'username')) {
                $table->dropUnique(['username']);
                $table->dropColumn('username');
            }
        });
    }
};
