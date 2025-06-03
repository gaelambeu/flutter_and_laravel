<?php

$apiUrl = 'http://localhost:8000/api/oxapay/callback'; // Change selon ton environnement
$secretKey = 'VQ2N29-NW8ATP-V2KXP8-YVNPOJ'; // Ta vraie clé secrète

// Données de test du paiement
$payload = [
    "track_id" => uniqid(),
    "status" => "Paid",
    "type" => "invoice",
    "module_name" => "OxaPay",
    "amount" => 10,
    "value" => 3.6839,
    "currency" => "POL",
    "order_id" => "ORD-12345-" . uniqid(),
    "email" => "ambeuemmanuel20@gmail.com",
    "note" => "",
    "fee_paid_by_payer" => 0,
    "under_paid_coverage" => 0,
    "description" => "Test de paiement manuel",
    "date" => time(),
];

// Encode JSON et génère la signature HMAC
$json = json_encode($payload, JSON_UNESCAPED_UNICODE);
$hmac = hash_hmac('sha512', $json, $secretKey);

// Initialisation de la requête cURL
$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'HMAC: ' . $hmac
]);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $json);

// Exécution de la requête
$response = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    echo "❌ Erreur cURL : " . curl_error($ch) . "\n";
}

curl_close($ch);

// Affichage du résultat
echo "✅ HTTP Code: $httpcode\n";
echo "📦 Response: ok";
