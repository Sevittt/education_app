import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sud_qollanma/features/systems/data/models/sud_system_model.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';

abstract class SystemsRemoteDataSource {
  Stream<List<SudSystemModel>> getAllSystems();
  Stream<List<SudSystemModel>> getSystemsByCategory(SystemCategory category);
  Stream<List<SudSystemModel>> getActiveSystems();
  Future<SudSystemModel?> getSystemById(String id);
  Future<void> createSystem(SudSystemEntity system);
  Future<void> updateSystem(SudSystemEntity system);
  Future<void> deleteSystem(String id);
  Future<void> updateSystemStatus(String id, SystemStatus status);
  Future<int> getTotalSystemsCount();
  Future<int> getActiveSystemsCount();
}

class SystemsRemoteDataSourceImpl implements SystemsRemoteDataSource {
  final CollectionReference _systemsCollection = FirebaseFirestore.instance.collection('systems');

  @override
  Stream<List<SudSystemModel>> getAllSystems() {
    return _systemsCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SudSystemModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<SudSystemModel>> getSystemsByCategory(SystemCategory category) {
    return _systemsCollection
        .where('category', isEqualTo: category.name)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SudSystemModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<SudSystemModel>> getActiveSystems() {
    return _systemsCollection
        .where('status', isEqualTo: SystemStatus.active.name)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SudSystemModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<SudSystemModel?> getSystemById(String id) async {
    final doc = await _systemsCollection.doc(id).get();
    if (doc.exists) {
      return SudSystemModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> createSystem(SudSystemEntity system) async {
    final model = SudSystemModel(
      id: system.id,
      name: system.name,
      fullName: system.fullName,
      url: system.url,
      logoUrl: system.logoUrl,
      description: system.description,
      loginGuideId: system.loginGuideId,
      videoGuideId: system.videoGuideId,
      faqIds: system.faqIds,
      category: system.category,
      status: system.status,
      supportEmail: system.supportEmail,
      supportPhone: system.supportPhone,
      createdAt: system.createdAt,
      updatedAt: system.updatedAt,
    );
    // If ID is empty, allow Firestore to generate it (using .add), but we pass 'id' in constructor which requires it.
    // Usually UseCase generates ID or we use .doc().set() if we have an ID.
    // If system.id is empty string, we should use .add and let Firestore generate.
    if (system.id.isEmpty) {
       await _systemsCollection.add(model.toFirestore());
    } else {
       await _systemsCollection.doc(system.id).set(model.toFirestore());
    }
  }

  @override
  Future<void> updateSystem(SudSystemEntity system) async {
     final model = SudSystemModel(
      id: system.id,
      name: system.name,
      fullName: system.fullName,
      url: system.url,
      logoUrl: system.logoUrl,
      description: system.description,
      loginGuideId: system.loginGuideId,
      videoGuideId: system.videoGuideId,
      faqIds: system.faqIds,
      category: system.category,
      status: system.status,
      supportEmail: system.supportEmail,
      supportPhone: system.supportPhone,
      createdAt: system.createdAt,
      updatedAt: DateTime.now(), // Update timestamp
    );
    await _systemsCollection.doc(system.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteSystem(String id) async {
    await _systemsCollection.doc(id).delete();
  }

  @override
  Future<void> updateSystemStatus(String id, SystemStatus status) async {
    await _systemsCollection.doc(id).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<int> getTotalSystemsCount() async {
    final snapshot = await _systemsCollection.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getActiveSystemsCount() async {
    final snapshot = await _systemsCollection
        .where('status', isEqualTo: SystemStatus.active.name)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
