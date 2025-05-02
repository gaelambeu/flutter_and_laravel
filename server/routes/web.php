<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GoogleAuthController;

Route::get('/', function () {
    return view('welcome');
});


Route::get('api/auth/google/redirect', [GoogleAuthController::class, 'redirect']);
Route::get('api/auth/google/callback', [GoogleAuthController::class, 'callback']);
