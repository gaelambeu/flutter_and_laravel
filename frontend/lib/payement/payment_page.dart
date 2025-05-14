import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StylishCryptoPayScreen extends StatelessWidget {
  // ✅ Déclaré ici pour être utilisable partout dans la classe
  final Map<String, String> paymentLinks = {
   "5 USD": "https://pay.oxapay.com/10691049",
    "10 USD": "https://pay.oxapay.com/13092357",
    "25 USD (Premium VPN)": "https://pay.oxapay.com/19785403",
  };

  Future<void> handlePayment(BuildContext context, String amount, String url) async {
    final Uri invoiceUri = Uri.parse(url);

    if (await canLaunchUrl(invoiceUri)) {
      await launchUrl(invoiceUri, mode: LaunchMode.externalApplication);

      await Future.delayed(Duration(seconds: 2));

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Paiement en attente", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.telegram, color: Colors.blue, size: 40),
              SizedBox(height: 10),
              Text("Souhaitez-vous informer le bot Telegram que vous avez payé $amount ?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Plus tard"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final telegramBotUrl = Uri.parse(
                  "https://t.me/OxaPayWalletBot?start=message=${Uri.encodeComponent("J’ai payé la facture de $amount ✅")}",
                );
                if (await canLaunchUrl(telegramBotUrl)) {
                  await launchUrl(telegramBotUrl, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Impossible d’ouvrir le bot Telegram.")),
                  );
                }
              },
              icon: Icon(Icons.send),
              label: Text("Informer le bot"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d’ouvrir la facture.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Paiement TON sécurisé", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Choisissez un montant et payez en Toncoin via Telegram",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ...paymentLinks.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed: () => handlePayment(context, entry.key, entry.value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text("Payer ${entry.key}", style: TextStyle(fontSize: 18)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
