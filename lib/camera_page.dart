import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'vision_processor.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _cameraController.initialize();
    } else {
      // Handle the case when no cameras are available
      throw Exception('No cameras found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection App'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Camera is initialized, display the preview and add the button functionality
            return Stack(
              children: [
                CameraPreview(_cameraController),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        await processImage(_cameraController);
                      },
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Camera is initializing
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}