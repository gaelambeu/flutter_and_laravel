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
    $amount = $validated['amount'];

    $request_body = [
        'amount' => $amount,
        'currency' => 'USDT', // ou 'USDT', etc.
        'order_id' => uniqid(),
        'callback_url' => url('/oxapay/callback'),
        'return_url' => url('/success'),
    ];
    Log::debug("[OXAPAY] Response body: " . json_encode($request_body));
    $response = Http::withHeaders([
        'merchant_api_key' => env('OXAPAY_MERCHANT_API_KEY'),
    ])->post('https://api.oxapay.com/v1/payment/invoice', $request_body);
    $data = $response->json();
    Log::debug("[OXAPAY] Response data: " . json_encode($data));

    if (!isset($data['data']['payment_url'])){
        abort(503);
    }
    $payment_url =$data['data']['payment_url'];
    Log::debug("[OXAPAY] Payment URL: " . $payment_url);
    return [
        "payment_url"=>$payment_url
    ];

}


}
