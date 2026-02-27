import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_record.dart';
import '../models/provider.dart';
import '../models/symptom_record.dart';
import '../models/user.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users
  static Future<User> getUser(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    return User.fromJson(snapshot.data()!);
  }

  static Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  // Health Records
  static Future<List<HealthRecord>> getHealthRecords(String userId) async {
    final snapshots = await _firestore.collection('health_records').where('userId', isEqualTo: userId).get();
    return snapshots.docs.map((snapshot) => HealthRecord.fromJson(snapshot.data())).toList();
  }

  static Future<void> createHealthRecord(HealthRecord healthRecord) async {
    await _firestore.collection('health_records').add(healthRecord.toJson());
  }

  // Providers
  static Future<List<HealthcareProvider>> getProviders(String state, String lga) async {
    final snapshots = await _firestore.collection('providers')
        .where('state', isEqualTo: state)
        .where('lga', isEqualTo: lga)
        .get();
    return snapshots.docs.map((snapshot) => HealthcareProvider.fromJson(snapshot.data())).toList();
  }

  static Future<void> createProvider(HealthcareProvider provider) async {
    await _firestore.collection('providers').add(provider.toJson());
  }

  // Symptom Records
  static Future<List<SymptomRecord>> getSymptomRecords(String userId) async {
    final snapshots = await _firestore.collection('symptom_records').where('userId', isEqualTo: userId).get();
    return snapshots.docs.map((snapshot) => SymptomRecord.fromJson(snapshot.data())).toList();
  }

  static Future<void> createSymptomRecord(SymptomRecord symptomRecord) async {
    await _firestore.collection('symptom_records').add(symptomRecord.toJson());
  }
}
