import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:powebvpn/auth_pages/logged_in_page.dart';
import 'package:powebvpn/auth_pages/sign_up_page.dart';
import 'package:powebvpn/buy/payment_page.dart';
import 'package:powebvpn/screens/home_screen.dart';
import 'package:powebvpn/screens/menu_screen.dart';
import 'package:powebvpn/screens/premium_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleSignInAccount? user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? googleId;
  String? userId;
  

  @override
  void initState() {
    super.initState();
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      setState(() {
        user = account;
      });
    } catch (e) {
      print("Ошибка при проверке входа в систему: $e");
    }
  }

  /// Convertit le compte Google en Map<String, dynamic>
  Map<String, dynamic>? get userAsMap {
    if (user == null) return null;
    return {
      'id': user!.id,
      'email': user!.email,
      'displayName': user!.displayName,
      'photoUrl': user!.photoUrl,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? SignUpPage() : HomeScreen(googleId: googleId!),
      routes: {
        '/signup': (context) =>  SignUpPage(),
        '/home': (context) => HomeScreen(googleId: googleId!),
        '/menu': (context) =>  MenuScreen(),
        '/premium': (context) =>  PremiumScreen(),
        '/profil': (context) => LoggedInPage(googleId: googleId!),
        '/pay': (context) =>  PaymentPage(userId: userId!),

      },
    );
  }
}
