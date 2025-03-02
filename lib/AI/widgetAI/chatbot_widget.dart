import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../serviceai/deepseek_service.dart';
import '../serviceai/ocr_service.dart';

class ChatBotWidget extends StatefulWidget {
  final Function(String) onCodeGenerated;
  final VoidCallback onFocusRequested;

  const ChatBotWidget({
    super.key,
    required this.onCodeGenerated,
    required this.onFocusRequested,
  });

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final TextEditingController _controller = TextEditingController();
  final DeepSeekService _deepSeek = DeepSeekService();
  final OCRService _ocr = OCRService();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  String? _lastError;

  Future<void> _generateAndInsert() async {
    if (_controller.text.isEmpty && _selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    try {
      String prompt = _controller.text;
      if (_selectedImage != null) {
        final ocrText = await _ocr.extractTextFromImage(_selectedImage!);
        prompt = '''
        Gere código Dart/Flutter que corresponda a estes requisitos:
        (Extraído da imagem via OCR)
        
        $ocrText
        ''';
      }

      final code = await _deepSeek.hybridGeneration(prompt);
      widget.onCodeGenerated(code);
      _controller.clear();
      widget.onFocusRequested();
    } catch (e) {
      setState(() => _lastError = 'Erro: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
        _selectedImage = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _selectedImage = File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  if (_isProcessing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _isProcessing ? null : _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Descreva o que quer codar....",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      onPressed: _isProcessing ? null : _generateAndInsert,
                    ),
                  ),
                  onSubmitted: (_) => _generateAndInsert(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}