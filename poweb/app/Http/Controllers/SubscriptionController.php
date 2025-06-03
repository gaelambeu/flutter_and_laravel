<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Subscription;

class SubscriptionController extends Controller
{
    /**
     * Vérifie l’abonnement d’un utilisateur via son google_id
     */
    public function handle(Request $request)
    {
        $request->validate([
            'google_id' => 'required|string',
        ]);

        $googleId = $request->google_id;

        // Vérifier si l'utilisateur existe
        $user = User::where('google_id', $googleId)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé.',
            ], 404);
        }

        // Vérifier si l'abonnement existe
        $subscription = Subscription::where('google_id', $googleId)->first();

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun abonnement trouvé pour cet utilisateur.',
            ], 404);
        }

        // Compte bloqué
        if ($subscription->account === 'locked') {
            return response()->json([
                'success' => false,
                'locked' => true,
                'jours' => $subscription->jours ?? 0,
                'message' => '🚫 Votre compte est bloqué.',
            ], 403);
        }

        // Abonnement expiré
        if ($subscription->jours <= 0) {
            return response()->json([
                'success' => false,
                'locked' => false,
                'jours' => 0,
                'message' => '⏳ Votre abonnement est expiré.',
            ], 403);
        }

        // Accès autorisé
        return response()->json([
            'success' => true,
            'locked' => false,
            'jours' => $subscription->jours,
            'message' => '✅ Abonnement actif.',
        ]);
    }




    public function show($googleId)
    {
        // Même logique que dans handle(), sauf que tu ne valides pas la requête
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
                'jours' => $subscription->jours ?? 0,
                'message' => '🚫 Votre compte est bloqué.',
            ], 403);
        }

        if ($subscription->jours <= 0) {
            return response()->json([
                'success' => false,
                'locked' => false,
                'jours' => 0,
                'message' => '⏳ Votre abonnement est expiré.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'locked' => false,
            'jours' => $subscription->jours,
            'message' => '✅ Abonnement actif.',
        ]);
    }

}
