import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';

abstract class SystemsRepository {
  Stream<List<SudSystemEntity>> getAllSystems();
  Stream<List<SudSystemEntity>> getSystemsByCategory(SystemCategory category);
  Stream<List<SudSystemEntity>> getActiveSystems();
  Future<SudSystemEntity?> getSystemById(String id);
  
  // CRUD
  Future<void> createSystem(SudSystemEntity system);
  Future<void> updateSystem(SudSystemEntity system);
  Future<void> deleteSystem(String id);
  Future<void> updateSystemStatus(String id, SystemStatus status);

  // Stats
  Future<int> getTotalSystemsCount();
  Future<int> getActiveSystemsCount();
}
