import '../../models/appointment.dart';
import '../datasources/local/appointment_local_datasource.dart';
import '../datasources/remote/appointment_remote_datasource.dart';
import '../errors/firebase_error_mapper.dart';
import '../result/app_result.dart';
import '../services/connectivity_service.dart';
import '../services/sync_queue_service.dart';

abstract class AppointmentRepository {
  Future<AppResult<List<Appointment>>> getForUser(String userId, {bool forceRefresh = false});
  Future<AppResult<Appointment>> upsert(Appointment appointment);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(
    this._local,
    this._remote,
    this._syncQueue,
    this._connectivity,
  );

  final AppointmentLocalDataSource _local;
  final AppointmentRemoteDataSource _remote;
  final SyncQueueService _syncQueue;
  final ConnectivityService _connectivity;

  @override
  Future<AppResult<List<Appointment>>> getForUser(String userId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = _local.getAll().where((a) => a.patientId == userId).toList();
        if (cached.isNotEmpty) {
          return AppSuccess<List<Appointment>>(cached);
        }
      }

      final isOnline = await _connectivity.isConnected();
      if (!isOnline) {
        final cached = _local.getAll().where((a) => a.patientId == userId).toList();
        return AppSuccess<List<Appointment>>(cached);
      }

      final remote = await _remote.getAppointments(userId);
      await _local.saveAll(remote);
      return AppSuccess<List<Appointment>>(remote);
    } catch (error) {
      return FirebaseErrorMapper.map<List<Appointment>>(error);
    }
  }

  @override
  Future<AppResult<Appointment>> upsert(Appointment appointment) async {
    try {
      await _local.saveOne(appointment);
      final isOnline = await _connectivity.isConnected();
      if (isOnline) {
        await _remote.upsertAppointment(appointment);
      } else {
        await _syncQueue.enqueueUpsertAppointment(appointment);
      }
      return AppSuccess<Appointment>(appointment);
    } catch (error) {
      return FirebaseErrorMapper.map<Appointment>(error);
    }
  }
}
