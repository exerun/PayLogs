import 'dart:io';

import 'package:flutter/material.dart';
import '../data/ocr_service.dart';

class OcrDemoPage extends StatefulWidget {
  final File imageFile;
  const OcrDemoPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<OcrDemoPage> createState() => _OcrDemoPageState();
}

class _OcrDemoPageState extends State<OcrDemoPage> {
  String? _recognizedText;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runOcr();
  }

  Future<void> _runOcr() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final ocrService = OcrService();
    try {
      final text = await ocrService.recognizeTextFromFile(widget.imageFile);
      setState(() {
        _recognizedText = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      ocrService.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.file(widget.imageFile, height: 200),
                        const SizedBox(height: 16),
                        const Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_recognizedText ?? '', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
      ),
    );
  }
} 