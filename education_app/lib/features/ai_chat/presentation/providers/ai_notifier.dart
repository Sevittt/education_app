import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/services/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiNotifier extends ChangeNotifier {
  final AiService _aiService;
  
  AiNotifier(this._aiService);

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _currentStreamingMessage;
  String? get currentStreamingMessage => _currentStreamingMessage;

  String? _error;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _error = null;
    _isLoading = true;
    
    // Add user message immediately
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    try {
      _currentStreamingMessage = "";
      notifyListeners();

      // Stream response
      await for (final chunk in _aiService.streamChat(text)) {
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
    notifyListeners();
  }
}
