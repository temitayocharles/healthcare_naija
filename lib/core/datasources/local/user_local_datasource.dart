import '../../../models/user.dart';
import '../../services/storage_service.dart';

class UserLocalDataSource {
  UserLocalDataSource(this._storage);

  final StorageService _storage;

  User? getCurrentUser() => _storage.getCachedUser();

  Future<void> saveCurrentUser(User user) => _storage.cacheUser(user);

  Future<void> clearCurrentUser() => _storage.clearUser();
}
