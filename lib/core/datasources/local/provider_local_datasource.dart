import '../../../models/provider.dart';
import '../../services/storage_service.dart';

class ProviderLocalDataSource {
  ProviderLocalDataSource(this._storage);

  final StorageService _storage;

  List<HealthcareProvider> getAll() => _storage.getCachedProviders();

  Future<void> saveAll(List<HealthcareProvider> providers) =>
      _storage.cacheProviders(providers);

  HealthcareProvider? getById(String id) => _storage.getProvider(id);
}
