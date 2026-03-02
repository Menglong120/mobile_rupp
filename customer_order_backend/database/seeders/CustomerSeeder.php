<?php

namespace Database\Seeders;

use App\Models\Customer;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class CustomerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Customer::updateOrCreate(
            ['email' => 'visal@example.com'],
            [
                'full_name' => 'Visal',
                'gender' => 'male',
                'phone' => '012345678',
                'password' => Hash::make('password'),
                'otp_verified' => true,
                'is_active' => true,
            ]
        );
    }
}
