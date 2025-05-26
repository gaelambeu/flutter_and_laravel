<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Subscription;

class SubscriptionController extends Controller
{
    /**
     * Vérifie l’abonnement d’un utilisateur existant
     */
    public function handle(Request $request)
    {
        $request->validate([
            'google_id' => 'required|string',
        ]);

        $googleId = $request->google_id;

        $user = User::where('google_id', $googleId)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé.',
            ], 404);
        }

        $subscription = Subscription::where('google_id', $googleId)->first();

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun abonnement trouvé pour cet utilisateur.',
            ], 404);
        }

        if ($subscription->account === 'locked') {
            return response()->json([
                'success' => false,
                'locked' => true,
                'message' => '🚫 Ваша учетная запись заблокирована администратором.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => '✅ Compte actif.',
            'subscription' => $subscription,
        ]);
    }
}
