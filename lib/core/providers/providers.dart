import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';
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
    final storage = ref.read(storageServiceProvider);
    state = storage.getCachedUser();
  }

  Future<void> setUser(models.User user) async {
    final storage = ref.read(storageServiceProvider);
    await storage.cacheUser(user);
    state = user;
  }

  Future<void> clearUser() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearUser();
    state = null;
  }
}

// Providers list
final providersProvider = StateNotifierProvider<ProvidersNotifier, List<models.Provider>>((ref) {
  return ProvidersNotifier(ref);
});

class ProvidersNotifier extends StateNotifier<List<models.Provider>> {
  final Ref ref;

  ProvidersNotifier(this.ref) : super([]);

  void setProviders(List<models.Provider> providers) {
    state = providers;
  }

  void addProvider(models.Provider provider) {
    state = [...state, provider];
  }

  void updateProvider(models.Provider provider) {
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
