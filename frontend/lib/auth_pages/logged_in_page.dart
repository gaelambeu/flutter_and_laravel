import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:powebvpn/screens/home_screen.dart';
import 'dart:convert';
import 'sign_up_page.dart';
import 'package:powebvpn/api/google_signin_api.dart';

class LoggedInPage extends StatefulWidget {
  final String googleId; // googleId passé par le constructeur

  const LoggedInPage({Key? key, required this.googleId}) : super(key: key);

  @override
  _LoggedInPageState createState() => _LoggedInPageState();
}


class _LoggedInPageState extends State<LoggedInPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserFromApi();
  }

  // Fonction pour récupérer les infos de l'utilisateur à partir de l'API
  Future<void> fetchUserFromApi() async {
    final googleId = widget.googleId;
    final uri = Uri.parse('http://127.0.0.2:8000/api/user-info/$googleId');
    try {
      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        print('❌ Erreur lors de la récupération : ${response.statusCode}');
        print('📥 Corps : ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Exception HTTP : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : userData == null
              ? const Center(child: Text("❌ Données utilisateur introuvables", style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: (userData!['avatar'] != null && userData!['avatar'].toString().isNotEmpty)
                            ? NetworkImage(userData!['avatar'])
                            : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                      ),
                      const SizedBox(height: 20),
                      infoText("Имя", userData!['name']),
                      infoText("Электронная почта", userData!['email']),
                      infoText("ИДЕНТИФИКАТОР Google", userData!['google_id']),
                      infoText("Токен доступа", userData!['access_token']),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
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
                        onPressed: () async {
                          await GoogleSigninApi.logout();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          );
                        },
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
