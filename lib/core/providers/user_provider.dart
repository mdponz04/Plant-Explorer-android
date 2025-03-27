import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> fetchUserProfile(String token) async {
    print("Fetching user with token: $token");

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
            'https://plant-explorer-backend-0-0-1.onrender.com/api/users/current-user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*', // Thử thêm header này
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _user = responseData["data"]; // Lấy đúng data
      } else {
        _user = null;
      }
    } catch (error) {
      print('Error fetching user: $error');
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(String token, String userId, String name, int age,
      String phoneNumber, String avatarUrl, BuildContext context) async {
    final url = Uri.parse(
        "https://plant-explorer-backend-0-0-1.onrender.com/api/users/$userId");

    try {
      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "age": age,
          "phoneNumber": phoneNumber,
          "avatarUrl": avatarUrl,
        }),
      );

      if (response.statusCode == 200) {
        final updatedUser = json.decode(response.body);
        _user = updatedUser["data"];
        await fetchUserProfile(token);
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update user: ${response.body}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating user!")),
      );
    }
  }
}
