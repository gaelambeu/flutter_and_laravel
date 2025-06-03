import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninApi {
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  
  static Future<void> logout() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
  }
}
