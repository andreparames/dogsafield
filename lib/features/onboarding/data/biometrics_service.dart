import 'dart:io';
import 'dart:ui' show Rect;
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class BiometricsResult {
  final int personCount;
  final int dogCount;
  final Rect? humanTargetFaceCoordinates;

  const BiometricsResult({
    required this.personCount,
    required this.dogCount,
    this.humanTargetFaceCoordinates,
  });
}

class BiometricsService {
  ObjectDetector? _detector;

  ObjectDetector _getDetector() {
    if (_detector == null) {
      final options = ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      );
      _detector = ObjectDetector(options: options);
    }
    return _detector!;
  }

  Future<BiometricsResult> analyzeImage(String imagePath) async {
    final detector = _getDetector();
    final inputImage = InputImage.fromFile(File(imagePath));
    final objects = await detector.processImage(inputImage);

    Rect? personRect;
    int personCount = 0;
    int dogCount = 0;

    for (final object in objects) {
      final text = object.labels.isNotEmpty ? object.labels.first.text.toLowerCase() : '';
      if (text == 'person') {
        personCount++;
        if (personRect == null) {
          personRect = object.boundingBox;
        }
      } else if (text == 'dog') {
        dogCount++;
      }
    }

    close();

    return BiometricsResult(
      personCount: personCount,
      dogCount: dogCount,
      humanTargetFaceCoordinates: personCount == 1 ? personRect : null,
    );
  }

  void close() {
    _detector?.close();
    _detector = null;
  }
}
