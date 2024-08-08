import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

Future<void> processImage(CameraController cameraController) async {
  try {
    // Ensure the camera is initialized
    await cameraController.initialize();

    // Capture the image
    final image = await cameraController.takePicture();

    // Convert the image to the format required by google_ml_kit
    final inputImage = InputImage.fromFilePath(image.path);

    // Initialize the face detector
    final faceDetector = GoogleMlKit.vision.faceDetector();

    // Process the image for face detection
    final faces = await faceDetector.processImage(inputImage);

    // Check if faces were detected
    if (faces.isNotEmpty) {
      print('Faces detected: ${faces.length}');
      for (var face in faces) {
        print('Face bounding box: ${face.boundingBox}');
      }
    } else {
      print('No faces detected.');
    }

    // Don't forget to release resources
    faceDetector.close();
  } catch (e) {
    print('Error processing image: $e');
  }
}
