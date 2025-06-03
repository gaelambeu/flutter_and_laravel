import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:powebvpn/api/google_signin_api.dart';
import 'package:powebvpn/screens/home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _clearCachedUserData();
  }

  Future<void> _clearCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('🧹 Données locales supprimées');
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = await GoogleSigninApi.login();
      if (user == null) {
        _showError('Connexion annulée. Veuillez réessayer.');
        return;
      }

      final auth = await user.authentication;
      final googleId = user.id;
      final name = user.displayName ?? 'Utilisateur';
      final email = user.email;
      final avatar = user.photoUrl ?? '';
      final accessToken = auth.accessToken ?? '';

      final checkResponse = await http.get(
        Uri.parse('http://192.168.1.105:8000/api/user-info/$googleId'),
      );

      if (checkResponse.statusCode != 200) {
        final registerResponse = await http.post(
          Uri.parse('http://192.168.1.105:8000/api/google-login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'google_id': googleId,
            'avatar': avatar,
            'access_token': accessToken,
          }),
        );

        if (registerResponse.statusCode != 200) {
          final msg = jsonDecode(registerResponse.body)['message'] ?? 'Erreur inconnue';
          debugPrint('⚠️ Enregistrement échoué: $msg');
          _showError('Impossible de vous enregistrer. Veuillez réessayer plus tard.');
          return;
        }
      }

      await _checkUserEligibility(googleId);
    } catch (e) {
      debugPrint('⚠️ Exception lors de la connexion: $e');
      _showError('Erreur de connexion. Vérifiez votre réseau et réessayez.');
    }
  }

  Future<void> _checkUserEligibility(String googleId) async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.105:8000/api/user-sub-info/$googleId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('📦 Données abonnement: $data');

      final String account = data['account'] ?? 'locked';
      final String? expireDateStr = data['expire_date'];

      if (account != 'unlocked') {
        _showError('Votre compte est verrouillé. Contactez l’assistance.');
        return;
      }

      if (expireDateStr == null || expireDateStr.isEmpty) {
        _showError('La date d’expiration est introuvable.');
        return;
      }

      final DateTime expireDate = DateTime.parse(expireDateStr);
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime expire = DateTime(expireDate.year, expireDate.month, expireDate.day);

      if (expire.isBefore(today)) {
        _showErrorWithRenewal(
          'Votre abonnement a expiré le ${expireDate.toLocal().toString().split(' ')[0]}.',
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(googleId: googleId)),
      );
    } else {
      _showError('Impossible de vérifier l’abonnement.');
    }
  } catch (e) {
    debugPrint('❌ Erreur réseau lors de la vérification abonnement: $e');
    _showError('Erreur réseau. Veuillez réessayer.');
  }
}


  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _loading = false;
    });
  }

  void _showErrorWithRenewal(String message) {
    setState(() {
      _errorMessage = message;
      _loading = false;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renouvellement requis'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamed(context, '/payment');
            },
            child: const Text('Renouveler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: _loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 20),
                    Text('Connexion en cours...', style: TextStyle(color: Colors.white)),
                  ],
                )
              : Column(
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
                    if (_errorMessage != null) ...[
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                      ),
                    ] else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        icon: Image.asset('assets/images/google.png', height: 18),
                        label: const Text(
                          'Войти в систему с помощью Google',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        onPressed: _handleGoogleSignIn,
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
