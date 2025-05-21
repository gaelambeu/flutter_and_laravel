import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final String userId;

  const PaymentPage({required this.userId, super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;

  Future<void> _startPayment() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://172.19.0.1:8000/api/payment/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'amount': 5.0,
          'currency': 'TON', // ou 'USDT', selon ce que tu gères dans Laravel
          'method': 'telegram', // si tu veux spécifier que c'est pour Telegram
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['payment_url'] != null) {
        final paymentUrl = data['payment_url'];

        if (await canLaunchUrl(Uri.parse(paymentUrl))) {
          await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
        } else {
          _showError("Impossible d’ouvrir le lien de paiement.");
        }
      } else {
        _showError(data['message'] ?? 'Erreur lors de la création du paiement.');
      }
    } catch (e) {
      _showError("Erreur réseau : ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement via Oxapay')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _startPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Payer avec TON via Telegram'),
              ),
      ),
    );
  }
}
