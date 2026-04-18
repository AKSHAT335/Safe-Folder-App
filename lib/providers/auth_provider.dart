import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final storage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLogin() async {
    String? user = await storage.read(key: "user");
    if (user != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(String user, String pass) async {
    String? savedUser = await storage.read(key: "user");
    String? savedPass = await storage.read(key: "pass");

    if (user == savedUser && pass == savedPass) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> signup(String user, String pass) async {
    await storage.write(key: "user", value: user);
    await storage.write(key: "pass", value: pass);
  }

  Future<void> logout() async {
    await storage.delete(key: "user");
    await storage.delete(key: "pass");
    _isLoggedIn = false;
    notifyListeners();
  }
}
