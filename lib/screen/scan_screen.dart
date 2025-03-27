import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  String? _savedImagePath;
  Map<String, dynamic>? _plantInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    } else if (state == AppLifecycleState.paused) {
      _cameraController?.dispose();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController =
          CameraController(cameras.first, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _captureAndIdentify() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile picture = await _cameraController!.takePicture();

      try {
        await Gal.putImage(picture.path);
      } catch (e) {
        _showMessage("Error saving to gallery: $e", isError: true);
      }

      _showMessage("Uploading image...");
      await _uploadImageAndFetchPlantInfo(picture);
    } catch (e) {
      _showMessage("Error capturing image: $e", isError: true);
    }
  }

  Future<void> _uploadImageAndFetchPlantInfo(XFile picture) async {
    if (_savedImagePath == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      _showMessage("Authentication required!", isError: true);
      return;
    }
    // Kiểm tra phần mở rộng file
    if (!picture.path.toLowerCase().endsWith('.jpg')) {
      _showMessage("Chỉ hỗ trợ file .jpg!", isError: true);
      return;
    }
    try {
      var url = Uri.parse(
          "https://plant-explorer-backend-0-0-1.onrender.com/api/scan-histories/identify");

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Content-Type'] = 'multipart/form-data'; // Add this line
      var response = await request.send();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        String? cacheKey = jsonResponse['cacheKey'];

        if (cacheKey != null) {
          _fetchPlantDetails(cacheKey);
        } else {
          _showMessage("No plant found.", isError: true);
        }
      } else {
        _showMessage("Upload failed: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showMessage("Error uploading image: $e", isError: true);
    }
  }

  Future<void> _fetchPlantDetails(String cacheKey) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      _showMessage("Authentication required!", isError: true);
      return;
    }

    try {
      var plantInfoUrl = Uri.parse(
          "https://plant-explorer-backend-0-0-1.onrender.com/api/scan-histories/plant-info/$cacheKey");

      var response = await http.get(plantInfoUrl, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String? plantId = jsonResponse['plant']?['id'];

        if (plantId != null) {
          await _fetchPlantById(plantId);
        } else {
          _showMessage("Plant ID not found.", isError: true);
        }
      } else {
        _showMessage("Failed to fetch plant details: ${response.statusCode}",
            isError: true);
      }
    } catch (e) {
      _showMessage("Error fetching plant details: $e", isError: true);
    }
  }

  Future<void> _fetchPlantById(String plantId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      var url = Uri.parse(
          "https://plant-explorer-backend-0-0-1.onrender.com/api/plants/$plantId");

      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() => _plantInfo = jsonResponse);
        _showPlantInfoDialog();
      } else {
        _showMessage("Failed to fetch plant details: ${response.statusCode}",
            isError: true);
      }
    } catch (e) {
      _showMessage("Error fetching plant details: $e", isError: true);
    }
  }

  void _showPlantInfoDialog() {
    if (_plantInfo == null) {
      _showMessage("No plant information found.", isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_plantInfo?['name'] ?? 'Unknown Plant'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlantDetail(
                  "🌿 Scientific Name", _plantInfo?['scientificName']),
              _buildPlantDetail("🌱 Family", _plantInfo?['family']),
              _buildPlantDetail("📜 Description", _plantInfo?['description']),
              _buildPlantDetail("🏞 Habitat", _plantInfo?['habitat']),
              _buildPlantDetail("🌍 Distribution", _plantInfo?['distribution']),
              _buildPlantDetail(
                  "💊 Medicinal Uses", _plantInfo?['medicinalUses']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantDetail(String label, String? value) {
    return Text("$label: ${value ?? 'N/A'}");
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: Column(
        children: [
          Expanded(
              child: _cameraController != null &&
                      _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : Center(child: CircularProgressIndicator())),
          IconButton(
              iconSize: 80,
              icon: Icon(Icons.camera, color: Colors.green),
              onPressed: _captureAndIdentify),
        ],
      ),
    );
  }
}
