import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/core/utils/uzbek_orthography.dart';

void main() {
  group('normalizeUzbekApostrophes', () {
    test("o' va g' ni oʻ/gʻ ga keltiradi", () {
      expect(normalizeUzbekApostrophes("Sud qo'llanma"), 'Sud qoʻllanma');
      expect(normalizeUzbekApostrophes("To'g'ri"), 'Toʻgʻri');
      expect(normalizeUzbekApostrophes('O‘zbek tili'), 'Oʻzbek tili');
      expect(normalizeUzbekApostrophes("Yorug' rejim"), 'Yorugʻ rejim');
    });

    test('harflar orasidagi boshqa apostrof — tutuq belgisi', () {
      expect(normalizeUzbekApostrophes("Ma'lumot"), 'Maʼlumot');
      expect(normalizeUzbekApostrophes('E’lon'), 'Eʼlon');
      expect(normalizeUzbekApostrophes("A'lo"), 'Aʼlo');
    });

    test('toʻgʻri matn va placeholderlar oʻzgarmaydi', () {
      expect(normalizeUzbekApostrophes('Toʻgʻri maʼlumot'), 'Toʻgʻri maʼlumot');
      expect(normalizeUzbekApostrophes("{userName} bo'limi"), '{userName} boʻlimi');
    });
  });

  group('toUzbekNewAlphabet', () {
    test('oʻ→ö, gʻ→ğ, sh→ş, ch→ç', () {
      expect(toUzbekNewAlphabet('Oʻzbekiston'), 'Özbekiston');
      expect(toUzbekNewAlphabet('Toʻgʻri'), 'Töğri');
      expect(toUzbekNewAlphabet('Bosh sahifa'), 'Boş sahifa');
      expect(toUzbekNewAlphabet('Chiqish'), 'Çiqiş');
      expect(toUzbekNewAlphabet('Barchasi'), 'Barçasi');
    });

    test('bosh harf va katta harfli soʻzlar', () {
      expect(toUzbekNewAlphabet('Gʻalaba'), 'Ğalaba');
      expect(toUzbekNewAlphabet('Shaxs'), 'Şaxs');
      expect(toUzbekNewAlphabet('OʻZBEK SHAXSI'), 'ÖZBEK ŞAXSI');
      expect(toUzbekNewAlphabet('F.I.Sh.'), 'F.I.Ş.');
    });

    test("eski apostrofli kirishni ham qabul qiladi", () {
      expect(toUzbekNewAlphabet("o'qish"), 'öqiş');
      expect(toUzbekNewAlphabet("Sud qo'llanma"), 'Sud qöllanma');
    });

    test('ng, tutuq va ajralgan sʼh oʻzgarmaydi', () {
      expect(toUzbekNewAlphabet('Yangilash'), 'Yangilaş');
      expect(toUzbekNewAlphabet('Maʼlumot'), 'Maʼlumot');
      expect(toUzbekNewAlphabet("Is'hoq"), 'Isʼhoq');
    });

    test('placeholder, URL va e-pochta himoyalangan', () {
      expect(toUzbekNewAlphabet('{chapterName} boʻlimi'), '{chapterName} bölimi');
      expect(
        toUzbekNewAlphabet('{shareCount, plural, other{bosh}}'),
        '{shareCount, plural, other{boş}}',
      );
      expect(
        toUzbekNewAlphabet('Koʻrish: https://youtube.com/watch?v=abc'),
        'Köriş: https://youtube.com/watch?v=abc',
      );
      expect(
        toUzbekNewAlphabet('Yozing: shikoyat@sud.uz'),
        'Yozing: shikoyat@sud.uz',
      );
    });
  });
}
