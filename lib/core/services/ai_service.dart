import 'package:firebase_ai/firebase_ai.dart';
import 'dart:typed_data';
import 'logger_service.dart';

class AiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _initialized = false;

  bool get isAvailable => true;

  Future<void> _initModelIfNeeded() async {
    if (_initialized && _chatSession != null) return;

    try {
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topP: 0.8,
          topK: 40,
        ),
        systemInstruction: Content.system(_systemPrompt),
      );

      _chatSession = _model!.startChat();
      _initialized = true;
      LoggerService().log('AiService: initialized (gemini-2.5-flash, RAG-ready)');
    } catch (e, stack) {
      LoggerService().recordError(e, stack, reason: 'AiService: init failed');
      throw Exception('AI modelini ishga tushirishda xatolik yuz berdi.');
    }
  }

  static const String _systemPrompt =
      'Ismingiz Sodiq. Siz Uzbekiston sud xodimlarining raqamli yordamchisisiz.\n\n'

      'ASOSIY SOHA — quyidagi mavzularda to\'liq mutaxassis:\n'
      '• E-SUD, E-XAT, VKA, 1C, MSSQL, E-IMZO, kiberxavfsizlik\n'
      '• Sudlov tizimining barcha IT dasturlari\n\n'

      'KENGAYTIRILGAN YORDAM — agar savol yuqoridagi sohalardan tashqarida bo\'lsa:\n'
      '• Umumiy IT, dasturlash, kompyuter va texnologiya savollari bo\'yicha yordam ber\n'
      '• Iloji boricha foydali bo\'l, haddan ziyod cheklamadan\n'
      '• Agar bu ilova orqali hali qo\'llab-quvvatlanmasa: '
      '"Bu xususiyat tez orada qo\'shilishi rejalashtirilgan" de va '
      'muqobil manbalar (Google, YouTube, rasmiy hujjatlar) tavsiya et\n\n'

      'CHEKLOVLAR:\n'
      '• Yuridik maslahat berma\n'
      '• Tibbiy, moliyaviy va shaxsiy hayotiy maslahatlar berma\n'
      '• Siyosat, din va nizoli ijtimoiy masalalardan chetlan\n\n'

      'Agar xabarda "--- Kontekst ---" bo\'limi mavjud bo\'lsa:\n'
      '• O\'sha kontekstdagi ma\'lumotlarga tayan\n'
      '• Kontekstda javob topilmasa ham umumiy bilimingdan yordam ber\n\n'

      'Suhbat qoidalari:\n'
      '1. Faqat birinchi xabardagina salomlash\n'
      '2. O\'zbek tilida (Lotin) gapir\n'
      '3. Qisqa, to\'g\'ridan-to\'g\'ri javob ber\n'
      '4. Tabiiy, do\'stona ohangda yoz';

  static String _augment(String userMessage, String? context) {
    if (context == null || context.trim().isEmpty) return userMessage;
    return '--- Kontekst ---\n$context\n\n--- Foydalanuvchi savoli ---\n$userMessage';
  }

  Future<String?> generateContent(String prompt, {String? context}) async {
    await _initModelIfNeeded();
    if (prompt.trim().isEmpty) return null;

    try {
      final response =
          await _model!.generateContent([Content.text(_augment(prompt, context))]);
      return response.text;
    } catch (e, stack) {
      LoggerService().recordError(e, stack, reason: 'AiService: generateContent');
      throw Exception('AI xizmatida xatolik. Internetingizni tekshiring.');
    }
  }

  Stream<String> streamChat(
    String message, {
    Uint8List? imageBytes,
    String? context,
  }) async* {
    await _initModelIfNeeded();
    if (message.trim().isEmpty && imageBytes == null) return;

    try {
      final Content content;
      if (imageBytes != null) {
        content = Content.multi([
          TextPart(_augment(message, context)),
          InlineDataPart('image/jpeg', imageBytes),
        ]);
      } else {
        content = Content.text(_augment(message, context));
      }

      await for (final chunk in _chatSession!.sendMessageStream(content)) {
        if (chunk.text != null) yield chunk.text!;
      }
    } catch (e, stack) {
      final msg = e.toString();
      LoggerService().recordError(e, stack, reason: 'AiService: streamChat');

      if (msg.contains('App Check') || msg.contains('token is invalid')) {
        throw Exception('App Check token yaroqsiz. Firebase Console → App Check bo\'limida '
            'debug tokeningizni ro\'yxatdan o\'tkazing.');
      } else if (msg.contains('API key') || msg.contains('PERMISSION_DENIED')) {
        throw Exception('Firebase AI Logic yoqilmagan. Firebase Console → AI Logic '
            'bo\'limiga kirib, API ni yoqing.');
      } else if (msg.contains('not found') || msg.contains('404')) {
        throw Exception('AI model topilmadi. Firebase loyihangizda Gemini API yoqilganligini tekshiring.');
      }
      throw Exception('AI xizmatida xatolik. Sabab: $msg');
    }
  }

  void resetSession() {
    _chatSession = _model?.startChat();
    LoggerService().log('AiService: chat session reset');
  }
}
