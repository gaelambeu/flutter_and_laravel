import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _googleId;
  Map<String, dynamic>? _userData;

  String? get googleId => _googleId;
  Map<String, dynamic>? get userData => _userData;

  void setUser(String googleId, Map<String, dynamic> userData) {
    _googleId = googleId;
    _userData = userData;
    notifyListeners();
  }

  void clearUser() {
    _googleId = null;
    _userData = null;
    notifyListeners();
  }
}
