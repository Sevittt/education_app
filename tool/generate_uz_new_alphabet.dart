// Oʻzbekcha ARB fayllarini imlo boʻyicha yangilaydi:
//  1. lib/l10n/app_uz.arb — apostroflarni oʻ/gʻ (ʻ) va tutuq (ʼ) ga keltiradi;
//  2. lib/l10n/app_uz_Latn.arb — yangi alifbo (Ö, Ğ, Ş, Ç) variantini yaratadi.
//
// `uz_Latn` — gen-l10n alifbo variantini faqat skript kodi orqali ajrata olgani
// uchun yangi alifboga ajratilgan teg; oddiy `uz` — amaldagi lotin alifbosi.
//
// app_uz.arb oʻzgargandan keyin (loyiha ildizida):
//   dart run tool/generate_uz_new_alphabet.dart && flutter gen-l10n
import 'dart:convert';
import 'dart:io';

import 'package:sud_qollanma/core/utils/uzbek_orthography.dart';

void main() {
  final uzFile = File('lib/l10n/app_uz.arb');
  final raw = uzFile.readAsStringSync();
  final eol = raw.contains('\r\n') ? '\r\n' : '\n';
  final trailing = raw.substring(raw.lastIndexOf('}') + 1);
  final uz = jsonDecode(raw) as Map<String, dynamic>;

  final normalized = uz.map(
    (key, value) => MapEntry(
      key,
      _isMessage(key, value) ? normalizeUzbekApostrophes(value as String) : value,
    ),
  );
  final newAlphabet = <String, dynamic>{
    '@@locale': 'uz_Latn',
    for (final e in normalized.entries)
      if (_isMessage(e.key, e.value)) e.key: toUzbekNewAlphabet(e.value as String),
  };

  _write(uzFile, normalized, eol, trailing);
  _write(File('lib/l10n/app_uz_Latn.arb'), newAlphabet, eol, eol);
  stdout.writeln(
    'app_uz.arb normallashtirildi, app_uz_Latn.arb yaratildi '
    '(${newAlphabet.length - 1} ta matn).',
  );
}

bool _isMessage(String key, Object? value) =>
    !key.startsWith('@') && value is String;

void _write(File file, Map<String, dynamic> json, String eol, String trailing) {
  final text = const JsonEncoder.withIndent('  ').convert(json);
  file.writeAsStringSync('${text.replaceAll('\n', eol)}$trailing');
}
