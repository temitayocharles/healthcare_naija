import 'package:flutter_test/flutter_test.dart';

import 'package:nigeria_health_care/core/services/ai_service.dart';

void main() {
  test('AIService forceOffline returns offline triage response', () async {
    final service = AIService();

    final result = await service.analyzeSymptoms([
      'fever',
      'cough',
    ], forceOffline: true);

    expect(result['is_offline'], isTrue);
    expect(result['triage_only'], isTrue);
    expect(result['severity'], isNotNull);
    expect(result['recommendation'], isNotNull);
  });
}
