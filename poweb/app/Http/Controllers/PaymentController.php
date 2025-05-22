<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\Payment;

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

        // Enregistrement du paiement
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

        if (!isset($data['type']) || $data['type'] !== 'payment') {
            return response('Invalid data.type', 400);
        }

        $apiSecretKey = env('OXAPAY_MERCHANT_API_KEY');
        $hmacHeader = $request->header('HMAC');
        $calculatedHmac = hash_hmac('sha512', $postData, $apiSecretKey);

        if (!hash_equals($calculatedHmac, $hmacHeader)) {
            Log::warning('[OXAPAY] HMAC validation failed');
            return response('Invalid HMAC signature', 400);
        }

        $payload = $data['data'] ?? [];
        $orderId = $payload['order_id'] ?? null;

        if (!$orderId) {
            return response('Missing order_id', 400);
        }

        $payment = Payment::where('order_id', $orderId)->first();

        $fields = [
            'status'       => $payload['status'] ?? 'confirmed',
            'track_id'     => $payload['track_id'] ?? null,
            'tx_hash'      => $payload['tx_hash'] ?? null,
            'address'      => $payload['address'] ?? null,
            'amount'       => isset($payload['amount']) ? intval($payload['amount']) : null,
            'value'        => $payload['value'] ?? null,
            'currency'     => $payload['currency'] ?? null,
            'network'      => $payload['network'] ?? null,
            'description'  => $payload['description'] ?? null,
            'confirmed_at' => $payload['date'] ?? null,
            'raw_data'     => $data,
        ];

        if ($payment) {
            $payment->update($fields);
            Log::info("[OXAPAY] Updated existing payment: $orderId");
        } else {
            $fields['order_id'] = $orderId;
            Payment::create($fields);
            Log::info("[OXAPAY] Created new payment: $orderId");
        }

        return response('OK', 200);
    }
}
