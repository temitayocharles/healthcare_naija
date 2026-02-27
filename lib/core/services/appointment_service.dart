import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:uuid/uuid.dart';
import '../../models/appointment.dart';
import '../../models/provider.dart' as model;
import '../providers/providers.dart';

class AppointmentService {
  final riverpod.Ref ref;

  AppointmentService(this.ref);

  // Book an appointment
  Future<Appointment> bookAppointment({
    required String patientId,
    required model.HealthcareProvider provider,
    required DateTime dateTime,
    String? notes,
    String? symptoms,
    bool isEmergency = false,
    String appointmentType = 'in_person',
  }) async {
    final appointment = Appointment(
      id: const Uuid().v4(),
      patientId: patientId,
      providerId: provider.id,
      providerName: provider.name,
      providerType: provider.type,
      dateTime: dateTime,
      status: 'pending',
      notes: notes,
      symptoms: symptoms,
      createdAt: DateTime.now(),
      isEmergency: isEmergency,
      appointmentType: appointmentType,
    );

    // Store locally
    final storage = ref.read(storageServiceProvider);
    final existing = storage.getCachedAppointments();
    await storage.cacheAppointments([...existing, appointment]);
    await ref.read(syncQueueServiceProvider).enqueueUpsertAppointment(appointment);

    return appointment;
  }

  // Get user appointments
  List<Appointment> getAppointments(String userId) {
    return ref.read(storageServiceProvider).getCachedAppointments()
        .where((a) => a.patientId == userId)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Get upcoming appointments
  List<Appointment> getUpcomingAppointments(String userId) {
    final now = DateTime.now();
    return getAppointments(userId)
        .where((a) => a.dateTime.isAfter(now) && a.status != 'cancelled')
        .toList();
  }

  // Get past appointments
  List<Appointment> getPastAppointments(String userId) {
    final now = DateTime.now();
    return getAppointments(userId)
        .where((a) => a.dateTime.isBefore(now) || a.status == 'completed')
        .toList();
  }

  // Get cancelled appointments
  List<Appointment> getCancelledAppointments(String userId) {
    return getAppointments(userId)
        .where((a) => a.status == 'cancelled')
        .toList();
  }

  // Cancel appointment
  Future<Appointment?> cancelAppointment(String appointmentId) async {
    final storage = ref.read(storageServiceProvider);
    final appointments = storage.getCachedAppointments();

    final index = appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return null;

    final updated = appointments[index].copyWith(status: 'cancelled');
    appointments[index] = updated;

    await storage.cacheAppointments(appointments);
    await ref.read(syncQueueServiceProvider).enqueueUpsertAppointment(updated);
    return updated;
  }

  // Reschedule appointment
  Future<Appointment?> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
  ) async {
    final storage = ref.read(storageServiceProvider);
    final appointments = storage.getCachedAppointments();

    final index = appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return null;

    final updated = appointments[index].copyWith(
      dateTime: newDateTime,
      status: 'pending',
    );
    appointments[index] = updated;

    await storage.cacheAppointments(appointments);
    await ref.read(syncQueueServiceProvider).enqueueUpsertAppointment(updated);
    return updated;
  }

  // Get appointment by ID
  Appointment? getAppointmentById(String id) {
    try {
      return ref.read(storageServiceProvider).getCachedAppointments()
          .firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

final appointmentServiceProvider = riverpod.Provider<AppointmentService>((ref) {
  return AppointmentService(ref);
});
