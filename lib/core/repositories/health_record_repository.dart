import '../../models/health_record.dart';
import '../datasources/local/health_record_local_datasource.dart';
import '../datasources/remote/health_record_remote_datasource.dart';
import '../errors/firebase_error_mapper.dart';
import '../result/app_result.dart';
import '../services/connectivity_service.dart';

abstract class HealthRecordRepository {
  Future<AppResult<List<HealthRecord>>> getForUser(String userId, {bool forceRefresh = false});
  Future<AppResult<HealthRecord>> create(HealthRecord record);
}

class HealthRecordRepositoryImpl implements HealthRecordRepository {
  HealthRecordRepositoryImpl(this._local, this._remote, this._connectivity);

  final HealthRecordLocalDataSource _local;
  final HealthRecordRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  @override
  Future<AppResult<List<HealthRecord>>> getForUser(String userId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = _local.getAll().where((r) => r.userId == userId).toList();
        if (cached.isNotEmpty) {
          return AppSuccess<List<HealthRecord>>(cached);
        }
      }
      final isOnline = await _connectivity.isConnected();
      if (!isOnline) {
        final cached = _local.getAll().where((r) => r.userId == userId).toList();
        return AppSuccess<List<HealthRecord>>(cached);
      }

      final remote = await _remote.getRecords(userId);
      await _local.saveAll(remote);
      return AppSuccess<List<HealthRecord>>(remote);
    } catch (error) {
      return FirebaseErrorMapper.map<List<HealthRecord>>(error);
    }
  }

  @override
  Future<AppResult<HealthRecord>> create(HealthRecord record) async {
    try {
      await _local.saveOne(record);
      if (await _connectivity.isConnected()) {
        await _remote.createRecord(record);
      }
      return AppSuccess<HealthRecord>(record);
    } catch (error) {
      return FirebaseErrorMapper.map<HealthRecord>(error);
    }
  }
}
