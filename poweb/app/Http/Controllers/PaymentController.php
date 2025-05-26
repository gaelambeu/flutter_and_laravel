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

        $paymentData = $data;

        if (($paymentData['type'] ?? '') !== 'invoice' || ($paymentData['status'] ?? '') !== 'Paid') {
            return response('Invalid callback type or status', 400);
        }

        $payment = Payment::updateOrCreate(
            ['order_id' => $paymentData['order_id']],
            [
                'track_id'             => $paymentData['track_id'],
                'status'               => $paymentData['status'],
                'type'                 => $paymentData['type'],
                'module_name'          => $paymentData['module_name'] ?? 'OxaPay',
                'amount'               => $paymentData['amount'],
                'value'                => $paymentData['value'],
                'currency'             => $paymentData['currency'],
                'email'                => $paymentData['email'] ?? null,
                'note'                 => $paymentData['note'] ?? '',
                'fee_paid_by_payer'    => (bool) ($paymentData['fee_paid_by_payer'] ?? 0),
                'under_paid_coverage'  => $paymentData['under_paid_coverage'] ?? 0,
                'description'          => $paymentData['description'] ?? '',
                'paid_at'              => date('Y-m-d H:i:s', $paymentData['date']),
                'raw_data'             => $paymentData,
            ]
        );

        // ✅ Gestion de l’abonnement après paiement
        $email = $paymentData['email'] ?? null;

if ($email) {
    $user = User::where('email', $email)->first();

    if ($user) {
        $subscription = Subscription::where('google_id', $user->google_id)->first();

        if ($subscription) {
            $nouveauxJours = $subscription->jours + 30;

            $subscription->update([
                'status'       => 'pay',
                'account'      => 'unlocked',
                'jours'        => $nouveauxJours,
                'type_account' => $subscription->type_account === 'new' && $nouveauxJours > 30 ? 'old' : $subscription->type_account,
            ]);
        } else {
            // Paiement sans abonnement existant (rare mais possible)
            Subscription::create([
                'google_id'     => $user->google_id,
                'prix'          => 100,
                'status'        => 'pay',
                'account'       => 'unlocked',
                'jours'         => 30,
                'type_account'  => 'new',
            ]);
        }
    }
}


        return response('OK', 200);
    }
}
