import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

Future<void> processImage(CameraController cameraController) async {
  final image = await cameraController.takePicture();
  final firebaseVisionImage = FirebaseVisionImage.fromFile(image);

  // Face detection
  final faceDetector = FirebaseVision.instance.faceDetector();
  final List<Face> faces = await faceDetector.processImage(firebaseVisionImage);

  // QR code detection
  final barcodeDetector = FirebaseVision.instance.barcodeDetector();
  final List<Barcode> barcodes = await barcodeDetector.processImage(firebaseVisionImage);

  // Process the detected face and QR code
  _drawDetections(firebaseVisionImage.inputImageData!.size, faces, barcodes);
}

void _drawDetections(
    Size imageSize,
    List<Face> faces,
    List<Barcode> barcodes,
    ) {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  // Draw bounding boxes around the detected faces
  for (final face in faces) {
    final rect = _normalizeRect(
      face.boundingBox,
      imageSize.width,
      imageSize.height,
    );
    _drawBoundingBox(canvas, rect, Colors.red);
  }

  // Draw bounding boxes around the detected QR codes
  for (final barcode in barcodes) {
    final rect = _normalizeRect(
      barcode.boundingBox,
      imageSize.width,
      imageSize.height,
    );
    _drawBoundingBox(canvas, rect, Colors.green);
  }

  final picture = recorder.endRecording();
  // Use the picture to update the camera feed or save it as an image
}

Rect _normalizeRect(Rect rect, double imageWidth, double imageHeight) {
  return Rect.fromLTRB(
    rect.left / imageWidth,
    rect.top / imageHeight,
    rect.right / imageWidth,
    rect.bottom / imageHeight,
  );
}

void _drawBoundingBox(Canvas canvas, Rect rect, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  canvas.drawRect(rect, paint);
}