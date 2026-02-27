import '../../../models/appointment.dart';
import '../../services/storage_service.dart';

class AppointmentLocalDataSource {
  AppointmentLocalDataSource(this._storage);

  final StorageService _storage;

  List<Appointment> getAll() => _storage.getCachedAppointments();

  Future<void> saveAll(List<Appointment> appointments) =>
      _storage.cacheAppointments(appointments);

  Future<void> saveOne(Appointment appointment) =>
      _storage.cacheAppointment(appointment);

  Appointment? getById(String id) => _storage.getCachedAppointmentById(id);
}
