import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'logger_service.dart';

class AiService {
  final FirebaseFunctions _functions;
  final List<Map<String, String>> _history = [];

  static const int _maxHistoryTurns = 16;

  AiService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  bool get isAvailable => true;

  Future<String?> generateContent(String prompt, {String? context}) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return null;

    try {
      final result = await _functions
          .httpsCallable(
            'sodiqChat',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
          )
          .call<Map<String, dynamic>>({
        'mode': 'wiki',
        'message': trimmed,
        if (context != null && context.trim().isNotEmpty) 'context': context,
      });

      final text = result.data['text'] as String?;
      return text?.trim().isEmpty == true ? null : text;
    } on FirebaseFunctionsException catch (e, stack) {
      LoggerService().recordError(e, stack, reason: 'AiService: generateContent');
      throw Exception(mapFunctionsError(e));
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
    final trimmed = message.trim();
    if (trimmed.isEmpty && imageBytes == null) return;

    try {
      final payload = <String, dynamic>{
        'mode': 'chat',
        'message': trimmed,
        'history': List<Map<String, String>>.from(_history),
      };
      if (context != null && context.trim().isNotEmpty) {
        payload['context'] = context;
      }
      if (imageBytes != null && imageBytes.isNotEmpty) {
        payload['imageBase64'] = base64Encode(imageBytes);
        payload['imageMimeType'] = detectImageMimeType(imageBytes);
      }

      final result = await _functions
          .httpsCallable(
            'sodiqChat',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
          )
          .call<Map<String, dynamic>>(payload);

      final reply = (result.data['text'] as String?) ?? '';
      if (reply.isEmpty) {
        throw Exception('AI javob qaytarmadi. Qaytadan urinib ko\'ring.');
      }

      final userTurnText =
          trimmed.isNotEmpty ? trimmed : '[Rasm yuborildi]';
      _appendTurn('user', userTurnText);
      _appendTurn('model', reply);

      yield reply;
    } on FirebaseFunctionsException catch (e, stack) {
      LoggerService().recordError(e, stack, reason: 'AiService: streamChat');
      throw Exception(mapFunctionsError(e));
    } catch (e, stack) {
      LoggerService().recordError(e, stack, reason: 'AiService: streamChat');
      final msg = e.toString().replaceFirst('Exception: ', '');
      throw Exception('AI xizmatida xatolik. Sabab: $msg');
    }
  }

  void _appendTurn(String role, String text) {
    _history.add({'role': role, 'text': text});
    if (_history.length > _maxHistoryTurns) {
      _history.removeRange(0, _history.length - _maxHistoryTurns);
    }
  }

  void resetSession() {
    _history.clear();
    LoggerService().log('AiService: chat session reset');
  }

  static String detectImageMimeType(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  static String mapFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'AI yordamchidan foydalanish uchun tizimga kiring.';
      case 'resource-exhausted':
        return 'AI so\'rovlar limiti vaqtincha tugadi. Birozdan so\'ng urinib ko\'ring.';
      case 'failed-precondition':
        return e.message ??
            'Serverdagi Gemini API kaliti sozlanmagan yoki yaroqsiz.';
      case 'deadline-exceeded':
      case 'unavailable':
        return 'AI server bilan bog\'lanib bo\'lmadi. Internetingizni tekshiring.';
      default:
        final detail = e.message;
        return (detail != null && detail.isNotEmpty)
            ? detail
            : 'AI xizmatida xatolik yuz berdi (${e.code}).';
    }
  }
}
