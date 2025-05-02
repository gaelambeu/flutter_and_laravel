<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Auth\GoogleController;;

Route::get('/', function () {
    return view('welcome');
});


Route::get('/auth/google', [GoogleController::class, 'redirectToGoogle'])->name("redirect.google");
Route::get('/auth/google/callback', [GoogleController::class, 'handleGoogleCallback']);
