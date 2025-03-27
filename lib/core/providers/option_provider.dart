import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Option {
  final String id;
  final String context;
  final bool isCorrect;

  Option({required this.id, required this.context, required this.isCorrect});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      context: json['context'],
      isCorrect: json['isCorrect'],
    );
  }
}

class OptionProvider with ChangeNotifier {
  List<Option> _options = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Option> get options => _options;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> fetchOptions(String questionId,
      {int index = 1, int pageSize = 10}) async {
    final url = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/options?index=$index&pageSize=$pageSize&questionId=$questionId');

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _options = data.map((option) => Option.fromJson(option)).toList();
        _isLoading = false;
      } else {
        _hasError = true;
      }
    } catch (error) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
