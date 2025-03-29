import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';
import 'package:plant_explore/model/plant.dart';
import 'package:plant_explore/model/favoritePlant.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  bool _isFavorited = false;
  bool _isLoading = false;
  String? _favoritePlantId; // Store the ID of the favorite plant entry
  List<Favoriteplant> _favoritePlants = []; // Store the list of favorite plants

  @override
  void initState() {
    super.initState();
    _fetchFavoritePlants(); // Fetch favorite plants when the screen loads
  }

  Future<void> _fetchFavoritePlants() async {
    setState(() => _isLoading = true);

    const String apiUrl =
        "https://plant-explorer-backend-0-0-1.onrender.com/api/favorite-plant?index=1&pageSize=10";

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? token = authProvider.token;

      if (token == null) {
        _showSnackBar("Error: User not authenticated.");
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> items = decodedData['data']['items'] ?? [];
        _favoritePlants = items.map((e) => Favoriteplant.fromJson(e)).toList();
        print("Fetched Favorite Plants: $_favoritePlants");

        // Check if the current plant is in the favorite plants list
        final favoritePlant = _favoritePlants.firstWhere(
          (favPlant) => favPlant.plantName == widget.plant.name,
          orElse: () => Favoriteplant(id: '', userName: '', plantName: ''),
        );

        setState(() {
          _isFavorited = favoritePlant.id.isNotEmpty;
          _favoritePlantId = favoritePlant.id.isNotEmpty ? favoritePlant.id : null;
        });
      } else {
        _showSnackBar("Failed to fetch favorite plants: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error fetching favorite plants: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
        setState(() => _isLoading = false);
        return;
      }

      if (_isFavorited) {
        // Unmark as favorite (DELETE request)
        if (_favoritePlantId == null) {
          _showSnackBar("Error: Favorite plant ID not found.");
          setState(() => _isLoading = false);
          return;
        }

        final response = await http.delete(
          Uri.parse("$apiUrl/$_favoritePlantId"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _isFavorited = false;
            _favoritePlantId = null;
          });
          _showSnackBar("Plant removed from favorites!");
        } else {
          _showSnackBar("Failed to remove favorite: ${response.body}");
        }
      } else {
        // Mark as favorite (POST request)
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({"plantId": widget.plant.id}),
        );

        if (response.statusCode == 200) {
          // After marking as favorite, fetch the updated favorite plants list to get the new favorite plant ID
          await _fetchFavoritePlants();
          _showSnackBar("Plant added to favorites!");
        } else {
          _showSnackBar("Failed to add favorite: ${response.body}");
        }
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
      backgroundColor: Colors.grey[100],
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
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
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