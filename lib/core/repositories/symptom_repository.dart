import '../../models/symptom_record.dart';
import '../datasources/local/symptom_record_local_datasource.dart';
import '../datasources/remote/symptom_record_remote_datasource.dart';
import '../errors/firebase_error_mapper.dart';
import '../result/app_result.dart';
import '../services/connectivity_service.dart';

abstract class SymptomRepository {
  Future<AppResult<List<SymptomRecord>>> getForUser(String userId, {bool forceRefresh = false});
  Future<AppResult<SymptomRecord>> create(SymptomRecord record);
}

class SymptomRepositoryImpl implements SymptomRepository {
  SymptomRepositoryImpl(this._local, this._remote, this._connectivity);

  final SymptomRecordLocalDataSource _local;
  final SymptomRecordRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  @override
  Future<AppResult<List<SymptomRecord>>> getForUser(String userId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = _local.getAll().where((r) => r.userId == userId).toList();
        if (cached.isNotEmpty) {
          return AppSuccess<List<SymptomRecord>>(cached);
        }
      }

      if (!await _connectivity.isConnected()) {
        final cached = _local.getAll().where((r) => r.userId == userId).toList();
        return AppSuccess<List<SymptomRecord>>(cached);
      }

      final remote = await _remote.getRecords(userId);
      await _local.saveAll(remote);
      return AppSuccess<List<SymptomRecord>>(remote);
    } catch (error) {
      return FirebaseErrorMapper.map<List<SymptomRecord>>(error);
    }
  }

  @override
  Future<AppResult<SymptomRecord>> create(SymptomRecord record) async {
    try {
      await _local.saveOne(record);
      if (await _connectivity.isConnected()) {
        await _remote.createRecord(record);
      }
      return AppSuccess<SymptomRecord>(record);
    } catch (error) {
      return FirebaseErrorMapper.map<SymptomRecord>(error);
    }
  }
}
