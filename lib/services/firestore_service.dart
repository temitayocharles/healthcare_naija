import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
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

  static Future<void> upsertUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  // Health Records
  static Future<List<HealthRecord>> getHealthRecords(String userId) async {
    final snapshots = await _firestore.collection('health_records').where('userId', isEqualTo: userId).get();
    return snapshots.docs.map((snapshot) => HealthRecord.fromJson(snapshot.data())).toList();
  }

  static Future<void> createHealthRecord(HealthRecord healthRecord) async {
    await _firestore.collection('health_records').doc(healthRecord.id).set(
          healthRecord.toJson(),
          SetOptions(merge: true),
        );
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

  static Future<List<HealthcareProvider>> getAllProviders() async {
    final snapshots = await _firestore.collection('providers').get();
    return snapshots.docs.map((snapshot) => HealthcareProvider.fromJson(snapshot.data())).toList();
  }

  static Future<void> upsertProvider(HealthcareProvider provider) async {
    await _firestore.collection('providers').doc(provider.id).set(provider.toJson(), SetOptions(merge: true));
  }

  // Symptom Records
  static Future<List<SymptomRecord>> getSymptomRecords(String userId) async {
    final snapshots = await _firestore.collection('symptom_records').where('userId', isEqualTo: userId).get();
    return snapshots.docs.map((snapshot) => SymptomRecord.fromJson(snapshot.data())).toList();
  }

  static Future<void> createSymptomRecord(SymptomRecord symptomRecord) async {
    await _firestore.collection('symptom_records').doc(symptomRecord.id).set(
          symptomRecord.toJson(),
          SetOptions(merge: true),
        );
  }

  // Appointments
  static Future<List<Appointment>> getAppointments(String userId) async {
    final snapshots = await _firestore.collection('appointments').where('patientId', isEqualTo: userId).get();
    return snapshots.docs.map((snapshot) => Appointment.fromJson(snapshot.data())).toList();
  }

  static Future<void> upsertAppointment(Appointment appointment) async {
    await _firestore.collection('appointments').doc(appointment.id).set(appointment.toJson(), SetOptions(merge: true));
  }

  static Future<void> shareHealthRecordWithCaregiver({
    required String recordId,
    required String patientId,
    required String caregiverId,
    required String fileUrl,
    required String title,
  }) async {
    final shareId = '${recordId}_$caregiverId';
    await _firestore.collection('health_record_shares').doc(shareId).set(
      <String, dynamic>{
        'recordId': recordId,
        'patientId': patientId,
        'caregiverId': caregiverId,
        'fileUrl': fileUrl,
        'title': title,
        'sharedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }

  static String conversationIdFor(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Stream<List<Map<String, dynamic>>> watchConversationMessages({
    required String currentUserId,
    required String otherUserId,
  }) {
    final conversationId = conversationIdFor(currentUserId, otherUserId);
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshots) => snapshots.docs.map((d) => d.data()).toList());
  }

  static Future<void> sendConversationMessage({
    required String senderId,
    required String receiverId,
    String? text,
    String? attachmentUrl,
    String? attachmentName,
    String? attachmentType,
    String? sharedRecordId,
  }) async {
    final conversationId = conversationIdFor(senderId, receiverId);
    final now = DateTime.now().toIso8601String();
    await _firestore.collection('conversations').doc(conversationId).set({
      'participants': [senderId, receiverId],
      'lastMessage': text ?? attachmentName ?? 'Attachment',
      'lastMessageAt': now,
    }, SetOptions(merge: true));

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();
    await messageRef.set({
      'id': messageRef.id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'attachmentType': attachmentType,
      'sharedRecordId': sharedRecordId,
      'createdAt': now,
    });
  }
}
