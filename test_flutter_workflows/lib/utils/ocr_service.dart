import 'package:flutter/material.dart';
import 'package:flutter_native_ocr/flutter_native_ocr.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  final _flutterNativeOcr = FlutterNativeOcr();
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from camera and performs OCR
  Future<String?> captureAndRecognizeText(BuildContext context) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing image...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Pick image from camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        // User cancelled
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        return null;
      }

      // Perform OCR
      final text = await _flutterNativeOcr.recognizeText(image.path);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Clean up the recognized text (remove extra whitespace)
      final cleanedText = text.trim();

      if (cleanedText.isEmpty) {
        if (context.mounted) {
          _showSnackBar(context, 'No text found in the image');
        }
        return null;
      }

      return cleanedText;
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, 'Error: ${e.toString()}');
      }
      debugPrint('OCR Error: $e');
      return null;
    }
  }

  /// Picks an image from gallery and performs OCR
  Future<String?> pickAndRecognizeText(BuildContext context) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing image...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        // User cancelled
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        return null;
      }

      // Perform OCR
      final text = await _flutterNativeOcr.recognizeText(image.path);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Clean up the recognized text (remove extra whitespace)
      final cleanedText = text.trim();

      if (cleanedText.isEmpty) {
        if (context.mounted) {
          _showSnackBar(context, 'No text found in the image');
        }
        return null;
      }

      return cleanedText;
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, 'Error: ${e.toString()}');
      }
      debugPrint('OCR Error: $e');
      return null;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
