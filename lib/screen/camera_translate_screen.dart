import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'dart:async';

class CameraTranslateScreen extends StatefulWidget {
  const CameraTranslateScreen({Key? key}) : super(key: key);

  @override
  State<CameraTranslateScreen> createState() => _CameraTranslateScreenState();
}

class _CameraTranslateScreenState extends State<CameraTranslateScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  String _recognizedText = '';
  String _translatedText = '';
  bool _isTranslating = false;
  late OnDeviceTranslator _translator;
  TranslateLanguage _sourceLang = TranslateLanguage.vietnamese;
  TranslateLanguage _targetLang = TranslateLanguage.english;
  Timer? _translationTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLang,
      targetLanguage: _targetLang,
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Tắt flash sau khi camera đã khởi tạo
      await _cameraController!.setFlashMode(FlashMode.off);
      setState(() {
        _isInitialized = true;
      });

      // Bắt đầu nhận diện văn bản mỗi 2 giây
      _startTextRecognition();
    }
  }

  void _startTextRecognition() {
    _translationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _recognizeText();
      }
    });
  }

  Future<void> _recognizeText() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      textRecognizer.close();

      if (recognizedText.text.isNotEmpty) {
        setState(() {
          _recognizedText = recognizedText.text;
        });

        // Tự động dịch văn bản
        await _translateText(recognizedText.text);
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final result = await _translator.translateText(text);
      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
    _updateTranslator();
  }

  Future<void> _updateTranslator() async {
    await _translator.close();
    setState(() {
      _translator = OnDeviceTranslator(
        sourceLanguage: _sourceLang,
        targetLanguage: _targetLang,
      );
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _translator.close();
    _translationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(child: CameraPreview(_cameraController!)),

          // Top Controls
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLanguageCard(
                      'Từ',
                      _sourceLang == TranslateLanguage.vietnamese
                          ? 'Tiếng Việt'
                          : 'English',
                      Colors.blue.shade100,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _swapLanguages,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLanguageCard(
                      'Sang',
                      _targetLang == TranslateLanguage.vietnamese
                          ? 'Tiếng Việt'
                          : 'English',
                      Colors.green.shade100,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Translation Results
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Recognized Text
                  if (_recognizedText.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        _recognizedText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],

                  // Translated Text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        if (_isTranslating) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            _translatedText.isEmpty
                                ? 'Kết quả dịch sẽ hiển thị ở đây...'
                                : _translatedText,
                            style: TextStyle(
                              color: _translatedText.isEmpty
                                  ? Colors.grey.shade500
                                  : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
    String label,
    String language,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            language,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
