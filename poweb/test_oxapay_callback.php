<?php

$apiUrl = 'http://localhost:8000/api/oxapay/callback';
$secretKey = '6XK5L3-SYLFNU-UGPRU4-DBL9ES';

$payload = [
    "track_id" => "151811887",
    "status" => "Paid",
    "type" => "invoice",
    "module_name" => "OxaPay",
    "amount" => 10,
    "value" => 3.6839,
    "currency" => "POL",
    "order_id" => "ORD-12345",
    "email" => "customer@oxapay.com",
    "note" => "",
    "fee_paid_by_payer" => 0,
    "under_paid_coverage" => 0,
    "description" => "Test Description",
    "date" => 1738493900
];

$json = json_encode($payload, JSON_UNESCAPED_SLASHES);
$hmac = hash_hmac('sha512', $json, $secretKey);

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'HMAC: ' . $hmac
]);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $json);

$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpcode\nResponse: $response\n";
