import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';
import 'package:plant_explore/model/plant.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({Key? key, required this.plant}) : super(key: key);

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  bool _isFavorited = false;
  bool _isLoading = false;

  Future<void> _toggleFavorite(BuildContext context) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    const String apiUrl =
        "https://plant-explorer-backend-0-0-1.onrender.com/api/favorite-plant";

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? token = authProvider.token;

      if (token == null) {
        _showSnackBar("Error: User not authenticated.");
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"plantId": widget.plant.id}),
      );

      if (response.statusCode == 200) {
        setState(() => _isFavorited = !_isFavorited);
        _showSnackBar("Plant added to favorites!");
      } else {
        _showSnackBar("Failed to add favorite: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for better contrast
      appBar: AppBar(
        title: Text(widget.plant.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border,
            color: Colors.white),
        onPressed: () => _toggleFavorite(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(widget.plant.name),
            _buildDetailCard("Family", widget.plant.family),
            _buildDetailCard("Habitat", widget.plant.habitat),
            _buildDetailCard("Distribution", widget.plant.distribution),
            _buildDetailCard("Description", widget.plant.description),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 6),
            Text(content,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
