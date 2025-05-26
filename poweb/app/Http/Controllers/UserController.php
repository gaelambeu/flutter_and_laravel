<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Subscription;

class UserController extends Controller
{
    /**
     * Enregistre l’utilisateur (si nouveau) et déclenche l’abonnement via Observer.
     */
    public function login($google_id)
    {
        if (!is_string($google_id) || empty($google_id)) {
            return response()->json([
                'success' => false,
                'message' => 'Google ID invalide.',
            ], 422);
        }

        // Création ou récupération de l'utilisateur
        $user = User::firstOrCreate(
            ['google_id' => $google_id],
            [
                'name' => 'Utilisateur',
                'email' => null,
                'avatar' => null,
                'access_token' => null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Utilisateur connecté.',
            'user' => [
                'google_id'    => $user->google_id,
                'name'         => $user->name,
                'email'        => $user->email,
                'avatar'       => $user->avatar,
                'access_token' => $user->access_token,
            ]
        ]);
    }
}
