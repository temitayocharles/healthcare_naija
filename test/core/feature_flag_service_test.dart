import 'package:flutter_test/flutter_test.dart';

import 'package:nigeria_health_care/core/config/feature_flags.dart';
import 'package:nigeria_health_care/core/services/feature_flag_service.dart';

void main() {
  test('FeatureFlagService emits defaults first', () async {
    final service = FeatureFlagService(
      remoteStreamFactory: () => const Stream<Map<String, dynamic>?>.empty(),
    );

    final first = await service.watchFlags().first;

    expect(
      first[FeatureFlagKeys.chatEnabled],
      FeatureFlagDefaults.valueFor(FeatureFlagKeys.chatEnabled),
    );
    expect(
      first[FeatureFlagKeys.aiTriageEnabled],
      FeatureFlagDefaults.valueFor(FeatureFlagKeys.aiTriageEnabled),
    );
  });

  test(
    'FeatureFlagService remote values override defaults and ignore unknown keys',
    () async {
      final service = FeatureFlagService(
        remoteStreamFactory: () => Stream<Map<String, dynamic>?>.fromIterable([
          {
            FeatureFlagKeys.chatAttachmentsEnabled: false,
            FeatureFlagKeys.healthRecordSharingEnabled: false,
            'unknown_key': true,
          },
        ]),
      );

      final emitted = await service.watchFlags().take(2).toList();
      final merged = emitted.last;

      expect(merged[FeatureFlagKeys.chatAttachmentsEnabled], isFalse);
      expect(merged[FeatureFlagKeys.healthRecordSharingEnabled], isFalse);
      expect(merged.containsKey('unknown_key'), isFalse);
    },
  );

  test('FeatureFlagService keeps defaults when remote stream fails', () async {
    final service = FeatureFlagService(
      remoteStreamFactory: () =>
          Stream<Map<String, dynamic>?>.error(Exception('boom')),
    );

    final emitted = await service.watchFlags().take(2).toList();

    expect(
      emitted.first[FeatureFlagKeys.chatEnabled],
      FeatureFlagDefaults.valueFor(FeatureFlagKeys.chatEnabled),
    );
    expect(
      emitted.last[FeatureFlagKeys.chatEnabled],
      FeatureFlagDefaults.valueFor(FeatureFlagKeys.chatEnabled),
    );
  });
}
