import '../../models/provider.dart';
import '../services/provider_service.dart';
import '../services/storage_service.dart';

abstract class ProviderRepository {
  Future<List<HealthcareProvider>> getProviders({bool forceRefresh = false});
  Future<void> cacheProviders(List<HealthcareProvider> providers);
  HealthcareProvider? getProviderById(String id);
}

class ProviderRepositoryImpl implements ProviderRepository {
  ProviderRepositoryImpl(this._providerService, this._storageService);

  final ProviderService _providerService;
  final StorageService _storageService;

  @override
  Future<List<HealthcareProvider>> getProviders({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _storageService.getCachedProviders();
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    final remote = _providerService.getAllProviders();
    await _storageService.cacheProviders(remote);
    return remote;
  }

  @override
  Future<void> cacheProviders(List<HealthcareProvider> providers) {
    return _storageService.cacheProviders(providers);
  }

  @override
  HealthcareProvider? getProviderById(String id) {
    return _storageService.getProvider(id) ?? _providerService.getProviderById(id);
  }
}
