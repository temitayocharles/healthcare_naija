import '../../../models/appointment.dart';
import '../../../services/firestore_service.dart';

class AppointmentRemoteDataSource {
  Future<List<Appointment>> getAppointments(String userId) {
    return FirestoreService.getAppointments(userId);
  }

  Future<void> upsertAppointment(Appointment appointment) {
    return FirestoreService.upsertAppointment(appointment);
  }
}
