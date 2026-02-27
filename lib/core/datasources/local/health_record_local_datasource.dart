import '../../../models/health_record.dart';
import '../../services/storage_service.dart';

class HealthRecordLocalDataSource {
  HealthRecordLocalDataSource(this._storage);

  final StorageService _storage;

  List<HealthRecord> getAll() => _storage.getCachedHealthRecords();

  Future<void> saveAll(List<HealthRecord> records) =>
      _storage.cacheHealthRecords(records);

  Future<void> saveOne(HealthRecord record) => _storage.cacheHealthRecord(record);
}
