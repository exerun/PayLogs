import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  // Use only the Latin (English) script for text recognition
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Runs OCR on the given image file and returns the recognized text.
  Future<String> recognizeTextFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Optionally, you can extract blocks, lines, or elements for more advanced parsing.
  Future<RecognizedText> recognizeDetailedText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    return await _textRecognizer.processImage(inputImage);
  }

  void dispose() {
    _textRecognizer.close();
  }
} 