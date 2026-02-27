// Firebase configuration for Nigeria Health Care App
// Replace the placeholder values with your actual Firebase project credentials

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseConfig {
  static const String androidApiKey = "YOUR_ANDROID_API_KEY";
  static const String iosApiKey = "YOUR_IOS_API_KEY";
  static const String appId = "1:123456789:android:abcdef123456";
  static const String messagingSenderId = "123456789";
  static const String projectId = "nigeria-health-care";
  static const String storageBucket = "nigeria-health-care.appspot.com";

  static Future<void> initialize() async {
    await firebase_core.Firebase.initializeApp(
      options: const firebase_core.FirebaseOptions(
        apiKey: androidApiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      ),
    );

    // Set messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background messages
  }

  // Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  // Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Storage instance
  static FirebaseStorage get storage => FirebaseStorage.instance;

  // Messaging instance
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // Authentication methods
  static Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
