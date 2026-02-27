import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nigeria_health_care/lib/core/config/firebase_config.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _messaging.requestPermission();
    String? token = await _messaging.getToken();
    print('Firebase Messaging Token: $token');
  }

  static Future<void> sendNotification(String title, String body) async {
    await _messaging.sendToTopic(
      'all',
      Notification(
        title: title,
        body: body,
      ),
    );
  }
}
