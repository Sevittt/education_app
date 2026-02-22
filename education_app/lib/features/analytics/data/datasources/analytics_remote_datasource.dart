import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/xapi_statement.dart';

abstract class AnalyticsRemoteDataSource {
  Future<void> recordStatement(XApiStatement statement);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('learning_records');

  @override
  Future<void> recordStatement(XApiStatement statement) async {
    await _collection.add(statement.toJson());
  }
}
