<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\Payment;

class PaymentController extends Controller
{
    public function createPayment(Request $request)
    {
        $orderId = 'ORDER-' . uniqid();

        $payment = Payment::create([
            'user_id' => $request->user_id,
            'order_id' => $orderId,
            'amount' => $request->amount,
        ]);

        $paymentUrl = 'https://www.oxapay.com/payment?amount=' . $payment->amount . '&currency=TON&order_id=' . $payment->order_id . '&callback_url=' . urlencode(env('APP_URL') . '/api/payment/webhook');

        return response()->json([
            'payment_url' => $paymentUrl,
            'order_id' => $orderId,
        ]);
    }

    public function handleWebhook(Request $request)
    {
        $payment = Payment::where('order_id', $request->order_id)->first();

        if ($payment) {
            $payment->update([
                'status' => $request->status,
                'transaction_id' => $request->transaction_id,
            ]);
        }

        return response()->json(['success' => true]);
    }
}
