import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/feature_flags.dart';

class FeatureFlagService {
  FeatureFlagService({
    FirebaseFirestore? firestore,
    Stream<Map<String, dynamic>?> Function()? remoteStreamFactory,
  }) : _firestore = firestore,
       _remoteStreamFactory = remoteStreamFactory;

  final FirebaseFirestore? _firestore;
  final Stream<Map<String, dynamic>?> Function()? _remoteStreamFactory;

  Map<String, bool> get defaults =>
      Map<String, bool>.from(FeatureFlagDefaults.values);

  Stream<Map<String, bool>> watchFlags() async* {
    yield defaults;

    try {
      await for (final remote in _remoteFlagsStream()) {
        final merged = Map<String, bool>.from(defaults)
          ..addAll(_normalizeRemote(remote));
        yield merged;
      }
    } catch (_) {
      // Keep defaults if remote flags are unavailable.
      yield defaults;
    }
  }

  Stream<Map<String, dynamic>?> _remoteFlagsStream() {
    if (_remoteStreamFactory != null) {
      return _remoteStreamFactory.call();
    }

    final firestore = _firestore ?? FirebaseFirestore.instance;
    return firestore
        .collection('config')
        .doc('feature_flags')
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  Map<String, bool> _normalizeRemote(Map<String, dynamic>? remote) {
    if (remote == null) {
      return <String, bool>{};
    }

    final normalized = <String, bool>{};
    for (final key in FeatureFlagKeys.all) {
      final value = remote[key];
      if (value is bool) {
        normalized[key] = value;
      }
    }
    return normalized;
  }
}
