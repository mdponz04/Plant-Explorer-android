import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_provider.dart';
import 'package:plant_explore/model/plant.dart';

class PlantProvider with ChangeNotifier {
  List<Plant> _plants = [];
  bool _isLoading = false;
  final AuthProvider authProvider;

  PlantProvider(this.authProvider);

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;

  Future<void> fetchPlants() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        "https://plant-explorer-backend-0-0-1.onrender.com/api/plants");
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
          _plants = (decodedData['data']['items'] as List)
              .map((e) => Plant.fromJson(e))
              .toList();
          print("Plants fetched successfully: $_plants");
        } else {
          print("Error: API did not return a valid plant list: $decodedData");
          _plants = [];
        }
      } else {
        print("Error fetching plants: ${response.statusCode}");
        _plants = [];
      }
    } catch (error) {
      print("Exception while fetching plants: $error");
      _plants = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
