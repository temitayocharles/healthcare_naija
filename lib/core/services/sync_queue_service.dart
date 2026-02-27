import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../models/appointment.dart';
import '../../models/provider.dart';
import '../../models/user.dart';
import '../../services/firestore_service.dart';
import 'connectivity_service.dart';
import 'storage_service.dart';

class SyncQueueOperation {
  SyncQueueOperation({
    required this.type,
    required this.payload,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SyncQueueOperation.fromJson(Map<String, dynamic> json) {
    return SyncQueueOperation(
      type: json['type'] as String? ?? '',
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const <String, dynamic>{}),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SyncQueueService {
  SyncQueueService(this._storageService, this._connectivityService);

  static const String _queueKey = 'sync_queue';
  static const String upsertUserType = 'upsert_user';
  static const String upsertProviderType = 'upsert_provider';
  static const String upsertAppointmentType = 'upsert_appointment';

  final StorageService _storageService;
  final ConnectivityService _connectivityService;
  final StreamController<int> _pendingCountController = StreamController<int>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isFlushing = false;

  Stream<int> get pendingCountStream => _pendingCountController.stream;

  void initialize() {
    _connectivitySub?.cancel();
    _emitPendingCount();
    _connectivitySub = _connectivityService.connectivityStream.listen((_) async {
      await flushQueue();
    });
  }

  Future<void> enqueue(SyncQueueOperation operation) async {
    final current = _getQueue();
    current.add(operation);
    await _saveQueue(current);
    await flushQueue();
  }

  Future<void> enqueueUpsertUser(User user) {
    return enqueue(
      SyncQueueOperation(
        type: upsertUserType,
        payload: user.toJson(),
      ),
    );
  }

  Future<void> enqueueUpsertProvider(HealthcareProvider provider) {
    return enqueue(
      SyncQueueOperation(
        type: upsertProviderType,
        payload: provider.toJson(),
      ),
    );
  }

  Future<void> enqueueUpsertAppointment(Appointment appointment) {
    return enqueue(
      SyncQueueOperation(
        type: upsertAppointmentType,
        payload: appointment.toJson(),
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
        final synced = await _trySync(op);
        if (!synced) {
          remaining.add(op);
        }
      }
      await _saveQueue(remaining);
    } finally {
      _isFlushing = false;
    }
  }

  List<SyncQueueOperation> pendingOperations() {
    return _getQueue();
  }

  Future<void> clearQueue() async {
    await _saveQueue(<SyncQueueOperation>[]);
  }

  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _pendingCountController.close();
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
    _emitPendingCount();
  }

  void _emitPendingCount() {
    if (_pendingCountController.isClosed) {
      return;
    }
    _pendingCountController.add(_getQueue().length);
  }

  Future<bool> _trySync(SyncQueueOperation op) async {
    try {
      switch (op.type) {
        case upsertUserType:
          await FirestoreService.createUser(User.fromJson(op.payload));
          return true;
        case upsertProviderType:
          await FirestoreService.createProvider(HealthcareProvider.fromJson(op.payload));
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
