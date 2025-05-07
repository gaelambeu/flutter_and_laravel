import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'user_page.dart'; // ← à créer

class GoogleLoginScreen extends StatefulWidget {
  @override
  _GoogleLoginScreenState createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        final email = account.email;
        final name = account.displayName ?? '';
        final googleId = account.id;

        // Envoi au backend Laravel
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/auth/google'), // ← Android Emulator
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "email": email,
            "name": name,
            "google_id": googleId,
            "device_name": "flutter_app"
          }),
        );

        if (response.statusCode == 200) {
          final token = response.body;
          print('Token reçu : $token');

          // Redirection avec les infos utilisateur
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(
                name: name,
                email: email,
                googleId: googleId,
              ),
            ),
          );
        } else {
          print('Erreur backend : ${response.body}');
        }
      }
    } catch (e) {
      print('Erreur Google Sign-In : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _handleGoogleSignIn,
          child: Text('Connexion avec Google'),
        ),
      ),
    );
  }
}
