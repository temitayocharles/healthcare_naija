import 'package:firebase_auth/firebase_auth.dart';
import '../result/app_result.dart';

class FirebaseErrorMapper {
  static AppFailure<T> map<T>(Object error) {
    if (error is FirebaseAuthException) {
      return _mapAuth<T>(error);
    }
    if (error is FirebaseException) {
      return _mapFirebase<T>(error);
    }
    return AppFailure<T>(
      code: 'unknown',
      message: 'An unexpected error occurred',
      retriable: false,
      cause: error,
    );
  }

  static AppFailure<T> _mapAuth<T>(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return AppFailure<T>(
          code: 'network',
          message: 'Network error. Please try again.',
          retriable: true,
          cause: error,
        );
      case 'invalid-email':
      case 'wrong-password':
      case 'user-not-found':
        return AppFailure<T>(
          code: 'auth_invalid_credentials',
          message: 'Invalid credentials.',
          retriable: false,
          cause: error,
        );
      case 'too-many-requests':
        return AppFailure<T>(
          code: 'auth_rate_limited',
          message: 'Too many attempts. Try again later.',
          retriable: true,
          cause: error,
        );
      default:
        return AppFailure<T>(
          code: 'auth_error',
          message: error.message ?? 'Authentication failed',
          retriable: false,
          cause: error,
        );
    }
  }

  static AppFailure<T> _mapFirebase<T>(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return AppFailure<T>(
          code: 'permission',
          message: 'You do not have permission for this action.',
          retriable: false,
          cause: error,
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return AppFailure<T>(
          code: 'network',
          message: 'Service temporarily unavailable.',
          retriable: true,
          cause: error,
        );
      case 'not-found':
        return AppFailure<T>(
          code: 'not_found',
          message: 'Requested resource was not found.',
          retriable: false,
          cause: error,
        );
      default:
        return AppFailure<T>(
          code: 'server',
          message: error.message ?? 'Server error.',
          retriable: true,
          cause: error,
        );
    }
  }
}
