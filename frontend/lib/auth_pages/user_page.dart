import 'package:flutter/material.dart';
import 'package:powebvpn/api/google_signin_api.dart';
import 'package:powebvpn/auth_pages/sign_up_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/avatar.jpg'),
              ),
              const SizedBox(height: 20),
              Text(
                //'Nom : $name',
                'Ambeu Gael',
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ambeugael@gmail.com',
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  
                ),
                icon: const Icon(Icons.logout, size: 32, color: Colors.white,),
                label: const Text(
                  'Déconnexion',
                  style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold,),
                ),
                onPressed: () async {
                  await GoogleSigninApi.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) =>  SignUpPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}