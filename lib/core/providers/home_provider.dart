import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant_explore/model/plant.dart';
import 'package:plant_explore/model/quiz.dart';
import 'dart:convert';
import 'auth_provider.dart';

class HomeProvider with ChangeNotifier {
  List<Plant> _plants = [];
  List<Quiz> _quizzes = [];
  List<Plant> _favoritePlants = [];
  bool _isLoading = false;
  final AuthProvider authProvider; // Reference to AuthProvider

  HomeProvider(this.authProvider); // Require AuthProvider in constructor
  List<Plant> get favoritePlants => _favoritePlants;
  List<Plant> get plants => _plants;
  List<Quiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;

  Future<void> fetchPlants() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/plants');

    final token = authProvider.token; // Get token from AuthProvider
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
      final List<dynamic> decodedData = jsonDecode(response.body);
      _plants = decodedData.map((e) => Plant.fromJson(e)).toList();
      print("Fetched Plants: $_plants");
    } else {
      print("Error fetching plants: ${response.statusCode}");
      _plants = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFavoritePlants() async {
    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/favorite-plant?index=1&pageSize=10');
    final token = authProvider.token; // Get token from AuthProvider
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
      final List<dynamic> decodedData = jsonDecode(response.body);
      _plants = decodedData.map((e) => Plant.fromJson(e)).toList();
      print("Fetched Plants: $_plants");
    } else {
      print("Error fetching plants: ${response.statusCode}");
      _plants = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/quizzes?index=1&pageSize=10');

    final token = authProvider.token; // Get token from AuthProvider
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
}
