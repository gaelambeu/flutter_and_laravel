<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\Payment;
use App\Models\User;
use App\Models\Subscription;

class PaymentController extends Controller
{
    public function createPayment(Request $request)
    {
        $validated = $request->validate([
            'amount' => 'required|integer|min:1',
        ]);

        $order_id = uniqid();
        $amount = $validated['amount'];

        $requestBody = [
            'amount' => $amount,
            'currency' => 'USDT',
            'order_id' => $order_id,
            'callback_url' => url('/api/oxapay/callback'),
            'return_url' => url('/success'),
        ];

        Log::info("[OXAPAY] Request:", $requestBody);

        $response = Http::withHeaders([
            'merchant_api_key' => env('OXAPAY_MERCHANT_API_KEY'),
        ])->post('https://api.oxapay.com/v1/payment/invoice', $requestBody);

        $data = $response->json();
        Log::info("[OXAPAY] API response:", $data);

        if (!isset($data['data']['payment_url'])) {
            abort(503, 'Erreur de communication avec Oxapay');
        }

        Payment::create([
            'order_id' => $order_id,
            'currency' => 'USDT',
            'amount' => $amount,
            'status' => 'pending',
            'raw_data' => $data,
        ]);

        return [
            'payment_url' => $data['data']['payment_url']
        ];
    }

    public function handleCallback(Request $request)
    {
        $postData = $request->getContent();
        $data = json_decode($postData, true);

        $hmacHeader = $request->header('HMAC');
        if (!$hmacHeader) {
            return response('Missing HMAC', 400);
        }

        $apiSecret = env('OXAPAY_MERCHANT_API_KEY');
        $calculatedHmac = hash_hmac('sha512', $postData, $apiSecret);
        if (!hash_equals($calculatedHmac, $hmacHeader)) {
            return response('Invalid HMAC', 400);
        }

        if (($data['type'] ?? '') !== 'invoice' || ($data['status'] ?? '') !== 'Paid') {
            return response('Invalid callback type or status', 400);
        }

        // ✅ 1. Enregistrement du paiement
        $payment = Payment::create([
            'order_id'            => $data['order_id'],
            'track_id'            => $data['track_id'],
            'status'              => $data['status'],
            'type'                => $data['type'],
            'module_name'         => $data['module_name'] ?? 'OxaPay',
            'amount'              => $data['amount'],
            'value'               => $data['value'],
            'currency'            => $data['currency'],
            'email'               => $data['email'] ?? null,
            'note'                => $data['note'] ?? '',
            'fee_paid_by_payer'   => (bool) ($data['fee_paid_by_payer'] ?? 0),
            'under_paid_coverage' => $data['under_paid_coverage'] ?? 0,
            'description'         => $data['description'] ?? '',
            'paid_at'             => date('Y-m-d H:i:s', $data['date']),
            'raw_data'            => $data,
        ]);

        // ✅ 2. Mise à jour de la subscription par email
        $email = $data['email'] ?? null;

        if ($email) {
            $subscription = Subscription::where('email', $email)->first();

            if (!$subscription) {
                Log::warning("❗ Subscription introuvable pour l'email : $email");
                return response('Subscription not found', 404);
            }

            Log::debug("OK");
            // $subscription->increment('jours', 30);
            $subscription->updateSubscription(30);
            $subscription->save();

            info(json_encode($subscription->toArray(), JSON_PRETTY_PRINT));
            info("Subscription is active: {$subscription->isActive}");
            $days_to_expiration = round($subscription->daysToExpiration);
            info("Days to expiration: {$days_to_expiration}");
            Log::info("✅ Subscription mise à jour pour {$email} : +30 jours (total: " . ($subscription->jours) . ").");
        }

        return response('OK', 200);
    }

}
