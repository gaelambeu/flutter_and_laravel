// lib/screens/sub_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:powebvpn/screens/home_screen.dart';

class SubPage extends StatefulWidget {
  final String googleId;

  const SubPage({super.key, required this.googleId});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.105:8000/api/subscription/handle'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'google_id': widget.googleId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['locked'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ваша учетная запись заблокирована.')),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(googleId: widget.googleId),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur abonnement: ${jsonDecode(response.body)['message']}')),
        );
      }
    } catch (e) {
      print('❌ Erreur abonnement : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Загрузка завершена.', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
