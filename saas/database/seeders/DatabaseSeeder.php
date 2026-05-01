<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['username' => 'admin'],
            [
                'name' => 'Admin',
                'email' => 'admin@example.com',
                'password' => Hash::make('12345678'),
                'pin' => Hash::make('1234'),
                'is_super_admin' => true,
                'is_active' => true,
            ]
        );

        User::firstOrCreate(
            ['email' => 'test@example.com'],
            [
                'name' => 'Test User',
                'username' => 'test',
                'password' => Hash::make('password'),
                'pin' => Hash::make('1234'),
                'is_super_admin' => false,
                'is_active' => true,
            ]
        );
    }
}
