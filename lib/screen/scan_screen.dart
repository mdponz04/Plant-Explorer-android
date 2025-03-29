import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
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

  Future<void> _captureAndIdentify(BuildContext context) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final picture = await _cameraController!.takePicture();
      File imageFile = File(picture.path);

      print("Image saved at: ${picture.path}");
      _showMessage("Uploading image...");

      await _uploadImageAndFetchPlantInfo(context, imageFile);
    } catch (e) {
      _showMessage("Error capturing image: $e", isError: true);
    }
  }

  Future<http.StreamedResponse?> _uploadImageAndFetchPlantInfo(
      BuildContext context, File picture) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (!picture.path.toLowerCase().endsWith('.jpg')) {
      _showMessage("Only .jpg files are supported!", isError: true);
      return null;
    }

    try {
      var url = Uri.parse(
          "https://plant-explorer-backend-0-0-1.onrender.com/api/scan-histories/identify");
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', picture.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        String? cacheKey = jsonResponse['cacheKey'];

        if (cacheKey != null) {
          _fetchPlantDetails(cacheKey);
        } else {
          _showMessage("No plant found.", isError: true);
        }
        return response;
      } else {
        _showMessage("Upload failed: ${response.statusCode}", isError: true);
        return response;
      }
    } catch (e) {
      _showMessage("Error uploading image: $e", isError: true);
      return null;
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    debugPrint(message); // Replace with Snackbar or Dialog if needed
  }

  Future<void> _fetchPlantDetails(String cacheKey) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    try {
      var url = Uri.parse(
          "https://plant-explorer-backend-0-0-1.onrender.com/api/scan-histories/plant-info/$cacheKey");
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
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
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      var url = Uri.parse(
          "https://plant-explorer-backend-0-0-1.onrender.com/api/plants/$plantId");
      var response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        setState(() => _plantInfo = json.decode(response.body));
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
    if (_plantInfo == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_plantInfo?['name'] ?? 'Unknown Plant'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _plantInfo!.entries
                .map((e) => Text("${e.key}: ${e.value}"))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"))
        ],
      ),
    );
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
            icon: Icon(Icons.camera_alt_sharp, color: Colors.green),
            onPressed: () async {
              await _captureAndIdentify(context);
            },
          ),
        ],
      ),
    );
  }
}
