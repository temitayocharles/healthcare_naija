import '../../models/user.dart';
import '../datasources/local/user_local_datasource.dart';
import '../errors/firebase_error_mapper.dart';
import '../result/app_result.dart';
import '../services/connectivity_service.dart';
import '../services/sync_queue_service.dart';
import '../../services/firestore_service.dart';

abstract class UserRepository {
  User? getCurrentUser();
  Future<void> saveCurrentUser(User user);
  Future<void> clearCurrentUser();
  Future<AppResult<User>> upsertUser(User user);
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._local, this._connectivity, this._syncQueue);

  final UserLocalDataSource _local;
  final ConnectivityService _connectivity;
  final SyncQueueService _syncQueue;

  @override
  User? getCurrentUser() {
    return _local.getCurrentUser();
  }

  @override
  Future<void> saveCurrentUser(User user) {
    return _local.saveCurrentUser(user);
  }

  @override
  Future<void> clearCurrentUser() {
    return _local.clearCurrentUser();
  }

  @override
  Future<AppResult<User>> upsertUser(User user) async {
    try {
      await _local.saveCurrentUser(user);
      if (await _connectivity.isConnected()) {
        await FirestoreService.upsertUser(user);
      } else {
        await _syncQueue.enqueueUpsertUser(user);
      }
      return AppSuccess<User>(user);
    } catch (error) {
      return FirebaseErrorMapper.map<User>(error);
    }
  }
}
