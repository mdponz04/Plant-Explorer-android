import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_provider.dart';
import 'package:plant_explore/model/question.dart';

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];
  bool _isLoading = false;
  final AuthProvider authProvider;

  QuestionProvider(this.authProvider);

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;

  Future<void> fetchQuestions(String quizId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        "https://plant-explorer-backend-0-0-1.onrender.com/api/questions/8e57e444-afd9-4d48-89eb-3b0c2376592e");
    final token = authProvider.token;

    if (token == null) {
      print("Error: No token found. Please log in.");
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is Map &&
            decodedData.containsKey('data') &&
            decodedData['data'] is Map &&
            decodedData['data'].containsKey('items') &&
            decodedData['data']['items'] is List) {
          _questions = (decodedData['data']['items'] as List)
              .map((e) => Question.fromJson(e))
              .toList();
          print("Questions fetched successfully: $_questions");
        } else {
          print(
              "Error: API did not return a valid question list: $decodedData");
          _questions = [];
        }
      } else {
        print("Error fetching questions: ${response.statusCode}");
        _questions = [];
      }
    } catch (error) {
      print("Exception while fetching questions: $error");
      _questions = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
