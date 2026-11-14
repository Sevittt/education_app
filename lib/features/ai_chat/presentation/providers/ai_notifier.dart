import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imageBytes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiNotifier extends ChangeNotifier {
  final AiService _aiService;
  final ImagePicker _picker = ImagePicker();

  AiNotifier(this._aiService);

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _currentStreamingMessage;
  String? get currentStreamingMessage => _currentStreamingMessage;

  String? _error;
  String? get error => _error;

  Uint8List? _selectedImageBytes;
  Uint8List? get selectedImageBytes => _selectedImageBytes;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _selectedImageBytes = await image.readAsBytes();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Rasm yuklashda xatolik: $e';
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    _selectedImageBytes = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty && _selectedImageBytes == null) return;

    _error = null;
    _isLoading = true;

    final imageToSend = _selectedImageBytes;
    _selectedImageBytes = null;

    _messages.add(ChatMessage(text: text, isUser: true, imageBytes: imageToSend));
    notifyListeners();

    try {
      // Kontekst (RAG) serverda olinadi: sodiqChat → rag_chunks_v2
      _currentStreamingMessage = '';
      notifyListeners();

      await for (final chunk in _aiService.streamChat(text, imageBytes: imageToSend)) {
        _currentStreamingMessage = (_currentStreamingMessage ?? '') + chunk;
        notifyListeners();
      }

      if (_currentStreamingMessage != null && _currentStreamingMessage!.isNotEmpty) {
        _messages.add(ChatMessage(text: _currentStreamingMessage!, isUser: false));
      }

      _currentStreamingMessage = null;
    } catch (e) {
      final String errorMessage = e.toString().replaceFirst('Exception: ', '');
      _error = 'Xatolik yuz berdi: $errorMessage';
      _messages.add(ChatMessage(text: errorMessage, isUser: false));
    } finally {
      _isLoading = false;
      _currentStreamingMessage = null;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    _selectedImageBytes = null;
    _aiService.resetSession();
    notifyListeners();
  }
}
