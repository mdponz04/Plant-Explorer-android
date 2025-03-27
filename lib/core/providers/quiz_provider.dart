import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_provider.dart';
import 'package:plant_explore/model/quiz.dart';
import 'package:plant_explore/model/question.dart';

class QuizProvider with ChangeNotifier {
  List<Quiz> _quizzes = [];
  List<Question> _questions = [];
  bool _isLoading = false;
  final AuthProvider authProvider;

  QuizProvider(this.authProvider);

  List<Quiz> get quizzes => _quizzes;
  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        "https://plant-explorer-backend-0-0-1.onrender.com/api/quizzes?index=1&pageSize=10");
    final token = authProvider.token;
    if (token == null) {
      print("Error: No token found. Please log in.");
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      print("Raw API response: $decodedData");

      if (decodedData is Map &&
          decodedData.containsKey('data') &&
          decodedData['data'] is Map &&
          decodedData['data'].containsKey('items') &&
          decodedData['data']['items'] is List) {
        _quizzes = (decodedData['data']['items'] as List)
            .map((e) => Quiz.fromJson(e))
            .toList();
        print("Quizzes fetched successfully: $_quizzes");
      } else {
        print("Error: API did not return a valid quiz list: $decodedData");
        _quizzes = [];
      }
    } else {
      print("Error fetching quizzes: ${response.statusCode}");
      _quizzes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchQuestions(String quizId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        "https://plant-explorer-backend-0-0-1.onrender.com/api/questions?quizId=$quizId&index=1&pageSize=10");
    final token = authProvider.token;
    if (token == null) {
      print("Error: No token found. Please log in.");
      _isLoading = false;
      notifyListeners();
      return;
    }

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
        print("Error: API did not return a valid question list: $decodedData");
        _questions = [];
      }
    } else {
      print("Error fetching questions: ${response.statusCode}");
      _questions = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
