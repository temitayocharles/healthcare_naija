import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('firestore.rules contains required collection guards', () {
    final rules = File('firestore.rules').readAsStringSync();
    expect(rules.contains('match /users/{userId}'), isTrue);
    expect(rules.contains('match /providers/{providerId}'), isTrue);
    expect(rules.contains('match /appointments/{appointmentId}'), isTrue);
    expect(rules.contains('match /health_records/{recordId}'), isTrue);
    expect(rules.contains('match /symptom_records/{recordId}'), isTrue);
    expect(rules.contains('match /health_record_shares/{shareId}'), isTrue);
    expect(rules.contains('match /conversations/{conversationId}'), isTrue);
    expect(rules.contains('match /messages/{messageId}'), isTrue);
    expect(rules.contains('match /config/{docId}'), isTrue);
    expect(rules.contains('function signedIn()'), isTrue);
    expect(rules.contains('validUserDoc'), isTrue);
    expect(rules.contains('validAppointmentDoc'), isTrue);
  });
}
