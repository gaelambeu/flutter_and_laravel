import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'sign_up_page.dart';
import 'package:powebvpn/api/google_signin_api.dart';

class LoggedInPage extends StatefulWidget {
  final String googleId;

  const LoggedInPage({Key? key, required this.googleId}) : super(key: key);

  @override
  _LoggedInPageState createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<LoggedInPage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserFromApi();
  }

  Future<void> fetchUserFromApi() async {
    final uri = Uri.parse('http://192.168.1.105:8000/api/user-info/${widget.googleId}');

    try {
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true && body['user'] != null) {
        setState(() {
          user = body['user'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = body['message'] ?? '❌ Erreur lors de la récupération des données utilisateur.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '⚠️ Erreur réseau : $e';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await GoogleSigninApi.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignUpPage()),
      (route) => false, // Supprime toutes les pages précédentes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 18),
                    ),
                  ),
                )
              : user == null
                  ? const Center(
                      child: Text(
                        '❌ Données utilisateur introuvables.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: (user!['avatar'] != null && user!['avatar'].toString().isNotEmpty)
                                ? NetworkImage(user!['avatar'])
                                : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                          ),
                          const SizedBox(height: 20),
                          infoText("Имя", user!['name'] ?? ''),
                          infoText("Электронная почта", user!['email'] ?? ''),
                          infoText("ИДЕНТИФИКАТОР Google", user!['google_id'] ?? ''),
                          infoText("Токен доступа", user!['access_token'] ?? ''),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.logout, size: 32, color: Colors.white),
                            label: const Text(
                              'Отключиться',
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        '$title :\n$value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
