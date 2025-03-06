import 'package:flutter/material.dart';

class PlantProvider extends ChangeNotifier {
  String _selectedPlant = '';

  String get selectedPlant => _selectedPlant;

  void selectPlant(String plant) {
    _selectedPlant = plant;
    notifyListeners();
  }
}
