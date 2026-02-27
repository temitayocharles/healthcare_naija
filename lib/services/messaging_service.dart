import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _messaging.requestPermission();
    final String? token = await _messaging.getToken();
    debugPrint('Firebase Messaging Token: $token');
  }

  static Future<void> sendNotification(String title, String body) async {
    // FCM client SDK cannot send push notifications directly.
    // This is kept as a no-op entry point for future backend integration.
    await Future<void>.value();
  }
}
