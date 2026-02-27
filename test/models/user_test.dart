import 'package:flutter_test/flutter_test.dart';
import 'package:nigeria_healthcare_app/models/user.dart';

void main() {
  test('User model should be created correctly', () {
    final user = User(
      id: '123',
      email: 'test@example.com',
      phone: '1234567890',
      name: 'Test User',
      role: 'patient',
      profileImageUrl: 'https://example.com/profile.jpg',
      state: 'Lagos',
      lga: 'Ikeja',
      address: '123 Main St',
      latitude: 1.0,
      longitude: 2.0,
      createdAt: DateTime.now(),
      isVerified: true,
      medicalHistory: {'diabetes': true},
    );

    expect(user.id, '123');
    expect(user.email, 'test@example.com');
    expect(user.phone, '1234567890');
    expect(user.name, 'Test User');
    expect(user.role, 'patient');
    expect(user.profileImageUrl, 'https://example.com/profile.jpg');
    expect(user.state, 'Lagos');
    expect(user.lga, 'Ikeja');
    expect(user.address, '123 Main St');
    expect(user.latitude, 1.0);
    expect(user.longitude, 2.0);
    expect(user.createdAt, isA<DateTime>());
    expect(user.isVerified, true);
    expect(user.medicalHistory, {'diabetes': true});
  });
}
