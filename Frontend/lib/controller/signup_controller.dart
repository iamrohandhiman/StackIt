import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
import 'package:odoo25/model/signup_model.dart';

class SignupController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signupUser(SignupData data, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (data.password != confirmPassword) {
      _errorMessage = 'Passwords do not match.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.106:5000/api/v1/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final String userId = responseBody['userId'];

        await _storeUserId(userId);
        _errorMessage = null;
        print('Signup successful! User ID: $userId');
      } else {
        _errorMessage = 'Signup failed: ${response.body}';
        print('Signup failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      print('Error during signup: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _storeUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    // await prefs.setString('user')
    print('User ID stored in SharedPreferences: $userId');
  }
}