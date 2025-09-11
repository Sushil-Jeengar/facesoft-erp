import 'dart:convert';
import 'package:facesoft/model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthProvider with ChangeNotifier {
  AuthData? _authData;

  AuthData? get authData => _authData;

  bool get isLoggedIn => _authData != null;

  void setAuthData(AuthData data) {
    _authData = data;
    _saveToLocal(data);
    notifyListeners();
  }

  void clearAuthData() {
    _authData = null;
    _clearFromLocal();
    notifyListeners();
  }

  Future<void> _saveToLocal(AuthData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString('auth_data', jsonString);
  }

  Future<void> _clearFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
  }

  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('auth_data');
    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      _authData = AuthData.fromJson(jsonMap);
      notifyListeners();
    }
  }
}
