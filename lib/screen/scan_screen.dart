/*import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

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

  Future<void> _captureAndIdentify() async {
    if (!(_cameraController?.value.isInitialized ?? false)) return;
    try {
      final picture = await _cameraController!.takePicture();
      File imageFile = File(picture.path);
      print("Image saved at: ${picture.path}");
      _showMessage("Uploading image...");
      await _uploadImageAndFetchPlantInfo(imageFile);
    } catch (e) {
      _showMessage("Error capturing image: $e", isError: true);
    }
  }

  Future<void> _uploadImageAndFetchPlantInfo(File picture) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      _showMessage("Authentication required!", isError: true);
      return;
    }
    /*if (!picture.path.toLowerCase().endsWith('.jpg')) {
      _showMessage("Only .jpg files are supported!", isError: true);
      return;
    }*/

    try {
      //Uint8List imageBytes = await picture.readAsBytes();
      var url = Uri.parse(
          "https://plant-explorer-backend-0-0-1.onrender.com/api/scan-histories/identify");
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          picture.path,
          contentType: MediaType('image', 'jpg'),
        ));

      var response = await request.send();
      //Debug log response
      var responseBody = await response.stream.bytesToString();
      print("Response: ${response.statusCode} - $responseBody");

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
              icon: Icon(Icons.camera_alt_sharp, color: Colors.green),
              onPressed: _captureAndIdentify),
        ],
      ),
    );
  }
}*/

//--------------------------------------------------------------------

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Function to capture an image from the camera
  Future<void> _captureImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Small delay to prevent OpenGL crash
      await Future.delayed(Duration(milliseconds: 300));

      await _uploadImage(_image!);
    }
  }

  // Function to upload the image to the backend API
  Future<void> _uploadImage(File imageFile) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      print("Authentication required!");
      return;
    }
    var uri = Uri.parse(
        'https://plant-explorer-backend-0-0-1.onrender.com/api/scan-histories/identify');

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..files.add(
        await http.MultipartFile.fromPath(
          'file', // Make sure this matches API expectations
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    var response = await request.send();

    if (response.statusCode == 200) {
      /*var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (jsonResponse.containsKey('cacheKey')) {
        print('Cache Key: ${jsonResponse['cacheKey']}'); // Prints the cache key
      } else {
        print('Image uploaded, but no cache key found.');
      }*/
      var cacheKey = await response.stream.bytesToString();
      if (cacheKey.isNotEmpty) {
        print('Response from server: $cacheKey');
      } else {
        print('Response is empty or null');
      }
    } else {
      print('Image upload failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Plant'),
      ),
      body: Center(
        child:
            _image == null ? Text('No image captured.') : Image.file(_image!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        tooltip: 'Capture Image',
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
