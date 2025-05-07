import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoogleSignIn extends StatefulWidget {
  @override
  _GoogleSignIn createState() => _GoogleSignIn();
}

final GoogleSignIn _googleSignIn = GoogleSignIn();
final _storage = FlutterSecureStorage();

/// Connexion avec Google
Future<GoogleSignInAccount?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    return googleUser;
  } catch (error) {
    print('Erreur de connexion Google : $error');
    return null;
  }
}

/// Récupération du ID Token après authentification Google
Future<String?> getGoogleIdToken() async {
  final GoogleSignInAccount? googleUser = await signInWithGoogle();
  if (googleUser != null) {
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    return googleAuth.idToken;
  }
  return null;
}

/// Envoi du ID Token au backend Laravel
Future<void> sendIdTokenToBackend(String idToken) async {
  final Uri uri = Uri.parse('https://http://10.0.2.2:8000/api/auth/google/callback');
  final Map<String, String> headers = {'Content-Type': 'application/json'};
  final Map<String, String> body = {'id_token': idToken};

  try {
    final http.Response response = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String sanctumToken = data['token'];

      await saveSanctumToken(sanctumToken);
      print('Connexion réussie. Jeton sauvegardé.');
      // TODO : Redirection vers l'écran utilisateur
    } else {
      print('Erreur du backend : ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Erreur d\'envoi du ID token : $e');
  }
}

/// Sauvegarde du token JWT de Sanctum
Future<void> saveSanctumToken(String token) async {
  await _storage.write(key: 'sanctum_token', value: token);
}

/// Lecture du token JWT
Future<String?> getSanctumToken() async {
  return await _storage.read(key: 'sanctum_token');
}

/// Appel à une route protégée avec le token JWT
Future<http.Response> getProtectedData() async {
  final String? token = await getSanctumToken();

  if (token != null) {
    final Uri uri = Uri.parse('https://http://10.0.2.2:8000/api/protected-route');
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    return await http.get(uri, headers: headers);
  } else {
    return http.Response('Unauthorized', 401);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _signInWithGoogle,
          child: Text('Connexion avec Google'),
        ),
      ),
    );
  }
}









