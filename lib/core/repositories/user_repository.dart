import '../../models/user.dart';
import '../services/storage_service.dart';

abstract class UserRepository {
  User? getCurrentUser();
  Future<void> saveCurrentUser(User user);
  Future<void> clearCurrentUser();
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._storageService);

  final StorageService _storageService;

  @override
  User? getCurrentUser() {
    return _storageService.getCachedUser();
  }

  @override
  Future<void> saveCurrentUser(User user) {
    return _storageService.cacheUser(user);
  }

  @override
  Future<void> clearCurrentUser() {
    return _storageService.clearUser();
  }
}
