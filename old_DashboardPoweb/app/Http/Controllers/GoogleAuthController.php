<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class GoogleAuthController extends Controller
{
    public function login(Request $request)
    {
        Log::info('Requête reçue :', $request->all());

        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            'email' => 'required|email',
            'google_id' => 'required|string',
            'avatar' => 'nullable|url',
            'access_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            Log::error('Erreur de validation', $validator->errors()->toArray());
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $validated = $validator->validated();

            $user = User::updateOrCreate(
                ['google_id' => $validated['google_id']],
                [
                    'name' => $validated['name'],
                    'email' => $validated['email'],
                    'avatar' => $validated['avatar'] ?? '',
                    'access_token' => $validated['access_token'],
                    'password' => bcrypt('dummy_password'), // ne pas utiliser dans un vrai cas
                ]
            );

            return response()->json(['message' => 'Utilisateur enregistré', 'user' => $user], 200);
        } catch (\Exception $e) {
            Log::error('Erreur lors de l’enregistrement de l’utilisateur', ['exception' => $e]);
            return response()->json(['message' => 'Erreur serveur', 'error' => $e->getMessage()], 500);
        }
    }
}
