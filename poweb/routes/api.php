<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GoogleAuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\SubscriptionController;
use App\Http\Controllers\PaymentController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');





Route::post('/google-login', [GoogleAuthController::class, 'login']);


Route::get('/user-info/{google_id}', [UserController::class, 'getByGoogleId']);


Route::get('/subscription/{google_id}', [SubscriptionController::class, 'check']);

Route::post('/subscription/handle', [SubscriptionController::class, 'handle']);



Route::post('/payment/create', [PaymentController::class, 'createPayment']);
Route::post('/payment/webhook', [PaymentController::class, 'handleWebhook']);

