<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GoogleAuthController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::post('/google-login', function (\Illuminate\Http\Request $request) {
    \Log::info('API HIT', $request->all()); // journaliser l'appel
    return response()->json(['message' => 'Reçu', 'data' => $request->all()]);
});
