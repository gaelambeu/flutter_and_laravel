<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\Payment;

class PaymentController extends Controller
{

public function createPayment(Request $request)
{
    $amount = 2; // USD
    $telegramId = $request->telegram_id;

    $response = Http::post('https://api.oxapay.com/merchant/invoice', [
        'api_key' => env('6XK5L3-SYLFNU-UGPRU4-DBL9ES'),
        'amount' => $amount,
        'currency' => 'TON', // ou 'USDT', etc.
        'order_id' => uniqid(),
        'callback_url' => url('/oxapay/callback'),
        'success_url' => url('/success'),
        'cancel_url' => url('/cancel'),
    ]);

    $data = $response->json();

    if (isset($data['data']['invoice_url'])) {
        // Envoie le lien de paiement à Telegram
        Http::post("https://api.telegram.org/bot" . env('7391381549:AAG-YWFuxMWB78kdk3iG5SSh94VCSovDXTc') . "/sendMessage", [
            'chat_id' => $telegramId,
            'text' => "Voici votre lien de paiement : " . $data['data']['invoice_url'],
        ]);
    }
}


}
