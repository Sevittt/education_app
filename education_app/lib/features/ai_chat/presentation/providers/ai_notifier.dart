import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? imageBytes; // Added for image support

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

  // Method to pick an image
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _selectedImageBytes = await image.readAsBytes();
        notifyListeners();
      }
    } catch (e) {
      _error = "Rasm yuklashda xatolik: $e";
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
    
    // Capture the image bytes to send, then clear selection
    final imageToSend = _selectedImageBytes;
    _selectedImageBytes = null; // Clear immediately after sending starts
    
    // Add user message immediately
    _messages.add(ChatMessage(
      text: text, 
      isUser: true,
      imageBytes: imageToSend,
    ));
    notifyListeners();

    try {
      _currentStreamingMessage = "";
      notifyListeners();

      // Stream response with optional image
      await for (final chunk in _aiService.streamChat(text, imageBytes: imageToSend)) {
        _currentStreamingMessage = (_currentStreamingMessage ?? "") + chunk;
        notifyListeners();
      }

      // Finalize message
      if (_currentStreamingMessage != null && _currentStreamingMessage!.isNotEmpty) {
        _messages.add(ChatMessage(text: _currentStreamingMessage!, isUser: false));
      }
      
      _currentStreamingMessage = null;

    } catch (e) {
      _error = "Xatolik yuz berdi: $e";
      // Add error message as bot response so user sees it
      _messages.add(ChatMessage(text: "Kechirasiz, xatolik yuz berdi. Iltimos qayta urinib ko'ring.", isUser: false));
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
    notifyListeners();
  }
}
