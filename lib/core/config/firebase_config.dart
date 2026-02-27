import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static bool get hasWebOptions =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty &&
      storageBucket.isNotEmpty;

  static Future<bool> initialize() async {
    if (firebase_core.Firebase.apps.isNotEmpty) {
      return true;
    }

    try {
      if (kIsWeb) {
        if (!hasWebOptions) {
          debugPrint(
            'Firebase not initialized on web: missing dart-define Firebase options.',
          );
          return false;
        }
        await firebase_core.Firebase.initializeApp(
          options: const firebase_core.FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
            storageBucket: storageBucket,
          ),
        );
      } else {
        await firebase_core.Firebase.initializeApp();
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      return true;
    } catch (error) {
      debugPrint('Firebase initialization skipped/failed: $error');
      return false;
    }
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

  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) {
    return auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() {
    return auth.signOut();
  }
}
