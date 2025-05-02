<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\GoogleAuthController;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;




Route::get('api/auth/google/redirect', [GoogleAuthController::class, 'redirect']);
Route::get('api/auth/google/callback', [GoogleAuthController::class, 'callback']);




Route::middleware('auth:sanctum')->get('/me', function () {
    return auth()->user();
});



Route::post('/sanctum/token', function (Request $request) {
    $request->validate([
        'email' => 'required|email',
        'password' => 'required',
        'device_name' => 'required',
    ]);

    $user = User::where('email', $request->email)->first();

    if (! $user || ! Hash::check($request->password, $user->password)) {
        throw ValidationException::withMessages([
            'email' => ['The provided credentials are incorrect.'],
        ]);
    }

    return $user->createToken($request->device_name)->plainTextToken;
});




Route::middleware('auth:sanctum')->get('/user/revoke', function (Request $request) {
    $user = $request->user();
    $user->tokens()->delete();
    return "token are delete";
});


