import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:async';

class MLKitTranslateScreen extends StatefulWidget {
  const MLKitTranslateScreen({Key? key}) : super(key: key);

  @override
  State<MLKitTranslateScreen> createState() => _MLKitTranslateScreenState();
}

class _MLKitTranslateScreenState extends State<MLKitTranslateScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = '';
  late OnDeviceTranslator _translator;
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceText = '';
  TranslateLanguage _sourceLang = TranslateLanguage.vietnamese;
  TranslateLanguage _targetLang = TranslateLanguage.english;
  Timer? _autoTranslateTimer;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLang,
      targetLanguage: _targetLang,
    );
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _translator.close();
    _inputController.dispose();
    _autoTranslateTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    // Hủy timer cũ nếu có
    _autoTranslateTimer?.cancel();

    // Tạo timer mới để auto translate sau 1 giây
    _autoTranslateTimer = Timer(const Duration(seconds: 1), () {
      if (_inputController.text.isNotEmpty) {
        _translateText(_inputController.text);
      }
    });
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

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _voiceText = val.recognizedWords;
            _inputController.text = _voiceText;
          });

          // Tự động dừng nghe khi có kết quả và không còn đang nghe
          if (val.finalResult) {
            _stopListening();
          }
        },
        localeId: _sourceLang == TranslateLanguage.vietnamese
            ? 'vi_VN'
            : 'en_US',
        listenFor: const Duration(seconds: 5), // Tự động dừng sau 5 giây
        pauseFor: const Duration(seconds: 2), // Tạm dừng sau 2 giây im lặng
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _pickImageAndTranslate() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      textRecognizer.close();
      _inputController.text = recognizedText.text;
      _translateText(recognizedText.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dịch thuật',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Language Selection with Swap Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
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
                      const SizedBox(width: 16),
                      // Swap Button
                      GestureDetector(
                        onTap: _swapLanguages,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Nhập văn bản',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Nhập văn bản cần dịch...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue.shade600,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    minLines: 3,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Voice Button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                          label: Text(_isListening ? 'Đang nghe...' : 'Nói'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isListening
                                ? Colors.red.shade600
                                : Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _isListening
                              ? _stopListening
                              : _startListening,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Image Button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('Ảnh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _pickImageAndTranslate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Translation Result
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Kết quả dịch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (_isTranslating) ...[
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      _translatedText.isEmpty
                          ? 'Kết quả dịch sẽ hiển thị ở đây...'
                          : _translatedText,
                      style: TextStyle(
                        fontSize: 16,
                        color: _translatedText.isEmpty
                            ? Colors.grey.shade500
                            : Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            language,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
