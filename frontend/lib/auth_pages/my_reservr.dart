import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:powebvpn/api/google_signin_api.dart';
import 'package:powebvpn/auth_pages/logged_in_page.dart';
import 'package:powebvpn/screens/home_screen.dart';


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

    // 🔍 Vérifie si l'utilisateur existe déjà dans la BDD
    final checkUri = Uri.parse('http://192.168.1.105:8000/api/user-info/$googleId');
    final checkResponse = await http.get(checkUri);

    if (checkResponse.statusCode == 200) {
      // ✅ Utilisateur trouvé dans la BDD
      final userData = jsonDecode(checkResponse.body);
      print('✅ Utilisateur existant : $userData');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(googleId: googleId),
        ),
      );
    } else {
      // ❌ Pas trouvé → on l’enregistre
      final name = user.displayName ?? 'Nom inconnu';
      final email = user.email;
      final avatar = user.photoUrl ?? '';
      final accessToken = auth.accessToken ?? '';

      final registerUri = Uri.parse('http://192.168.1.105:8000/api/google-login');
      final registerResponse = await http.post(
        registerUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'google_id': googleId,
          'avatar': avatar,
          'access_token': accessToken,
        }),
      );

      if (registerResponse.statusCode == 200) {
        print('✅ Utilisateur enregistré avec succès');
        final userData = jsonDecode(registerResponse.body);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(googleId: googleId),
          ),
        );
      } else {
        print('❌ Échec de l’enregistrement: ${registerResponse.statusCode}');
        print('Corps: ${registerResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${jsonDecode(registerResponse.body)['errors'].toString()}')),
        );
      }
    }
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
              'Bienvenue !',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Connecte-toi avec ton compte Google pour continuer.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: Image.asset('assets/images/google.png', height: 24),
              label: const Text(
                'Se connecter avec Google',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
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
