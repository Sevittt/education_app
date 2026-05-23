import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/domain/repositories/systems_repository.dart';

class CreateSystem {
  final SystemsRepository repository;
  CreateSystem(this.repository);
  Future<void> call(SudSystemEntity system) => repository.createSystem(system);
}

class UpdateSystem {
  final SystemsRepository repository;
  UpdateSystem(this.repository);
  Future<void> call(SudSystemEntity system) => repository.updateSystem(system);
}

class DeleteSystem {
  final SystemsRepository repository;
  DeleteSystem(this.repository);
  Future<void> call(String id) => repository.deleteSystem(id);
}

class UpdateSystemStatus {
  final SystemsRepository repository;
  UpdateSystemStatus(this.repository);
  Future<void> call(String id, SystemStatus status) => repository.updateSystemStatus(id, status);
}
