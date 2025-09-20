import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MLKitTranslateScreen extends StatefulWidget {
  const MLKitTranslateScreen({Key? key}) : super(key: key);

  @override
  State<MLKitTranslateScreen> createState() => _MLKitTranslateScreenState();
}

class _MLKitTranslateScreenState extends State<MLKitTranslateScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = '';
  late final OnDeviceTranslator _translator;
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.vietnamese,
      targetLanguage: TranslateLanguage.english,
    );
  }

  @override
  void dispose() {
    _translator.close();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) return;
    final result = await _translator.translateText(text);
    setState(() {
      _translatedText = result;
    });
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
        },
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
      appBar: AppBar(title: const Text('ML Kit Translate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  labelText: 'Nhập văn bản',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    label: Text(_isListening ? 'Đang nghe...' : 'Nói'),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Ảnh'),
                    onPressed: _pickImageAndTranslate,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.translate),
                    label: const Text('Dịch'),
                    onPressed: () => _translateText(_inputController.text),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Kết quả:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _translatedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
