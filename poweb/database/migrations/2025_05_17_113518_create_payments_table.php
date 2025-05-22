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
       Schema::create('payments', function (Blueprint $table) {
        $table->id();
        $table->string('track_id')->nullable();                  // "151811887"
        $table->string('status')->default('pending');           // "Paid"
        $table->string('type')->nullable();                     // "invoice"
        $table->string('module_name')->nullable();              // "OxaPay"
        $table->decimal('amount', 16, 8)->nullable();            // 10
        $table->decimal('value', 16, 8)->nullable();             // 3.6839
        $table->string('currency')->nullable();                 // "POL"
        $table->string('order_id')->unique();                   // "ORD-12345"
        $table->string('email')->nullable();                    // "customer@oxapay.com"
        $table->text('note')->nullable();                       // ""
        $table->boolean('fee_paid_by_payer')->default(false);   // 0
        $table->decimal('under_paid_coverage', 16, 8)->nullable(); // 0
        $table->string('description')->nullable();              // "Test Description"
        $table->timestamp('paid_at')->nullable();               // 1738493900
        $table->json('raw_data')->nullable();                   // tout le JSON original
        $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
