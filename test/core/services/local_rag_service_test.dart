import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:sud_qollanma/core/database/app_database.dart';
import 'package:sud_qollanma/core/services/local_rag_service.dart';

void main() {
  late AppDatabase db;
  late LocalRagService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = LocalRagService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('LocalRagService seeds and retrieves relevant court chunks', () async {
    // 1. Insert sample court chunks
    await db.saveRagChunks([
      RagChunksTableCompanion.insert(
        id: 'chunk_1',
        title: 'DSKEYS va ERI kalitlari standarti',
        module: '2-modul: ERI va Brauzer',
        category: 'e_imzo',
        content:
            'Barcha ERI kalitlari C:\\DSKEYS papkasiga joylashtiriladi. Fayl formati .pfx kengaytmada bo\'ladi.',
        vectorJson: '[0.1, 0.2, 0.3]',
        updatedAt: DateTime.now(),
      ),
      RagChunksTableCompanion.insert(
        id: 'chunk_2',
        title: 'Sud hujjatlarini to\'g\'ri nomlash standarti',
        module: '1-modul: Windows va Ofis',
        category: 'dars',
        content:
            'Fayllarni D: diskda saqlash kerak. Standart: [Ish raqami]_[Hujjat turi]_[F.I.Sh]_[Sana].',
        vectorJson: '[0.4, 0.5, 0.6]',
        updatedAt: DateTime.now(),
      ),
    ]);

    expect(await db.getRagChunksCount(), equals(2));

    // 2. Search by text tokens
    final results = await service.search(query: 'DSKEYS kalitlari');
    expect(results.isNotEmpty, isTrue);
    expect(results.first.id, equals('chunk_1'));
    expect(results.first.title, contains('DSKEYS'));

    // 3. Grounding context generation
    final context = await service.getGroundingContext('C:\\DSKEYS papkasi');
    expect(context, contains('Rasmiy Sud Yo\'riqnomalari'));
    expect(context, contains('DSKEYS va ERI kalitlari standarti'));
  });

  test('Cosine similarity ranks matching vector highest', () async {
    await db.saveRagChunks([
      RagChunksTableCompanion.insert(
        id: 'vec_a',
        title: 'Kesh tozalash',
        module: '2-modul',
        category: 'e_imzo',
        content: 'Brauzer keshini tozalash uchun Ctrl+Shift+Del bosiladi.',
        vectorJson: '[1.0, 0.0, 0.0]',
        updatedAt: DateTime.now(),
      ),
      RagChunksTableCompanion.insert(
        id: 'vec_b',
        title: 'VKA sozlash',
        module: '5-modul',
        category: 'vka',
        content: 'VKA tizimida ovoz va videoni tekshirish.',
        vectorJson: '[0.0, 1.0, 0.0]',
        updatedAt: DateTime.now(),
      ),
    ]);

    // Query close to vec_a: [1.0, 0.0, 0.0]
    final results = await service.search(
      query: 'kesh',
      queryVector: [1.0, 0.0, 0.0],
    );

    expect(results.first.id, equals('vec_a'));
    expect(results.first.score, closeTo(1.0, 0.01));
  });
}
