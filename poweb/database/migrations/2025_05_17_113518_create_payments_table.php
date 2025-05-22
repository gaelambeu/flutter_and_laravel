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
            $table->string('order_id')->unique();
            $table->string('currency');
            $table->integer('amount');
            $table->string('status')->default('pending');
            $table->json('raw_data')->nullable();
            $table->string('track_id')->nullable();
            $table->string('tx_hash')->nullable();
            $table->string('address')->nullable();
            $table->decimal('value', 16, 8)->nullable();
            $table->string('network')->nullable();
            $table->string('description')->nullable();
            $table->bigInteger('confirmed_at')->nullable(); // timestamp UNIX
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
