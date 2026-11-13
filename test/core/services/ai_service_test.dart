import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/core/services/ai_service.dart';

void main() {
  group('AiService helpers', () {
    test('detectImageMimeType recognizes PNG, WEBP and defaults to JPEG', () {
      expect(
        AiService.detectImageMimeType(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D])),
        'image/png',
      );
      expect(
        AiService.detectImageMimeType(
          Uint8List.fromList([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50]),
        ),
        'image/webp',
      );
      expect(
        AiService.detectImageMimeType(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])),
        'image/jpeg',
      );
    });

    test('mapFunctionsError returns clear localized messages without App Check confusion', () {
      expect(
        AiService.mapFunctionsError(
          FirebaseFunctionsException(code: 'unauthenticated', message: 'Auth required'),
        ),
        contains('tizimga kiring'),
      );
      expect(
        AiService.mapFunctionsError(
          FirebaseFunctionsException(code: 'resource-exhausted', message: 'Quota'),
        ),
        contains('limiti'),
      );
      expect(
        AiService.mapFunctionsError(
          FirebaseFunctionsException(
            code: 'failed-precondition',
            message: 'Gemini API kaliti yaroqsiz',
          ),
        ),
        'Gemini API kaliti yaroqsiz',
      );
    });
  });
}
