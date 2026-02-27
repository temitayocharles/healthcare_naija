import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nigeria_health_care/core/services/connectivity_service.dart';
import 'package:nigeria_health_care/core/services/storage_service.dart';
import 'package:nigeria_health_care/core/services/sync_queue_service.dart';
import 'package:nigeria_health_care/models/appointment.dart';

class _FakeConnectivityService extends ConnectivityService {
  bool connected = false;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<bool> isConnected() async => connected;

  @override
  Stream<List<ConnectivityResult>> get connectivityStream => _controller.stream;
}

class _FakeStorageService extends StorageService {
  final Map<String, dynamic> _settings = <String, dynamic>{};
  final Map<String, Appointment> _appointments = <String, Appointment>{};

  @override
  Future<void> setSetting(String key, dynamic value) async {
    _settings[key] = value;
  }

  @override
  T? getSetting<T>(String key) {
    return _settings[key] as T?;
  }

  @override
  Appointment? getCachedAppointmentById(String id) {
    return _appointments[id];
  }
}

void main() {
  group('SyncQueueService', () {
    late _FakeStorageService storage;
    late _FakeConnectivityService connectivity;
    late SyncQueueService service;

    setUp(() {
      storage = _FakeStorageService();
      connectivity = _FakeConnectivityService();
      service = SyncQueueService(storage, connectivity);
    });

    test('dedupe keeps latest operation per entity/op type key', () {
      final op1 = SyncQueueOperation(
        operationId: '1',
        entityType: SyncQueueService.entityUser,
        entityId: 'u1',
        opType: SyncQueueService.upsertUserType,
        payload: <String, dynamic>{'name': 'first'},
      );
      final op2 = SyncQueueOperation(
        operationId: '2',
        entityType: SyncQueueService.entityUser,
        entityId: 'u1',
        opType: SyncQueueService.upsertUserType,
        payload: <String, dynamic>{'name': 'second'},
      );
      final deduped = service.dedupeOperations(<SyncQueueOperation>[op1, op2]);
      expect(deduped.length, 1);
      expect(deduped.first.payload['name'], 'second');
    });

    test('schedule retry increments attempts and sets next retry', () {
      final op = SyncQueueOperation(
        operationId: 'op',
        entityType: SyncQueueService.entityProvider,
        entityId: 'p1',
        opType: SyncQueueService.upsertProviderType,
        payload: const <String, dynamic>{},
      );
      final retried = service.scheduleRetryForTest(op);
      expect(retried.attemptCount, 1);
      expect(retried.lastAttemptAt, isNotNull);
      expect(retried.nextRetryAt, isNotNull);
      expect(retried.nextRetryAt!.isAfter(DateTime.now().subtract(const Duration(seconds: 1))), isTrue);
    });
  });
}
