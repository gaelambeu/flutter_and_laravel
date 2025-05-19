<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Subscription;

class SubscriptionController extends Controller
{
    /**
     * Vérifie ou crée un abonnement en fonction du google_id.
     */
    public function handle(Request $request)
    {
        $request->validate([
            'google_id' => 'required|string',
        ]);

        $googleId = $request->google_id;

        // Vérifie que l'utilisateur existe
        $user = User::where('google_id', $googleId)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé.',
            ], 404);
        }

        // Vérifie si l'abonnement existe déjà
        $subscription = Subscription::where('google_id', $googleId)->first();

        if ($subscription) {
            // Vérifie si le compte est bloqué
            if ($subscription->account === 'locked') {
                return response()->json([
                    'success' => false,
                    'locked' => true,
                    'message' => '🚫 Ваша учетная запись заблокирована администратором.',
                ], 403);
            }

            return response()->json([
                'success' => true,
                'exists' => true,
                'message' => '✅ Compte déjà abonné.',
                'subscription' => $subscription,
            ]);
        }

        // Sinon, on crée l'abonnement
        $new = Subscription::create([
            'google_id' => $googleId,
            'prix' => 100,
            'status' => 'pay',
            'account' => 'unlocked',
        ]);

        return response()->json([
            'success' => true,
            'created' => true,
            'message' => '🎉 Abonnement créé avec succès.',
            'subscription' => $new,
        ]);
    }
}
