import '../../../models/provider.dart';
import '../../../services/firestore_service.dart';

class ProviderRemoteDataSource {
  Future<List<HealthcareProvider>> getAllProviders() {
    return FirestoreService.getAllProviders();
  }

  Future<void> upsertProvider(HealthcareProvider provider) {
    return FirestoreService.upsertProvider(provider);
  }
}
