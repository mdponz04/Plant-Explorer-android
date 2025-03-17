import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeProvider with ChangeNotifier {
  List<dynamic> _plants = [];
  List<dynamic> _quizzes = [];
  bool _isLoading = false;

  List<dynamic> get plants => _plants;
  List<dynamic> get quizzes => _quizzes;
  bool get isLoading => _isLoading;

  Future<void> fetchPlants() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/plant');
    final response = await http.get(
      url,
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    if (response.statusCode == 200) {
      _plants = jsonDecode(response.body);
      print("Fetched Plants: $_plants"); // Debug dữ liệu
    } else if (response.statusCode == 304) {
      print("Not Modified: Dữ liệu không thay đổi, có thể đang bị cache");
    } else {
      print(
          "Error: Failed to fetch plants. Status Code: ${response.statusCode}");
      _plants = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/quizzes');
    final response = await http.get(
      url,
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);

      // Kiểm tra nếu API trả về đúng cấu trúc
      if (decodedData is Map &&
          decodedData.containsKey('data') &&
          decodedData['data'] is Map &&
          decodedData['data'].containsKey('items') &&
          decodedData['data']['items'] is List) {
        _quizzes = decodedData['data']['items'];
        print("Quizzes fetched successfully: $_quizzes"); // Debug dữ liệu
      } else {
        print("Error: API không trả về danh sách hợp lệ: $decodedData");
        _quizzes = [];
      }
    } else {
      print("Error fetching quizzes: ${response.statusCode}");
      _quizzes = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
