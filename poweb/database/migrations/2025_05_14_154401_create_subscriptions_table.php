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
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->string('google_id');
            $table->integer('prix')->default(100);
            $table->enum('status', ['pay', 'nopay'])->default('pay');
            $table->enum('account', ['locked', 'unlocked'])->default('unlocked');
            $table->integer('jours')->default(30);
            //$table->boolean('demande_unlock')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};
