const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');

let testEnv;

before(async () => {
  const firestoreRulesPath = path.resolve(__dirname, '..', 'firestore.rules');
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-nigeria-healthcare',
    firestore: {
      rules: fs.readFileSync(firestoreRulesPath, 'utf8'),
    },
  });
});

after(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

test('users: owner can write own profile', async () => {
  const db = testEnv.authenticatedContext('user_a').firestore();
  await assertSucceeds(
    db.collection('users').doc('user_a').set({
      id: 'user_a',
      email: null,
      phone: '08012345678',
      name: 'User A',
      role: 'patient',
      profileImageUrl: null,
      state: null,
      lga: null,
      address: null,
      latitude: null,
      longitude: null,
      createdAt: new Date().toISOString(),
      isVerified: false,
      medicalHistory: null,
    }),
  );
});

test('users: non-owner cannot write another user profile', async () => {
  const db = testEnv.authenticatedContext('user_a').firestore();
  await assertFails(
    db.collection('users').doc('user_b').set({
      id: 'user_b',
      email: null,
      phone: '08012345678',
      name: 'User B',
      role: 'patient',
      profileImageUrl: null,
      state: null,
      lga: null,
      address: null,
      latitude: null,
      longitude: null,
      createdAt: new Date().toISOString(),
      isVerified: false,
      medicalHistory: null,
    }),
  );
});

test('appointments: patient can create own appointment', async () => {
  const db = testEnv.authenticatedContext('patient_1').firestore();
  await assertSucceeds(
    db.collection('appointments').doc('a1').set({
      id: 'a1',
      patientId: 'patient_1',
      providerId: 'provider_1',
      providerName: 'Provider',
      providerType: 'Physician',
      dateTime: new Date().toISOString(),
      status: 'pending',
      notes: null,
      symptoms: null,
      createdAt: new Date().toISOString(),
      isEmergency: false,
      appointmentType: 'in_person',
    }),
  );
});

test('appointments: patient cannot create for another patient', async () => {
  const db = testEnv.authenticatedContext('patient_1').firestore();
  await assertFails(
    db.collection('appointments').doc('a2').set({
      id: 'a2',
      patientId: 'patient_2',
      providerId: 'provider_1',
      providerName: 'Provider',
      providerType: 'Physician',
      dateTime: new Date().toISOString(),
      status: 'pending',
      notes: null,
      symptoms: null,
      createdAt: new Date().toISOString(),
      isEmergency: false,
      appointmentType: 'in_person',
    }),
  );
});

test('health_record_shares: patient can create share for caregiver', async () => {
  const db = testEnv.authenticatedContext('patient_1').firestore();
  await assertSucceeds(
    db.collection('health_record_shares').doc('share_1').set({
      recordId: 'record_1',
      patientId: 'patient_1',
      caregiverId: 'caregiver_1',
      fileUrl: 'https://example.com/r.pdf',
      title: 'Lab Result',
      sharedAt: new Date().toISOString(),
    }),
  );
});

test('health_record_shares: non-owner cannot create share for another patient', async () => {
  const db = testEnv.authenticatedContext('intruder').firestore();
  await assertFails(
    db.collection('health_record_shares').doc('share_2').set({
      recordId: 'record_1',
      patientId: 'patient_1',
      caregiverId: 'caregiver_1',
      fileUrl: 'https://example.com/r.pdf',
      title: 'Lab Result',
      sharedAt: new Date().toISOString(),
    }),
  );
});

test('conversations: participant can create conversation and message', async () => {
  const db = testEnv.authenticatedContext('patient_1').firestore();
  await assertSucceeds(
    db.collection('conversations').doc('c1').set({
      participants: ['patient_1', 'caregiver_1'],
      lastMessage: null,
      lastMessageAt: new Date().toISOString(),
    }),
  );

  await assertSucceeds(
    db.collection('conversations').doc('c1').collection('messages').doc('m1').set({
      id: 'm1',
      senderId: 'patient_1',
      receiverId: 'caregiver_1',
      text: 'hello',
      attachmentUrl: null,
      attachmentName: null,
      attachmentType: null,
      sharedRecordId: null,
      createdAt: new Date().toISOString(),
    }),
  );
});

test('conversations: outsider cannot read messages', async () => {
  const adminDb = testEnv.unauthenticatedContext().firestore();
  assert.ok(adminDb);
  const participantDb = testEnv.authenticatedContext('patient_1').firestore();
  await assertSucceeds(
    participantDb.collection('conversations').doc('c2').set({
      participants: ['patient_1', 'caregiver_1'],
      lastMessage: null,
      lastMessageAt: new Date().toISOString(),
    }),
  );
  await assertSucceeds(
    participantDb.collection('conversations').doc('c2').collection('messages').doc('m1').set({
      id: 'm1',
      senderId: 'patient_1',
      receiverId: 'caregiver_1',
      text: 'private',
      attachmentUrl: null,
      attachmentName: null,
      attachmentType: null,
      sharedRecordId: null,
      createdAt: new Date().toISOString(),
    }),
  );

  const outsiderDb = testEnv.authenticatedContext('outsider').firestore();
  await assertFails(
    outsiderDb.collection('conversations').doc('c2').collection('messages').doc('m1').get(),
  );
});

test('config: unauthenticated user can read feature flags', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('config').doc('feature_flags').set({
      ff_chat_enabled: true,
    });
  });

  const db = testEnv.unauthenticatedContext().firestore();
  await assertSucceeds(db.collection('config').doc('feature_flags').get());
});

test('config: non-admin cannot write feature flags', async () => {
  const db = testEnv.authenticatedContext('regular_user').firestore();
  await assertFails(
    db.collection('config').doc('feature_flags').set({
      ff_chat_enabled: false,
    }),
  );
});
