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
      print('🔄 Tentative de création du paiement...');

      final response = await http.post(
        Uri.parse('http://192.168.1.105:8000/api/oxapay/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 2,
          'google_id': widget.userId, // si nécessaire pour lier à l'utilisateur
        }),
      );

      print('📡 Statut HTTP: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      late final Map<String, dynamic> data;

      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('❌ Erreur de décodage JSON: ${e.toString()}');
        _showError('Réponse invalide du serveur.');
        return;
      }

      if (response.statusCode != 200) {
        print('❗ Statut non-200: ${response.statusCode}');
        _showError(data['message'] ?? 'Erreur serveur lors du paiement.');
        return;
      }

      final paymentUrl = data['payment_url'];
      print('🔗 Lien de paiement: $paymentUrl');

      if (paymentUrl == null || paymentUrl.isEmpty) {
        print('⚠️ Lien de paiement manquant ou vide.');
        _showError('Lien de paiement non disponible.');
        return;
      }

      final uri = Uri.parse(paymentUrl);
      if (!await canLaunchUrl(uri)) {
        print('❌ Impossible de lancer l’URL: $paymentUrl');
        _showError("Impossible d’ouvrir le lien de paiement.");
        return;
      }

      print('🚀 Ouverture du lien de paiement...');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("❌ Erreur réseau ou inconnue: ${e.toString()}");
      _showError("Erreur réseau : ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    print('⚠️ Message d’erreur affiché à l’utilisateur: $message');
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
