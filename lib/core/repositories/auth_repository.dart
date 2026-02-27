import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../datasources/local/user_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../errors/firebase_error_mapper.dart';
import '../result/app_result.dart';
import '../../models/user.dart';

abstract class AuthRepository {
  Future<AppResult<User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppResult<User>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  Future<AppResult<void>> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._userLocal);

  final AuthRemoteDataSource _remote;
  final UserLocalDataSource _userLocal;

  @override
  Future<AppResult<User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _remote.signInWithEmail(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const AppFailure<User>(
          code: 'auth_missing_user',
          message: 'No authenticated user returned.',
        );
      }
      final user = _mapFirebaseUser(firebaseUser);
      await _userLocal.saveCurrentUser(user);
      return AppSuccess<User>(user);
    } catch (error) {
      return FirebaseErrorMapper.map<User>(error);
    }
  }

  @override
  Future<AppResult<User>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final credential = await _remote.registerWithEmail(email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const AppFailure<User>(
          code: 'auth_missing_user',
          message: 'No authenticated user returned.',
        );
      }
      final user = _mapFirebaseUser(firebaseUser).copyWith(
        name: name,
        phone: phone,
      );
      await _userLocal.saveCurrentUser(user);
      return AppSuccess<User>(user);
    } catch (error) {
      return FirebaseErrorMapper.map<User>(error);
    }
  }

  @override
  Future<AppResult<void>> signOut() async {
    try {
      await _remote.signOut();
      await _userLocal.clearCurrentUser();
      return const AppSuccess<void>(null);
    } catch (error) {
      return FirebaseErrorMapper.map<void>(error);
    }
  }

  User _mapFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber ?? '',
      name: firebaseUser.displayName ?? 'User',
      role: 'patient',
      createdAt: DateTime.now(),
      isVerified: firebaseUser.emailVerified,
    );
  }
}
