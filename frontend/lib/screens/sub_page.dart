import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:powebvpn/auth_pages/sign_up_page.dart';
import 'package:powebvpn/screens/home_screen.dart';

class SubPage extends StatefulWidget {
  final String googleId;

  const SubPage({Key? key, required this.googleId}) : super(key: key);

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final subUrl = 'http://192.168.1.105:8000/api/user-sub-info/${widget.googleId}';

    try {
      final subResponse = await http.get(Uri.parse(subUrl), headers: {'Accept': 'application/json'});
      final subData = jsonDecode(subResponse.body);

      if (subResponse.statusCode == 200 && subData['subscription'] != null) {
        final int jours = subData['subscription']['jours'] ?? 0;
        final String account = subData['subscription']['account'] ?? 'locked';

        if (jours > 0 && account == 'unlocked') {
          // ✅ Accès autorisé
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(googleId: widget.googleId),
            ),
          );
        } else {
          setState(() {
            _errorMessage = '⏳ Abonnement expiré ou compte bloqué.';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = subData['message'] ?? '❌ Abonnement introuvable.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '⚠️ Erreur réseau : $e';
        _loading = false;
      });
    }
  }

  void _goBackToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Vérification de votre abonnement...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : _errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 60),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _goBackToSignUp,
                        child: const Text('OK'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      )
                    ],
                  )
                : const Text(
                    '✅ Compte vérifié.',
                    style: TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}
