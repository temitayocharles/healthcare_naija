import 'package:hive_flutter/hive_flutter.dart';
import '../../models/models.dart';

class StorageService {
  static const String userBoxName = 'users';
  static const String providersBoxName = 'providers';
  static const String appointmentsBoxName = 'appointments';
  static const String symptomsBoxName = 'symptoms';
  static const String healthRecordsBoxName = 'health_records';
  static const String settingsBoxName = 'settings';

  late Box<User> _userBox;
  late Box<HealthcareProvider> _providersBox;
  late Box<Appointment> _appointmentsBox;
  late Box<SymptomRecord> _symptomsBox;
  late Box<HealthRecord> _healthRecordsBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(HealthcareProviderAdapter());
    Hive.registerAdapter(AppointmentAdapter());
    Hive.registerAdapter(SymptomRecordAdapter());
    Hive.registerAdapter(HealthRecordAdapter());

    // Open boxes
    _userBox = await Hive.openBox<User>(userBoxName);
    _providersBox = await Hive.openBox<HealthcareProvider>(providersBoxName);
    _appointmentsBox = await Hive.openBox<Appointment>(appointmentsBoxName);
    _symptomsBox = await Hive.openBox<SymptomRecord>(symptomsBoxName);
    _healthRecordsBox = await Hive.openBox<HealthRecord>(healthRecordsBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  // User methods
  Future<void> cacheUser(User user) async {
    await _userBox.put('current_user', user);
  }

  User? getCachedUser() {
    return _userBox.get('current_user');
  }

  Future<void> clearUser() async {
    await _userBox.delete('current_user');
  }

  // Provider methods
  Future<void> cacheProviders(List<HealthcareProvider> providers) async {
    await _providersBox.clear();
    for (var provider in providers) {
      await _providersBox.put(provider.id, provider);
    }
  }

  List<HealthcareProvider> getCachedProviders() {
    return _providersBox.values.toList();
  }

  HealthcareProvider? getProvider(String id) {
    return _providersBox.get(id);
  }

  // Appointment methods
  Future<void> cacheAppointments(List<Appointment> appointments) async {
    await _appointmentsBox.clear();
    for (var appointment in appointments) {
      await _appointmentsBox.put(appointment.id, appointment);
    }
  }

  List<Appointment> getCachedAppointments() {
    return _appointmentsBox.values.toList();
  }

  // Symptom methods
  Future<void> cacheSymptoms(List<SymptomRecord> symptoms) async {
    await _symptomsBox.clear();
    for (var symptom in symptoms) {
      await _symptomsBox.put(symptom.id, symptom);
    }
  }

  List<SymptomRecord> getCachedSymptoms() {
    return _symptomsBox.values.toList();
  }

  // Health Records methods
  Future<void> cacheHealthRecords(List<HealthRecord> records) async {
    await _healthRecordsBox.clear();
    for (var record in records) {
      await _healthRecordsBox.put(record.id, record);
    }
  }

  List<HealthRecord> getCachedHealthRecords() {
    return _healthRecordsBox.values.toList();
  }

  // Settings methods
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  // Clear all data (for logout)
  Future<void> clearAll() async {
    await _userBox.clear();
    await _providersBox.clear();
    await _appointmentsBox.clear();
    await _symptomsBox.clear();
    await _healthRecordsBox.clear();
    // Keep settings
  }
}
