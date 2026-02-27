import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../result/app_result.dart';
import '../../models/user.dart';
import '../providers/providers.dart';

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
      await ref.read(userRepositoryProvider).upsertUser(user);
      return user;
    } catch (e) {
      throw Exception('Phone authentication failed: $e');
    }
  }

  // Email authentication
  Future<User?> signInWithEmail(String email, String password) async {
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(email: email, password: password);
    if (result is AppSuccess<User>) {
      return result.data;
    }
    return null;
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

      await ref.read(userRepositoryProvider).upsertUser(user);
      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return ref.read(userRepositoryProvider).getCurrentUser();
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

    await ref.read(userRepositoryProvider).upsertUser(updatedUser);
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
