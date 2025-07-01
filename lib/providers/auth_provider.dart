import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        email = "guest@demo.com";
        password = "guest123";
      }

      final response = await ApiService.login(email, password);
      ("Login response: $response");

      _token = response['body']['data']['token'];
      _user = User.fromJson(response['body']['data']['author']);

      ApiService.setToken(_token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      ("Login error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getMe() async {
    if (_token != null) {
      try {
        _user = await ApiService.getMe();
        notifyListeners();
      } catch (e) {
        ("getMe error: $e");
      }
    }
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
