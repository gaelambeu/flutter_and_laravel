<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Subscription;


class UserController extends Controller
{

    public function getUserInfo($google_id)
    {
        if (!is_string($google_id) || empty($google_id)) {
            return response()->json([
                'success' => false,
                'message' => 'Google ID invalide.',
            ], 422);
        }

        $userQuery = User::where('google_id', $google_id);

        if (!$userQuery->exists()) abort(404);

        // Création ou récupération de l'utilisateur
        $user = $userQuery->first();

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






    public function getUserSubInfo($google_id)
{
    if (!is_string($google_id) || empty($google_id)) {
        return response()->json([
            'success' => false,
            'message' => 'Google ID invalide.',
        ], 422);
    }

    $user = User::where('google_id', $google_id)->first();

    if (!$user) {
        return response()->json([
            'success' => false,
            'message' => 'Utilisateur non trouvé.',
        ], 404);
    }

    $subscription = Subscription::where('google_id', $google_id)->latest('created_at')->first();

    return response()->json([
        'success' => true,
        'user' => [
            'google_id'    => $user->google_id,
            'name'         => $user->name,
            'email'        => $user->email,
            'avatar'       => $user->avatar,
            'access_token' => $user->access_token,
        ],
        'account'      => $subscription?->account ?? 'locked',
        'jours'        => $subscription?->jours ?? 0,
        'expire_date'  => optional($subscription?->expire_date)->format('Y-m-d'),
    ]);
}



}
