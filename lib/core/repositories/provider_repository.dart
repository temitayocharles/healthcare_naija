import '../../models/provider.dart';
import '../datasources/local/provider_local_datasource.dart';
import '../datasources/remote/provider_remote_datasource.dart';
import '../errors/firebase_error_mapper.dart';
import '../result/app_result.dart';
import '../services/connectivity_service.dart';
import '../services/provider_service.dart';
import '../services/sync_queue_service.dart';

abstract class ProviderRepository {
  Future<List<HealthcareProvider>> getProviders({bool forceRefresh = false});
  Future<void> cacheProviders(List<HealthcareProvider> providers);
  HealthcareProvider? getProviderById(String id);
  Future<AppResult<HealthcareProvider>> upsertProvider(HealthcareProvider provider);
}

class ProviderRepositoryImpl implements ProviderRepository {
  ProviderRepositoryImpl(
    this._providerService,
    this._local,
    this._remote,
    this._connectivity,
    this._syncQueue,
  );

  final ProviderService _providerService;
  final ProviderLocalDataSource _local;
  final ProviderRemoteDataSource _remote;
  final ConnectivityService _connectivity;
  final SyncQueueService _syncQueue;

  @override
  Future<List<HealthcareProvider>> getProviders({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _local.getAll();
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    final isOnline = await _connectivity.isConnected();
    if (isOnline) {
      final remote = await _remote.getAllProviders();
      await _local.saveAll(remote);
      return remote;
    }
    final remote = _providerService.getAllProviders();
    await _local.saveAll(remote);
    return remote;
  }

  @override
  Future<void> cacheProviders(List<HealthcareProvider> providers) {
    return _local.saveAll(providers);
  }

  @override
  HealthcareProvider? getProviderById(String id) {
    return _local.getById(id) ?? _providerService.getProviderById(id);
  }

  @override
  Future<AppResult<HealthcareProvider>> upsertProvider(HealthcareProvider provider) async {
    try {
      await _local.saveAll([
        ..._local.getAll().where((p) => p.id != provider.id),
        provider,
      ]);
      if (await _connectivity.isConnected()) {
        await _remote.upsertProvider(provider);
      } else {
        await _syncQueue.enqueueUpsertProvider(provider);
      }
      return AppSuccess<HealthcareProvider>(provider);
    } catch (error) {
      return FirebaseErrorMapper.map<HealthcareProvider>(error);
    }
  }
}
