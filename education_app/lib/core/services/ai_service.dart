import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class AiService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiService() {
    // Initialize the model
    // Note: In production, consider using Remote Config for the model name
    // and FirebaseVertexAI.instance instead of FirebaseAI.googleAI() if using Vertex AI for Firebase
    // But since the setup guide used FirebaseAI.googleAI(), we'll stick to that if it's the standard client SDK.
    // Wait, the prompt said "import 'package:firebase_ai/firebase_ai.dart';" and used "FirebaseAI.googleAI()".
    // I need to verify if "firebase_ai" package supports "FirebaseAI.googleAI()". 
    // Actually, the package name in pubspec is "firebase_ai". 
    // Let's assume the provided documentation in ai-logic.md is correct for the installed package version.
    
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-1.5-flash', // Updated to latest flash model or use 'gemini-pro'
    );
    
    _chatSession = _model.startChat();
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

  // Wrapper for streaming chat
  Stream<String> streamChat(String message) async* {
    try {
      final content = Content.text(message);
      final responseStream = _chatSession.sendMessageStream(content);
      
      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      debugPrint('AI Stream Error: $e');
      throw e;
    }
  }
}
