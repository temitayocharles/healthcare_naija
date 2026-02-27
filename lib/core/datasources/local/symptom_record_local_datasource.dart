import '../../../models/symptom_record.dart';
import '../../services/storage_service.dart';

class SymptomRecordLocalDataSource {
  SymptomRecordLocalDataSource(this._storage);

  final StorageService _storage;

  List<SymptomRecord> getAll() => _storage.getCachedSymptoms();

  Future<void> saveAll(List<SymptomRecord> records) =>
      _storage.cacheSymptoms(records);

  Future<void> saveOne(SymptomRecord record) =>
      _storage.cacheSymptomRecord(record);
}
