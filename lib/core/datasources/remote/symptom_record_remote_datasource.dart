import '../../../models/symptom_record.dart';
import '../../../services/firestore_service.dart';

class SymptomRecordRemoteDataSource {
  Future<List<SymptomRecord>> getRecords(String userId) {
    return FirestoreService.getSymptomRecords(userId);
  }

  Future<void> createRecord(SymptomRecord record) {
    return FirestoreService.createSymptomRecord(record);
  }
}
