import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;

class MainPage extends StatefulWidget {
  final String username;
  const MainPage({super.key, required this.username});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _detectionResult;
  bool _isDetecting = false;
  OrtSession? _session;
  List<String> _classNames = [];
  bool _modelLoaded = false;

  Future<void> _showImageSourcePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Capture from Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedImageBytes = bytes;
        _detectionResult = null;
      });
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _loadModelIfNeeded() async {
    if (_modelLoaded) return;

    OrtEnv.instance.init();
    final modelBytes = await rootBundle.load("assets/models/pest-best-model.onnx");
    final options = OrtSessionOptions();
    _session = OrtSession.fromBuffer(modelBytes.buffer.asUint8List(), options);

    final classList = await rootBundle.loadString('assets/class_names.txt');
    _classNames = classList.split('\n').map((e) => e.trim()).toList();

    _modelLoaded = true;
  }

  Future<void> _runDetection() async {
    setState(() => _isDetecting = true);

    try {
      await _loadModelIfNeeded();

      if (_selectedImageBytes == null) {
        setState(() {
          _detectionResult = "❌ No image selected.";
          _isDetecting = false;
        });
        return;
      }

      final img.Image? image = img.decodeImage(_selectedImageBytes!);
      if (image == null) {
        setState(() {
          _detectionResult = "❌ Failed to decode image.";
          _isDetecting = false;
        });
        return;
      }

      final resized = img.copyResize(image, width: 640, height: 640);
      final rgb = resized.getBytes(order: img.ChannelOrder.rgb);

      Float32List inputTensor = Float32List(1 * 3 * 640 * 640);
      int idx = 0;
      for (int c = 0; c < 3; c++) {
        for (int y = 0; y < 640; y++) {
          for (int x = 0; x < 640; x++) {
            inputTensor[idx++] = rgb[(y * 640 + x) * 3 + c] / 255.0;
          }
        }
      }

      final input = OrtValueTensor.createTensorWithDataList(
          inputTensor, [1, 3, 640, 640]);
      final result = await _session!.runAsync(
          OrtRunOptions(), {"images": input});
      final outputRaw = result?[0]?.value;

      if (outputRaw is! List) {
        setState(() {
          _detectionResult = "❌ Invalid model output format.";
          _isDetecting = false;
        });
        return;
      }

      List<List<double>> detections = List<List<double>>.from(
          (outputRaw)[0].map((e) => List<double>.from(e))
      );

      input.release();
      result?.forEach((e) => e?.release());
      const objThresh = 0.25;
      const clsThresh = 0.25;
      String finalResult = "❌ No confident pest detection found.";

      for (var det in detections) {
        double objConf = det[4];
        if (objConf < objThresh) continue;

        List<double> classScores = det.sublist(5);
        int classId = 0;
        double maxConf = classScores[0];
        for (int i = 1; i < classScores.length; i++) {
          if (classScores[i] > maxConf) {
            maxConf = classScores[i];
            classId = i;
          }
        }

        if (maxConf > clsThresh) {
          String pest = _classNames[classId];
          int confidence = (maxConf * 100).toInt();
          finalResult = "🪲 Detected Pest: $pest\nConfidence: $confidence%";
          break;
        }
      }
      setState(() {
        _detectionResult = finalResult;
        _isDetecting = false;
      });
    } catch (e) {
      setState(() {
        _detectionResult = "❌ Error during detection: $e";
        _isDetecting = false;
      });
    }
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Container(
            color: Colors.green,
            padding: EdgeInsets.only(top: 30, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hey, ${widget.username} 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedImage != null) ...[
                  Image.file(_selectedImage!, height: 300),
                  SizedBox(height: 20),
                  if (_detectionResult != null)
                    Container(
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        _detectionResult!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isDetecting ? null : _runDetection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: _isDetecting
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("Detecting..."),
                      ],
                    )
                        : Text("Detect"),
                  ),
                ] else
                  ...[
                    Icon(Icons.camera_alt, size: 80, color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      "Tap to pick or capture an image",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _showImageSourcePicker,
                  icon: Icon(Icons.add_a_photo),
                  label: Text("Pick / Capture"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }


