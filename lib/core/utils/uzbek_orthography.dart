/// Oʻzbek lotin yozuvi uchun imlo yordamchilari.
///
/// * [normalizeUzbekApostrophes] — amaldagi alifbo: `o'`/`g'` ni `oʻ`/`gʻ`
///   (U+02BB), tutuq belgisini `ʼ` (U+02BC) ga keltiradi.
/// * [toUzbekNewAlphabet] — 2026-yil 21-oktabrdagi OʻRQ-1184-son qonun
///   boʻyicha yangi alifbo: oʻ→ö, gʻ→ğ, sh→ş, ch→ç (ng va tutuq oʻzgarmaydi).
///
/// Flutter'ga bogʻliq emas: `tool/` skriptlari va testlarda ham ishlatiladi.
library;

/// `oʻ` va `gʻ` dagi belgi (U+02BB).
const String uzOkina = 'ʻ';

/// Tutuq belgisi (U+02BC): maʼlumot, eʼlon.
const String uzTutuq = 'ʼ';

const String _apostrophes = "'‘’`$uzOkina$uzTutuq";

/// Placeholder nomlari (`{userName}`, `{count,`), URL va e-pochta — oʻzgarmaydi.
/// ICU tarmoqlari (`other{...}`, `=1{...}`) matn sifatida oʻgiriladi.
final RegExp _protected = RegExp(
  r'(?<![\w=])\{\w+[},]|https?://\S+|www\.\S+|[\w.+-]+@[\w-]+\.[\w.]+',
);

final RegExp _okina = RegExp('([oOgG])[$_apostrophes]');

final RegExp _tutuq = RegExp(
  '(?<=\\p{L})(?<![oOgG])[$_apostrophes](?=\\p{L})',
  unicode: true,
);

final RegExp _digraph = RegExp('[oOgG]$uzOkina|[sScC][hH]');

const Map<String, String> _newLetters = {
  'o': 'ö', 'O': 'Ö',
  'g': 'ğ', 'G': 'Ğ',
  's': 'ş', 'S': 'Ş',
  'c': 'ç', 'C': 'Ç',
};

/// Amaldagi lotin alifbosi: apostrof turlarini `ʻ` (oʻ, gʻ) va `ʼ` (tutuq) ga
/// keltiradi. Allaqachon toʻgʻri yozilgan matn oʻzgarmaydi.
String normalizeUzbekApostrophes(String text) => _mapUnprotected(
      text,
      (s) => s
          .replaceAllMapped(_okina, (m) => '${m[1]}$uzOkina')
          .replaceAll(_tutuq, uzTutuq),
    );

/// Matnni yangi alifboga oʻtkazadi. Kirish amaldagi alifboda (har qanday
/// apostrof bilan) boʻlishi mumkin; `Isʼhoq` kabi tutuqli soʻzlarda `sʼh`
/// ajralgan holda qoladi.
String toUzbekNewAlphabet(String text) => _mapUnprotected(
      normalizeUzbekApostrophes(text),
      (s) => s.replaceAllMapped(_digraph, (m) => _newLetters[m[0]![0]]!),
    );

String _mapUnprotected(String text, String Function(String) transform) {
  final out = StringBuffer();
  var start = 0;
  for (final m in _protected.allMatches(text)) {
    out
      ..write(transform(text.substring(start, m.start)))
      ..write(m[0]);
    start = m.end;
  }
  out.write(transform(text.substring(start)));
  return out.toString();
}
