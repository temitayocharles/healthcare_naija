import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import '../services/provider_service.dart';
import '../../models/models.dart' as models;

// Core services
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final service = SyncQueueService(storage, connectivity);
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});

final pendingSyncOperationsProvider = StreamProvider<int>((ref) {
  final syncQueue = ref.watch(syncQueueServiceProvider);
  return syncQueue.pendingCountStream;
});

final forceSyncProvider = FutureProvider<void>((ref) async {
  final syncQueue = ref.watch(syncQueueServiceProvider);
  await syncQueue.flushQueue();
});

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UserRepositoryImpl(storage);
});

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  final providerService = ref.watch(providerServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return ProviderRepositoryImpl(providerService, storage);
});

// Connectivity state
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return await service.isConnected();
});

// Current location
final currentLocationProvider = FutureProvider<dynamic>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.getCurrentPosition();
});

// User state
final currentUserProvider = StateNotifierProvider<UserNotifier, models.User?>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<models.User?> {
  final Ref ref;

  UserNotifier(this.ref) : super(null) {
    _loadCachedUser();
  }

  void _loadCachedUser() {
    final userRepository = ref.read(userRepositoryProvider);
    state = userRepository.getCurrentUser();
  }

  Future<void> setUser(models.User user) async {
    final userRepository = ref.read(userRepositoryProvider);
    await userRepository.saveCurrentUser(user);
    await ref.read(syncQueueServiceProvider).enqueueUpsertUser(user);
    state = user;
  }

  Future<void> clearUser() async {
    final userRepository = ref.read(userRepositoryProvider);
    await userRepository.clearCurrentUser();
    state = null;
  }
}

// Providers list
final providersProvider = StateNotifierProvider<ProvidersNotifier, List<models.HealthcareProvider>>((ref) {
  return ProvidersNotifier(ref);
});

class ProvidersNotifier extends StateNotifier<List<models.HealthcareProvider>> {
  final Ref ref;

  ProvidersNotifier(this.ref) : super([]) {
    loadProviders();
  }

  Future<void> loadProviders({bool forceRefresh = false}) async {
    final providerRepository = ref.read(providerRepositoryProvider);
    state = await providerRepository.getProviders(forceRefresh: forceRefresh);
  }

  void setProviders(List<models.HealthcareProvider> providers) {
    state = providers;
  }

  Future<void> addProvider(models.HealthcareProvider provider) async {
    state = [...state, provider];
    final providerRepository = ref.read(providerRepositoryProvider);
    await providerRepository.cacheProviders(state);
    await ref.read(syncQueueServiceProvider).enqueueUpsertProvider(provider);
  }

  Future<void> updateProvider(models.HealthcareProvider provider) async {
    state = state.map((p) => p.id == provider.id ? provider : p).toList();
    final providerRepository = ref.read(providerRepositoryProvider);
    await providerRepository.cacheProviders(state);
    await ref.read(syncQueueServiceProvider).enqueueUpsertProvider(provider);
  }
}

// Appointments
final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier, List<models.Appointment>>((ref) {
  return AppointmentsNotifier(ref);
});

class AppointmentsNotifier extends StateNotifier<List<models.Appointment>> {
  final Ref ref;

  AppointmentsNotifier(this.ref) : super([]);

  void setAppointments(List<models.Appointment> appointments) {
    state = appointments;
  }

  void addAppointment(models.Appointment appointment) {
    state = [...state, appointment];
  }

  void updateAppointment(models.Appointment appointment) {
    state = state.map((a) => a.id == appointment.id ? appointment : a).toList();
  }

  void cancelAppointment(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

// Symptom records
final symptomRecordsProvider = StateNotifierProvider<SymptomRecordsNotifier, List<models.SymptomRecord>>((ref) {
  return SymptomRecordsNotifier(ref);
});

class SymptomRecordsNotifier extends StateNotifier<List<models.SymptomRecord>> {
  final Ref ref;

  SymptomRecordsNotifier(this.ref) : super([]);

  void setRecords(List<models.SymptomRecord> records) {
    state = records;
  }

  void addRecord(models.SymptomRecord record) {
    state = [record, ...state];
  }
}

// Health records
final healthRecordsProvider = StateNotifierProvider<HealthRecordsNotifier, List<models.HealthRecord>>((ref) {
  return HealthRecordsNotifier(ref);
});

class HealthRecordsNotifier extends StateNotifier<List<models.HealthRecord>> {
  final Ref ref;

  HealthRecordsNotifier(this.ref) : super([]);

  void setRecords(List<models.HealthRecord> records) {
    state = records;
  }

  void addRecord(models.HealthRecord record) {
    state = [record, ...state];
  }
}

// Navigation state
final selectedTabProvider = StateProvider<int>((ref) => 0);
