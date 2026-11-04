import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Mobil va desktop (Windows, macOS, Linux, Android, iOS) uchun SQLite ulanishi.
QueryExecutor connect() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sud_qollanma_local.db'));
    return NativeDatabase.createInBackground(file);
  });
}
