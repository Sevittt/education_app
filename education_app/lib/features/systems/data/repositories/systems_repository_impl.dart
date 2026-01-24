import 'package:sud_qollanma/features/systems/data/datasources/systems_remote_datasource.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/domain/repositories/systems_repository.dart';

class SystemsRepositoryImpl implements SystemsRepository {
  final SystemsRemoteDataSource remoteDataSource;

  SystemsRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<SudSystemEntity>> getAllSystems() => remoteDataSource.getAllSystems();

  @override
  Stream<List<SudSystemEntity>> getSystemsByCategory(SystemCategory category) =>
      remoteDataSource.getSystemsByCategory(category);

  @override
  Stream<List<SudSystemEntity>> getActiveSystems() => remoteDataSource.getActiveSystems();

  @override
  Future<SudSystemEntity?> getSystemById(String id) => remoteDataSource.getSystemById(id);

  @override
  Future<void> createSystem(SudSystemEntity system) => remoteDataSource.createSystem(system);

  @override
  Future<void> updateSystem(SudSystemEntity system) => remoteDataSource.updateSystem(system);

  @override
  Future<void> deleteSystem(String id) => remoteDataSource.deleteSystem(id);

  @override
  Future<void> updateSystemStatus(String id, SystemStatus status) =>
      remoteDataSource.updateSystemStatus(id, status);

  @override
  Future<int> getTotalSystemsCount() => remoteDataSource.getTotalSystemsCount();

  @override
  Future<int> getActiveSystemsCount() => remoteDataSource.getActiveSystemsCount();
}
