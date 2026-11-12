import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/core/providers/locale_provider.dart';
import 'package:sud_qollanma/core/utils/uzbek_orthography.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

Map<String, String> _messages(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };
}

void main() {
  const regenerate = 'Qayta yarating: dart run tool/generate_uz_new_alphabet.dart';
  final uz = _messages('lib/l10n/app_uz.arb');
  final newAlphabet = _messages('lib/l10n/app_uz_Latn.arb');

  test('app_uz.arb da oʻ/gʻ va tutuq belgilari toʻgʻri', () {
    for (final e in uz.entries) {
      expect(normalizeUzbekApostrophes(e.value), e.value, reason: '${e.key}. $regenerate');
    }
  });

  test('app_uz_Latn.arb app_uz.arb bilan mos (yangi alifbo)', () {
    expect(newAlphabet.keys.toSet(), uz.keys.toSet(), reason: regenerate);
    for (final e in uz.entries) {
      expect(newAlphabet[e.key], toUzbekNewAlphabet(e.value), reason: '${e.key}. $regenerate');
    }
  });

  test('alifbo tanlovi mos tarjima klassiga ulanadi', () {
    expect(lookupAppLocalizations(const Locale('uz')).appTitle, 'Sud qoʻllanma');
    expect(lookupAppLocalizations(LocaleProvider.uzNewAlphabet).appTitle, 'Sud qöllanma');
    expect(AppLocalizations.supportedLocales, contains(LocaleProvider.uzNewAlphabet));
  });
}
