import 'package:flutter/material.dart';


class UserPage extends StatelessWidget {
  final String name;
  final String email;
  final String googleId;

  const UserPage({
    required this.name,
    required this.email,
    required this.googleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue $name')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: $name'),
            Text('Email: $email'),
            Text('Google ID: $googleId'),
          ],
        ),
      ),
    );
  }
}
