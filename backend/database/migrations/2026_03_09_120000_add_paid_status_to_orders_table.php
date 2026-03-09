<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $driver = DB::getDriverName();

        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check");
            DB::statement("ALTER TABLE orders ADD CONSTRAINT orders_status_check CHECK (status::text = ANY (ARRAY['pending','paid','processing','shipped','completed','cancelled']::text[]))");
            return;
        }

        if ($driver === 'mysql') {
            DB::statement("ALTER TABLE orders MODIFY status ENUM('pending','paid','processing','shipped','completed','cancelled') NOT NULL DEFAULT 'pending'");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $driver = DB::getDriverName();

        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check");
            DB::statement("ALTER TABLE orders ADD CONSTRAINT orders_status_check CHECK (status::text = ANY (ARRAY['pending','processing','shipped','completed','cancelled']::text[]))");
            return;
        }

        if ($driver === 'mysql') {
            DB::statement("ALTER TABLE orders MODIFY status ENUM('pending','processing','shipped','completed','cancelled') NOT NULL DEFAULT 'pending'");
        }
    }
};
