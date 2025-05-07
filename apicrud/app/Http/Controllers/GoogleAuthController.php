<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Laravel\Socialite\Facades\Socialite;

class GoogleAuthController extends Controller
{
    public function redirectToGoogle() {
        return Socialite::driver('google')->stateless()->redirect();
    }


    public function handleGoogleCallback() {

        try {
            $googleUser = Socialite::driver('google')->stateless()->user();
        } catch (\Exception $th) {
            return response()->json([
                'error' => 'Error authentification'
            ], 401);
        }

        $user = User::where('google_id', $googleUser->id)->orWhere('email', $googleUser->email)->first();

        if ($user) {
            $user->update([
                'google_id' => $googleUser->id,
                'avatar' => $googleUser->avatar,
            ]);
        } else {
            $user = User::create([
                'name' => $googleUser->name,
                'email' => $googleUser->email,
                'google_id' => $googleUser->id,
                'avatar' => $googleUser->avatar,
                'password' => null, // Pas de mot de passe nécessaire avec OAuth
            ]);
        }


        $token = $user->createToken('google-auth')->plainTextToken;
        $redirectUrl = 'frontend://auth-callback?token=' . $token;


        return redirect()->away($redirectUrl);

    }
}
