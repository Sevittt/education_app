import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class CsvReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateAndShareCourtReport() async {
    try {
      // 1. Fetch data
      final usersSnapshot = await _firestore.collection('users').get();
      
      // Calculate stats per court
      // Key: courtName, Value: Map of stats
      Map<String, Map<String, dynamic>> courtStats = {};

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final courtName = data['courtName'] as String? ?? "Noma'lum sud";
        final xp = (data['xp'] as num?)?.toInt() ?? 0;
        final quizzesPassed = (data['quizzesPassed'] as num?)?.toInt() ?? 0;
        final quizzesAced = (data['totalQuizzesAced'] as num?)?.toInt() ?? 0;
        final sims = (data['simulationsCompleted'] as num?)?.toInt() ?? 0;

        if (!courtStats.containsKey(courtName)) {
          courtStats[courtName] = {
            'usersCount': 0,
            'totalXp': 0,
            'quizzesPassed': 0,
            'quizzesAced': 0,
            'sims': 0,
          };
        }

        courtStats[courtName]!['usersCount'] += 1;
        courtStats[courtName]!['totalXp'] += xp;
        courtStats[courtName]!['quizzesPassed'] += quizzesPassed;
        courtStats[courtName]!['quizzesAced'] += quizzesAced;
        courtStats[courtName]!['sims'] += sims;
      }

      // 2. Prepare CSV data
      List<List<dynamic>> rows = [];
      // Row headers
      rows.add([
        'Sud nomi',
        'Xodimlar soni',
        'Umumiy XP',
        "O'rtacha XP",
        'Muvaffaqiyatli testlar',
        "A'lo testlar",
        'Tugatilgan simulyatsiyalar'
      ]);

      // Row data
      courtStats.forEach((courtName, stats) {
        final usersCount = stats['usersCount'] as int;
        final totalXp = stats['totalXp'] as int;
        final avgXp = usersCount > 0 ? (totalXp / usersCount).toStringAsFixed(1) : '0';

        rows.add([
          courtName,
          usersCount,
          totalXp,
          avgXp,
          stats['quizzesPassed'],
          stats['quizzesAced'],
          stats['sims']
        ]);
      });

      // 3. Convert to CSV string with CRLF line endings (Excel compat)
      StringBuffer csvBuffer = StringBuffer();
      for (var row in rows) {
        final rowString = row.map((e) {
          final s = e.toString();
          if (s.contains(',') || s.contains('"') || s.contains('\n')) {
            return '"${s.replaceAll('"', '""')}"';
          }
          return s;
        }).join(',');
        csvBuffer.write('$rowString\r\n');
      }
      final String csvData = csvBuffer.toString();

      // 4. UTF-8 BOM + proper encoding (fixes Cyrillic/Uzbek chars in Excel)
      final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csvData)]);

      // 5. Share file using modern share_plus API
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'text/csv',
              name: 'sud_faollik_hisoboti.csv',
            )
          ],
          text: "Sudlar bo'yicha xodimlar faolligi hisoboti",
        ),
      );
    } catch (e) {
      throw Exception('Hisobot yaratishda xatolik: $e');
    }
  }
}
