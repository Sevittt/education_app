import 'package:sud_qollanma/features/systems/data/datasources/systems_remote_datasource.dart';
import 'package:sud_qollanma/features/systems/domain/entities/sud_system_entity.dart';
import 'package:sud_qollanma/features/systems/domain/repositories/systems_repository.dart';
import 'package:sud_qollanma/features/search/utils/search_indexer.dart';
import 'package:sud_qollanma/features/search/data/models/search_index_model.dart';

class SystemsRepositoryImpl implements SystemsRepository {
  final SystemsRemoteDataSource remoteDataSource;
  final SearchIndexer _searchIndexer;

  SystemsRepositoryImpl(this.remoteDataSource, {SearchIndexer? searchIndexer})
      : _searchIndexer = searchIndexer ?? SearchIndexer();

  @override
  Stream<List<SudSystemEntity>> getAllSystems() =>
      remoteDataSource.getAllSystems();

  @override
  Stream<List<SudSystemEntity>> getSystemsByCategory(SystemCategory category) =>
      remoteDataSource.getSystemsByCategory(category);

  @override
  Stream<List<SudSystemEntity>> getActiveSystems() =>
      remoteDataSource.getActiveSystems();

  @override
  Future<SudSystemEntity?> getSystemById(String id) =>
      remoteDataSource.getSystemById(id);

  @override
  Future<void> createSystem(SudSystemEntity system) async {
    await remoteDataSource.createSystem(system);
    await _searchIndexer.indexDocument(SearchIndexModel(
      id: 'system_${system.id}',
      title: system.name,
      description: system.description,
      type: 'system',
      text: '${system.name}\n${system.description}',
      path: '/system/${system.id}',
      createdAt: system.createdAt,
    ));
  }

  @override
  Future<void> updateSystem(SudSystemEntity system) async {
    await remoteDataSource.updateSystem(system);
    await _searchIndexer.indexDocument(SearchIndexModel(
      id: 'system_${system.id}',
      title: system.name,
      description: system.description,
      type: 'system',
      text: '${system.name}\n${system.description}',
      path: '/system/${system.id}',
      createdAt: system.createdAt,
    ));
  }

  @override
  Future<void> deleteSystem(String id) async {
    await remoteDataSource.deleteSystem(id);
    await _searchIndexer.deleteDocument('system_$id');
  }

  @override
  Future<void> updateSystemStatus(String id, SystemStatus status) =>
      remoteDataSource.updateSystemStatus(id, status);

  @override
  Future<int> getTotalSystemsCount() => remoteDataSource.getTotalSystemsCount();

  @override
  Future<int> getActiveSystemsCount() =>
      remoteDataSource.getActiveSystemsCount();
}
