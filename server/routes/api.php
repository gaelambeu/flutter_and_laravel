<?php

use App\Http\Controllers\GoogleAuthController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Support\Facades\Route;

//Route::get('/auth/google/redirect', [GoogleAuthController::class, 'redirectToGoogle']);
//Route::get('/auth/google/callback', [GoogleAuthController::class, 'handleGoogleCallback']);



Route::apiResource('products',ProductController::class);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

