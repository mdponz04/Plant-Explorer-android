import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant_explore/core/providers/user_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _token;

  String? get token => _token;

  Future<void> login(
      String email, String password, UserProvider userProvider) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      print("Token sau khi login: $_token"); // Kiểm tra token
      await saveToken(_token!);
      await userProvider.fetchUserProfile(_token!);
      print('Login thành công, token đã lưu');

      // Gọi fetchUserProfile sau khi login thành công
      await userProvider.fetchUserProfile(_token!);
    } else {
      print('Đăng nhập thất bại: ${response.body}');
    }
  }

  Future<bool> register(String email, String password, String confirmPassword,
      String name, int age) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'name': name,
        'age': age,
      }),
    );

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      print('Registration successful. Logging in...');
      return true; // ✅ Return true for success
    } else {
      print('Registration failed: ${response.body}');
      return false; // ✅ Return false for failure
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    print(
        "Token từ SharedPreferences: $_token"); // Kiểm tra token khi lấy từ bộ nhớ
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    notifyListeners();
  }
}
