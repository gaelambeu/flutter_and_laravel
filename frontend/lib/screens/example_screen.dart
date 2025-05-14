import 'package:flutter/material.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("example Title"),
      ),
      body: const  Center(
        child: Text("example Body"),
      ),
    );
  }
}


final Map<String, String> paymentOptions = {
    "5 USD": "https://pay.oxapay.com/10691049",
    "10 USD": "https://pay.oxapay.com/13092357",
    "25 USD (Premium VPN)": "https://pay.oxapay.com/19785403",
  };