import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nigeria_health_care/core/config/feature_flags.dart';
import 'package:nigeria_health_care/core/providers/providers.dart';

void main() {
  test('featureEnabledProvider honors runtime kill switch values', () async {
    final container = ProviderContainer(
      overrides: [
        featureFlagsProvider.overrideWith(
          (ref) => Stream<Map<String, bool>>.value({
            FeatureFlagKeys.chatAttachmentsEnabled: false,
            FeatureFlagKeys.healthRecordSharingEnabled: false,
            FeatureFlagKeys.chatEnabled: true,
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(featureFlagsProvider.future);

    expect(
      container.read(featureEnabledProvider(FeatureFlagKeys.chatEnabled)),
      isTrue,
    );
    expect(
      container.read(
        featureEnabledProvider(FeatureFlagKeys.chatAttachmentsEnabled),
      ),
      isFalse,
    );
    expect(
      container.read(
        featureEnabledProvider(FeatureFlagKeys.healthRecordSharingEnabled),
      ),
      isFalse,
    );
  });

  test(
    'featureEnabledProvider falls back to defaults when runtime values unavailable',
    () {
      final controller = StreamController<Map<String, bool>>();
      final container = ProviderContainer(
        overrides: [
          featureFlagsProvider.overrideWith((ref) => controller.stream),
        ],
      );
      addTearDown(() async {
        await controller.close();
        container.dispose();
      });

      expect(
        container.read(featureEnabledProvider(FeatureFlagKeys.chatEnabled)),
        FeatureFlagDefaults.valueFor(FeatureFlagKeys.chatEnabled),
      );
    },
  );
}
