<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Laravel\Socialite\Facades\Socialite;
use App\Models\User;

class GoogleController extends Controller
{
    public function redirectToGoogle (Request $request)
    {
        return Socialite::driver('google')->redirect();
    }

    public function handleGoogleCallback (Request $request)
    {
        try {
            $googleUser = Socialite::driver('google')->stateless()->user();

            $findUser = User::where('google_id', $googleUser->id)->first();

            if ($findUser) {
                Auth::login($findUser);
            } else {
                $findUser = User::create([
                    'name' => $googleUser->name,
                    'email' => $googleUser->email,
                    'google_id' => $googleUser->id,
                    'password' => bcrypt('123456'), // plus sécurisé que encrypt()
                ]);
                Auth::login($findUser);
            }

            return redirect('/'); // redirection après login
        } catch (\Exception $e) {
            return redirect('/login')->with('error', 'Erreur lors de la connexion avec Google.');
        }
    }
}
