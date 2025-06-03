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

//Route::post('/google-login', [UserController::class, 'login']);

// Login utilisateur via google_id (POST ou GET possible, ici GET simple)
Route::get('/user-info/{google_id}', [UserController::class, 'getUserInfo']);

// Récupérer les infos de l'utilisateur + abonnement
Route::get('/user-sub-info/{google_id}', [UserController::class, 'getUserSubInfo']);


Route::get('/subscription/{googleId}', [SubscriptionController::class, 'show']);
Route::post('/subscription/handle', [SubscriptionController::class, 'handle']);





Route::post('/oxapay/create', [PaymentController::class, 'createPayment']);
Route::post('/oxapay/callback', [PaymentController::class, 'handleCallback']);

