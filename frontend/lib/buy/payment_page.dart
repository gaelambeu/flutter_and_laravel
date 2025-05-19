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
  Future<void> _startPayment() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/payment/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': widget.userId,
        'amount': 10.0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentUrl = data['payment_url'];

      if (await canLaunchUrl(Uri.parse(paymentUrl))) {
        await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d’ouvrir le lien de paiement')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création du paiement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement via Oxapay')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startPayment,
          child: const Text('Payer avec TON via Telegram'),
        ),
      ),
    );
  }
}
