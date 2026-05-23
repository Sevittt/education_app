import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sud_qollanma/core/database/app_database.dart';
import 'package:sud_qollanma/core/services/sync/outbox_action_model.dart';

/// Oflayn rejimda to'plangan Outbox amallarini Firestore-ga idempotent
/// usulda yuklash uchun mo'ljallangan fon sinxronizatsiya xizmati.
///
/// [triggerSync] metodini chaqirib sinxronizatsiyani qo'lda ishga tushirish
/// yoki tarmoq ulanishida avtomatik ishga tushurish uchun [listenToConnectivity]
/// metodini chaqiring.
class SyncWorker {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  bool _isSyncing = false;

  SyncWorker({
    required AppDatabase db,
    required FirebaseFirestore firestore,
    Connectivity? connectivity,
  })  : _db = db,
        _firestore = firestore,
        _connectivity = connectivity ?? Connectivity();

  /// Tarmoq ulanish o'zgarishlarini kuzatadi.
  /// Tarmoq qayta ulanganda avtomatik sinxronizatsiya ishga tushadi.
  void listenToConnectivity() {
    _connectivity.onConnectivityChanged.listen((results) {
      // ConnectivityResult.none bo'lmagan har qanday holat = tarmoq mavjud
      if (results.any((r) => r != ConnectivityResult.none)) {
        debugPrint('[SyncWorker] Tarmoq ulandi. Sinxronizatsiya boshlanmoqda...');
        triggerSync();
      }
    });
  }

  /// Sinxronizatsiya tsiklini ishga tushiradi.
  /// Agar allaqachon ishlayotgan bo'lsa, qayta ishga tushirmaydi.
  void triggerSync() {
    if (_isSyncing) {
      debugPrint('[SyncWorker] Sinxronizatsiya allaqachon ishlayapti, o\'tkazib yuborildi.');
      return;
    }
    _runSyncCycle();
  }

  Future<void> _runSyncCycle() async {
    _isSyncing = true;
    debugPrint('[SyncWorker] Sinxronizatsiya tsikli boshlandi.');

    try {
      // Tarmoq mavjudligini tekshirish
      final connectivityResults = await _connectivity.checkConnectivity();
      if (connectivityResults.every((r) => r == ConnectivityResult.none)) {
        debugPrint('[SyncWorker] Tarmoq mavjud emas. Sinxronizatsiya to\'xtatildi.');
        return;
      }

      // Navbatdagi eng qadimgi amalni FIFO tartibida qayta-qayta ishlash
      while (true) {
        // Tarmoqni har iteratsiyada tekshirib borish
        final currentResults = await _connectivity.checkConnectivity();
        if (currentResults.every((r) => r == ConnectivityResult.none)) {
          debugPrint('[SyncWorker] Sinxronizatsiya paytida tarmoq uzildi. Keyingiga qoldirildi.');
          break;
        }

        // Eng birinchi (eng qadimgi) qayta ishlashni kutayotgan amalni olish.
        // Drift: retryCount < 5 va createdAt bo'yicha o'sish (FIFO) tartibida.
        final row = await _db.getOldestPendingAction();

        if (row == null) {
          debugPrint('[SyncWorker] Navbat bo\'sh. Sinxronizatsiya muvaffaqiyatli yakunlandi.');
          break;
        }

        final action = OutboxActionModel.fromTable(row);

        debugPrint('[SyncWorker] Amal qayta ishlanmoqda: '
            '${action.actionType.name} / ${action.entityCollection} / ${action.entityId}');

        final success = await _processAction(action);

        if (success) {
          // Muvaffaqiyatli bo'lsa, navbatdan o'chirish
          await _db.deleteOutboxAction(action.id!);
          debugPrint('[SyncWorker] Amal muvaffaqiyatli bajarildi va navbatdan o\'chirildi.');
        } else {
          // Muvaffaqiyatsiz bo'lsa, keyingi urinishga qoldirish
          debugPrint('[SyncWorker] Amal muvaffaqiyatsiz. '
              'Urinish: ${action.retryCount}. Keyingi iteratsiyada qayta uriniladi.');
          break; // Tarmoq xatosida tsiklni to'xtatamiz
        }
      }
    } catch (e, stack) {
      debugPrint('[SyncWorker] Kutilmagan xato: $e\n$stack');
    } finally {
      _isSyncing = false;
      debugPrint('[SyncWorker] Sinxronizatsiya tsikli yakunlandi.');
    }
  }

  Future<bool> _processAction(OutboxActionModel action) async {
    try {
      final docRef = _firestore
          .collection(action.entityCollection)
          .doc(action.entityId);

      switch (action.actionType) {
        case OutboxActionType.create:
        case OutboxActionType.update:
          final Map<String, dynamic> data = jsonDecode(action.payloadJson)
              as Map<String, dynamic>;
          // Idempotent yozish: set + merge:true
          // Tarmoq uzilishida qayta yuborilsa ham, Firestore ma'lumotni takrorlamaydi
          await docRef.set(data, SetOptions(merge: true));
          break;

        case OutboxActionType.delete:
          await docRef.delete();
          break;
      }

      return true;
    } catch (e) {
      // Muvaffaqiyatsiz bo'lsa urinishlar sonini oshirib, xatoni yozamiz.
      final updated = action.copyWith(
        retryCount: action.retryCount + 1,
        lastError: e.toString(),
      );
      await _db.updateOutboxAction(updated.toUpdateCompanion());
      debugPrint('[SyncWorker] Xato: $e');
      return false;
    }
  }
}
