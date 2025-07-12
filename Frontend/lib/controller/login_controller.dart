import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoo25/model/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  bool _isLoading = false;
  // String? _authToken;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loginUser(LoginData data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.106:5000/api/v1/auth/login/mobile'), 
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final String token = responseBody['token']; 

        await _storeAuthToken(token);
        _errorMessage = null; 
        print('Login successful! Token: $token');
      } else {
        _errorMessage = 'Login failed: ${response.body}';
        print('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      print('Error during login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  

  Future<void> _storeAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    String? userid = await prefs.getString('userId');

    print('Auth Token stored in SharedPreferences: $token $userid');
  }
}