import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('storage.rules contains health and chat upload guards', () {
    final rules = File('storage.rules').readAsStringSync();
    expect(rules.contains('match /health_records/{ownerId}/{fileName}'), isTrue);
    expect(rules.contains('match /chat_attachments/{ownerId}/{fileName}'), isTrue);
    expect(rules.contains('allow read, write: if signedIn() && request.auth.uid == ownerId;'), isTrue);
  });
}
