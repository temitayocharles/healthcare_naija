import '../../../models/health_record.dart';
import '../../../services/firestore_service.dart';

class HealthRecordRemoteDataSource {
  Future<List<HealthRecord>> getRecords(String userId) {
    return FirestoreService.getHealthRecords(userId);
  }

  Future<void> createRecord(HealthRecord record) {
    return FirestoreService.createHealthRecord(record);
  }
}
