import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/local/appointment_local_datasource.dart';
import '../datasources/local/health_record_local_datasource.dart';
import '../datasources/local/provider_local_datasource.dart';
import '../datasources/local/symptom_record_local_datasource.dart';
import '../datasources/local/user_local_datasource.dart';
import '../datasources/remote/appointment_remote_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/remote/health_record_remote_datasource.dart';
import '../datasources/remote/provider_remote_datasource.dart';
import '../datasources/remote/symptom_record_remote_datasource.dart';
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

final failedSyncOperationsProvider = StreamProvider<int>((ref) {
  final syncQueue = ref.watch(syncQueueServiceProvider);
  return syncQueue.failedCountStream;
});

final lastSuccessfulSyncProvider = StreamProvider<DateTime?>((ref) {
  final syncQueue = ref.watch(syncQueueServiceProvider);
  return syncQueue.lastSyncStream;
});

// Local data sources
final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UserLocalDataSource(storage);
});

final providerLocalDataSourceProvider = Provider<ProviderLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProviderLocalDataSource(storage);
});

final appointmentLocalDataSourceProvider = Provider<AppointmentLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AppointmentLocalDataSource(storage);
});

final healthRecordLocalDataSourceProvider = Provider<HealthRecordLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HealthRecordLocalDataSource(storage);
});

final symptomRecordLocalDataSourceProvider = Provider<SymptomRecordLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SymptomRecordLocalDataSource(storage);
});

// Remote data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(FirebaseAuth.instance);
});

final providerRemoteDataSourceProvider = Provider<ProviderRemoteDataSource>((ref) {
  return ProviderRemoteDataSource();
});

final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDataSource>((ref) {
  return AppointmentRemoteDataSource();
});

final healthRecordRemoteDataSourceProvider = Provider<HealthRecordRemoteDataSource>((ref) {
  return HealthRecordRemoteDataSource();
});

final symptomRecordRemoteDataSourceProvider = Provider<SymptomRecordRemoteDataSource>((ref) {
  return SymptomRecordRemoteDataSource();
});

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final local = ref.watch(userLocalDataSourceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final syncQueue = ref.watch(syncQueueServiceProvider);
  return UserRepositoryImpl(local, connectivity, syncQueue);
});

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  final providerService = ref.watch(providerServiceProvider);
  final local = ref.watch(providerLocalDataSourceProvider);
  final remote = ref.watch(providerRemoteDataSourceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final syncQueue = ref.watch(syncQueueServiceProvider);
  return ProviderRepositoryImpl(
    providerService,
    local,
    remote,
    connectivity,
    syncQueue,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final userLocal = ref.watch(userLocalDataSourceProvider);
  return AuthRepositoryImpl(remote, userLocal);
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final local = ref.watch(appointmentLocalDataSourceProvider);
  final remote = ref.watch(appointmentRemoteDataSourceProvider);
  final syncQueue = ref.watch(syncQueueServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return AppointmentRepositoryImpl(local, remote, syncQueue, connectivity);
});

final healthRecordRepositoryProvider = Provider<HealthRecordRepository>((ref) {
  final local = ref.watch(healthRecordLocalDataSourceProvider);
  final remote = ref.watch(healthRecordRemoteDataSourceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return HealthRecordRepositoryImpl(local, remote, connectivity);
});

final symptomRepositoryProvider = Provider<SymptomRepository>((ref) {
  final local = ref.watch(symptomRecordLocalDataSourceProvider);
  final remote = ref.watch(symptomRecordRemoteDataSourceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SymptomRepositoryImpl(local, remote, connectivity);
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
    await userRepository.upsertUser(user);
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
    final providerRepository = ref.read(providerRepositoryProvider);
    await providerRepository.upsertProvider(provider);
    state = [...state, provider];
  }

  Future<void> updateProvider(models.HealthcareProvider provider) async {
    final providerRepository = ref.read(providerRepositoryProvider);
    await providerRepository.upsertProvider(provider);
    state = state.map((p) => p.id == provider.id ? provider : p).toList();
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
