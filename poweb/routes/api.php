<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GoogleAuthController;
use App\Http\Controllers\UserController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');





Route::post('/google-login', [GoogleAuthController::class, 'login']);


Route::get('/user-info/{google_id}', [UserController::class, 'getByGoogleId']);

