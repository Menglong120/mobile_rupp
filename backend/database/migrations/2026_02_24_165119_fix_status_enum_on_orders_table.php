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
        // Skip this migration because PostgreSQL does not support MODIFY COLUMN for ENUMs like MySQL.
        // Also 'paid' status should be handled differently in PG.
    }

    public function down(): void
    {
        // Skip
    }
};
