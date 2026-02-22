import 'package:flutter/material.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/domain/usecases/systems_read_usecases.dart';
import 'package:sud_qollanma/features/systems/domain/usecases/systems_write_usecases.dart';

class SystemsNotifier extends ChangeNotifier {
  final GetSystems _getSystems;
  final GetSystemsByCategory _getSystemsByCategory;
  final GetActiveSystems _getActiveSystems;
  final GetSystemById _getSystemById;
  final CreateSystem _createSystem;
  final UpdateSystem _updateSystem;
  final DeleteSystem _deleteSystem;
  final UpdateSystemStatus _updateSystemStatus;

  SystemsNotifier({
    required GetSystems getSystems,
    required GetSystemsByCategory getSystemsByCategory,
    required GetActiveSystems getActiveSystems,
    required GetSystemById getSystemById,
    required CreateSystem createSystem,
    required UpdateSystem updateSystem,
    required DeleteSystem deleteSystem,
    required UpdateSystemStatus updateSystemStatus,
  })  : _getSystems = getSystems,
        _getSystemsByCategory = getSystemsByCategory,
        _getActiveSystems = getActiveSystems,
        _getSystemById = getSystemById,
        _createSystem = createSystem,
        _updateSystem = updateSystem,
        _deleteSystem = deleteSystem,
        _updateSystemStatus = updateSystemStatus;

  // Streams
  Stream<List<SudSystemEntity>> get systemsStream => _getSystems();
  Stream<List<SudSystemEntity>> get activeSystemsStream => _getActiveSystems();
  Stream<List<SudSystemEntity>> getSystemsByCategory(SystemCategory category) =>
      _getSystemsByCategory(category);

  // Future methods
  Future<SudSystemEntity?> getSystemById(String id) => _getSystemById(id);

  Future<void> createSystem(SudSystemEntity system) async {
    try {
      await _createSystem(system);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSystem(SudSystemEntity system) async {
    try {
      await _updateSystem(system);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSystem(String id) async {
    try {
      await _deleteSystem(id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSystemStatus(String id, SystemStatus status) async {
    try {
      await _updateSystemStatus(id, status);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
