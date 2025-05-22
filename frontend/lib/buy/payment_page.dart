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
        Uri.parse('http://192.168.1.105:8000/api/payment/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 1.0,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 && data['payment_url'] == null) {
        _showError(data['message'] ?? 'Erreur lors de la création du paiement.');
        return;
      }

      final paymentUrl = data['payment_url'];
      if (!await canLaunchUrl(Uri.parse(paymentUrl))) {
        _showError("Impossible d’ouvrir le lien de paiement.");
        return;
      }

      await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
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
