import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class AiService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiService() {
    // Initialize the model with System Instructions for "Sodiq" persona
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
        "Ismingiz Sodiq. Siz sud xodimlarining yaqin hamkasbisiz. "
        "Sodda tilda gapiring. Agar rasm kelsa, undagi xatolarni tahlil qiling. "
        "Javoblaringiz qisqa, lo'nda va foydali bo'lsin. "
        "Texnik atamalarni soddalashtirib tushuntiring."
      ),
    );
    
    _chatSession = _model.startChat();
    debugPrint('AiService: Model initialized successfully (gemini-2.5-flash)');
  }

  // Wrapper to generate content (single response)
  Future<String?> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      debugPrint('AI Service Error: $e');
      rethrow;
    }
  }

  // Wrapper for streaming chat with optional image
  Stream<String> streamChat(String message, {Uint8List? imageBytes}) async* {
    try {
      Content content;
      if (imageBytes != null) {
        // Multimodal input: Text + Image
        content = Content.multi([
          TextPart(message),
          InlineDataPart('image/jpeg', imageBytes),
        ]);
      } else {
        content = Content.text(message);
      }

      final responseStream = _chatSession.sendMessageStream(content);
      
      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      final errorMsg = e.toString();
      debugPrint('AI Stream Error: $errorMsg');
      
      // Provide helpful error messages based on the error type
      if (errorMsg.contains('App Check') || errorMsg.contains('token is invalid')) {
        throw Exception(
          'App Check token yaroqsiz. Firebase Console → App Check bo\'limida '
          'debug tokeningizni ro\'yxatdan o\'tkazing.'
        );
      } else if (errorMsg.contains('API key') || errorMsg.contains('PERMISSION_DENIED')) {
        throw Exception(
          'Firebase AI Logic yoqilmagan. Firebase Console → AI Logic (Build with Gemini) '
          'bo\'limiga kirib, API ni yoqing.'
        );
      } else if (errorMsg.contains('not found') || errorMsg.contains('404')) {
        throw Exception(
          'AI model topilmadi. Firebase loyihangizda Gemini API yoqilganligini tekshiring.'
        );
      }
      
      throw e;
    }
  }
}

