import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

/// Veb platforma (Chrome, Web Server) uchun WASM asosidagi SQLite ulanishi.
QueryExecutor connect() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'sud_qollanma_local',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      debugPrint(
        'Drift Web: Browser xususiyatlari yetishmasligi sababli ${result.chosenImplementation} tanlandi: ${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  }));
}
