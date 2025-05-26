// lib/screens/signup_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:powebvpn/api/google_signin_api.dart';
import 'package:powebvpn/screens/sub_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final user = await GoogleSigninApi.login();

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la connexion avec Google')),
        );
        return;
      }

      final auth = await user.authentication;
      final googleId = user.id;

      // Vérifie si l'utilisateur existe déjà dans la base de données
      final checkUri = Uri.parse('http://192.168.1.105:8000/api/user-info/$googleId');
      final checkResponse = await http.get(checkUri);

      if (checkResponse.statusCode != 200) {
        // Utilisateur non trouvé → on l’enregistre
        final name = user.displayName ?? 'Nom inconnu';
        final email = user.email;
        final avatar = user.photoUrl ?? '';
        final accessToken = auth.accessToken ?? '';

        final registerUri = Uri.parse('http://192.168.1.105:8000/api/google-login');
        final registerResponse = await http.post(
          registerUri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'google_id': googleId,
            'avatar': avatar,
            'access_token': accessToken,
          }),
        );

        if (registerResponse.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${jsonDecode(registerResponse.body)['message'] ?? 'Échec de l\'enregistrement'}')),
          );
          return;
        }
      }

      // Aller à la page d’abonnement
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SubPage(googleId: googleId),
        ),
      );
    } catch (e) {
      print('❌ Erreur Google Sign-In : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset('assets/images/logo.png', height: 120),
            const SizedBox(height: 30),
            const Text(
              'Добро пожаловать !',
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Войдите в свою учетную запись Google, чтобы продолжить.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              icon: Image.asset('assets/images/google.png', height: 18),
              label: const Text(
                'Войти в систему с помощью Google',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              onPressed: () => _handleGoogleSignIn(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
