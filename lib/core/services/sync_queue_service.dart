import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../models/appointment.dart';
import '../../models/provider.dart';
import '../../models/user.dart';
import '../../services/firestore_service.dart';
import 'connectivity_service.dart';
import 'storage_service.dart';

class SyncQueueOperation {
  SyncQueueOperation({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payload,
    this.payloadVersion = 1,
    this.attemptCount = 0,
    this.maxAttempts = 5,
    DateTime? createdAt,
    this.lastAttemptAt,
    this.nextRetryAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String operationId;
  final String entityType;
  final String entityId;
  final String opType;
  final Map<String, dynamic> payload;
  final int payloadVersion;
  final int attemptCount;
  final int maxAttempts;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? nextRetryAt;

  SyncQueueOperation copyWith({
    String? operationId,
    String? entityType,
    String? entityId,
    String? opType,
    Map<String, dynamic>? payload,
    int? payloadVersion,
    int? attemptCount,
    int? maxAttempts,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
  }) {
    return SyncQueueOperation(
      operationId: operationId ?? this.operationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payload: payload ?? this.payload,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'operationId': operationId,
      'entityType': entityType,
      'entityId': entityId,
      'opType': opType,
      'payload': payload,
      'payloadVersion': payloadVersion,
      'attemptCount': attemptCount,
      'maxAttempts': maxAttempts,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'nextRetryAt': nextRetryAt?.toIso8601String(),
    };
  }

  factory SyncQueueOperation.fromJson(Map<String, dynamic> json) {
    return SyncQueueOperation(
      operationId: json['operationId'] as String? ?? const Uuid().v4(),
      entityType: json['entityType'] as String? ?? 'unknown',
      entityId: json['entityId'] as String? ?? '',
      opType: json['opType'] as String? ?? 'upsert',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const <String, dynamic>{}),
      payloadVersion: json['payloadVersion'] as int? ?? 1,
      attemptCount: json['attemptCount'] as int? ?? 0,
      maxAttempts: json['maxAttempts'] as int? ?? 5,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      lastAttemptAt: DateTime.tryParse(json['lastAttemptAt'] as String? ?? ''),
      nextRetryAt: DateTime.tryParse(json['nextRetryAt'] as String? ?? ''),
    );
  }
}

class SyncQueueService {
  SyncQueueService(this._storageService, this._connectivityService);

  static const String _queueKey = 'sync_queue';
  static const String _deadLetterKey = 'sync_dead_letter';
  static const String _lastSyncKey = 'sync_last_success_at';

  static const String entityUser = 'user';
  static const String entityProvider = 'provider';
  static const String entityAppointment = 'appointment';

  static const String upsertUserType = 'upsert_user';
  static const String upsertProviderType = 'upsert_provider';
  static const String upsertAppointmentType = 'upsert_appointment';

  final StorageService _storageService;
  final ConnectivityService _connectivityService;
  final StreamController<int> _pendingCountController = StreamController<int>.broadcast();
  final StreamController<int> _failedCountController = StreamController<int>.broadcast();
  final StreamController<DateTime?> _lastSyncController = StreamController<DateTime?>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isFlushing = false;

  Stream<int> get pendingCountStream => _pendingCountController.stream;
  Stream<int> get failedCountStream => _failedCountController.stream;
  Stream<DateTime?> get lastSyncStream => _lastSyncController.stream;

  void initialize() {
    _connectivitySub?.cancel();
    _emitStatus();
    _connectivitySub = _connectivityService.connectivityStream.listen((_) async {
      await flushQueue();
    });
  }

  Future<void> enqueue(SyncQueueOperation operation) async {
    final current = _getQueue();
    current.add(operation);
    final deduped = _dedupe(current);
    await _saveQueue(deduped);
    await flushQueue();
  }

  Future<void> enqueueUpsertUser(User user) {
    return enqueue(
      SyncQueueOperation(
        operationId: const Uuid().v4(),
        entityType: entityUser,
        entityId: user.id,
        opType: upsertUserType,
        payload: user.toJson(),
      ),
    );
  }

  Future<void> enqueueUpsertProvider(HealthcareProvider provider) {
    return enqueue(
      SyncQueueOperation(
        operationId: const Uuid().v4(),
        entityType: entityProvider,
        entityId: provider.id,
        opType: upsertProviderType,
        payload: provider.toJson(),
      ),
    );
  }

  Future<void> enqueueUpsertAppointment(Appointment appointment) {
    final validated = _applyAppointmentConflictPolicy(appointment);
    return enqueue(
      SyncQueueOperation(
        operationId: const Uuid().v4(),
        entityType: entityAppointment,
        entityId: validated.id,
        opType: upsertAppointmentType,
        payload: validated.toJson(),
      ),
    );
  }

  Future<void> flushQueue() async {
    if (_isFlushing) {
      return;
    }
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      return;
    }

    _isFlushing = true;
    try {
      final queue = _getQueue();
      if (queue.isEmpty) {
        return;
      }

      final remaining = <SyncQueueOperation>[];
      for (final op in queue) {
        if (op.nextRetryAt != null && DateTime.now().isBefore(op.nextRetryAt!)) {
          remaining.add(op);
          continue;
        }
        final synced = await _trySync(op);
        if (!synced) {
          final attempted = _scheduleRetry(op);
          if (attempted.attemptCount >= attempted.maxAttempts) {
            await _saveDeadLetter([..._getDeadLetter(), attempted]);
          } else {
            remaining.add(attempted);
          }
        }
      }
      final deduped = _dedupe(remaining);
      await _saveQueue(deduped);
      if (deduped.isEmpty) {
        final now = DateTime.now();
        await _storageService.setSetting(_lastSyncKey, now.toIso8601String());
      }
      _emitStatus();
    } finally {
      _isFlushing = false;
    }
  }

  List<SyncQueueOperation> pendingOperations() {
    return _getQueue();
  }

  Future<void> clearQueue() async {
    await _saveQueue(<SyncQueueOperation>[]);
    await _saveDeadLetter(<SyncQueueOperation>[]);
  }

  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _pendingCountController.close();
    _failedCountController.close();
    _lastSyncController.close();
  }

  List<SyncQueueOperation> _getQueue() {
    final raw = _storageService.getSetting<List<dynamic>>(_queueKey) ?? <dynamic>[];
    return raw
        .map((item) => SyncQueueOperation.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> _saveQueue(List<SyncQueueOperation> queue) async {
    await _storageService.setSetting(
      _queueKey,
      queue.map((op) => op.toJson()).toList(),
    );
    _emitStatus();
  }

  Future<void> _saveDeadLetter(List<SyncQueueOperation> failed) async {
    await _storageService.setSetting(
      _deadLetterKey,
      failed.map((op) => op.toJson()).toList(),
    );
    _emitStatus();
  }

  List<SyncQueueOperation> _getDeadLetter() {
    final raw = _storageService.getSetting<List<dynamic>>(_deadLetterKey) ?? <dynamic>[];
    return raw
        .map((item) => SyncQueueOperation.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  List<SyncQueueOperation> _dedupe(List<SyncQueueOperation> ops) {
    final map = <String, SyncQueueOperation>{};
    for (final op in ops) {
      map['${op.entityType}:${op.entityId}:${op.opType}'] = op;
    }
    return map.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @visibleForTesting
  List<SyncQueueOperation> dedupeOperations(List<SyncQueueOperation> ops) {
    return _dedupe(ops);
  }

  SyncQueueOperation _scheduleRetry(SyncQueueOperation op) {
    final nextAttempt = op.attemptCount + 1;
    final seconds = (1 << nextAttempt).clamp(2, 300);
    return op.copyWith(
      attemptCount: nextAttempt,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now().add(Duration(seconds: seconds)),
    );
  }

  @visibleForTesting
  SyncQueueOperation scheduleRetryForTest(SyncQueueOperation op) {
    return _scheduleRetry(op);
  }

  void _emitStatus() {
    if (_pendingCountController.isClosed) {
      return;
    }
    _pendingCountController.add(_getQueue().length);
    _failedCountController.add(_getDeadLetter().length);
    final raw = _storageService.getSetting<String>(_lastSyncKey);
    _lastSyncController.add(raw != null ? DateTime.tryParse(raw) : null);
  }

  Appointment _applyAppointmentConflictPolicy(Appointment next) {
    final existing = _storageService.getCachedAppointmentById(next.id);
    if (existing == null) {
      return next;
    }
    const terminalStates = <String>{'completed', 'cancelled'};
    if (terminalStates.contains(existing.status) && next.status == 'pending') {
      return next.copyWith(status: existing.status);
    }
    return next;
  }

  Future<bool> _trySync(SyncQueueOperation op) async {
    try {
      switch (op.opType) {
        case upsertUserType:
          await FirestoreService.upsertUser(User.fromJson(op.payload));
          return true;
        case upsertProviderType:
          await FirestoreService.upsertProvider(HealthcareProvider.fromJson(op.payload));
          return true;
        case upsertAppointmentType:
          await FirestoreService.upsertAppointment(Appointment.fromJson(op.payload));
          return true;
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }
}
