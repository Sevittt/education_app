import '../entities/xapi_statement.dart';

abstract class AnalyticsRepository {
  Future<void> recordStatement(XApiStatement statement);
}
