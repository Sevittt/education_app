import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/domain/repositories/systems_repository.dart';

class GetSystems {
  final SystemsRepository repository;
  GetSystems(this.repository);
  Stream<List<SudSystemEntity>> call() => repository.getAllSystems();
}

class GetSystemsByCategory {
  final SystemsRepository repository;
  GetSystemsByCategory(this.repository);
  Stream<List<SudSystemEntity>> call(SystemCategory category) => repository.getSystemsByCategory(category);
}

class GetActiveSystems {
  final SystemsRepository repository;
  GetActiveSystems(this.repository);
  Stream<List<SudSystemEntity>> call() => repository.getActiveSystems();
}

class GetSystemById {
  final SystemsRepository repository;
  GetSystemById(this.repository);
  Future<SudSystemEntity?> call(String id) => repository.getSystemById(id);
}
