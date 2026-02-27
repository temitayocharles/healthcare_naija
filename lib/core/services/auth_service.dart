import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final Ref ref;

  AuthService(this.ref);

  // Phone authentication
  Future<User?> signInWithPhone(String phoneNumber) async {
    try {
      // For demo purposes, we'll create a mock user
      // In production, implement actual Firebase phone auth
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phone: phoneNumber,
        name: 'User',
        role: 'patient',
        createdAt: DateTime.now(),
      );

      // Cache the user locally
      await ref.read(storageServiceProvider).cacheUser(user);
      return user;
    } catch (e) {
      throw Exception('Phone authentication failed: $e');
    }
  }

  // Email authentication
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // For demo, create mock user
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        phone: '',
        name: email.split('@').first,
        role: 'patient',
        createdAt: DateTime.now(),
      );

      await ref.read(storageServiceProvider).cacheUser(user);
      return user;
    } catch (e) {
      throw Exception('Email authentication failed: $e');
    }
  }

  // Register new user
  Future<User?> register({
    required String name,
    required String phone,
    String? email,
    required String role,
  }) async {
    try {
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phone: phone,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      await ref.read(storageServiceProvider).cacheUser(user);
      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await ref.read(storageServiceProvider).clearUser();
  }

  // Get current user
  User? getCurrentUser() {
    return ref.read(storageServiceProvider).getCachedUser();
  }

  // Update user profile
  Future<User?> updateProfile({
    String? name,
    String? state,
    String? lga,
    String? address,
  }) async {
    final currentUser = getCurrentUser();
    if (currentUser == null) return null;

    final updatedUser = currentUser.copyWith(
      name: name ?? currentUser.name,
      state: state ?? currentUser.state,
      lga: lga ?? currentUser.lga,
      address: address ?? currentUser.address,
    );

    await ref.read(storageServiceProvider).cacheUser(updatedUser);
    return updatedUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getCurrentUser() != null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});
