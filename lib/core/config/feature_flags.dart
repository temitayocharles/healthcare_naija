class FeatureFlagKeys {
  FeatureFlagKeys._();

  static const String chatEnabled = 'ff_chat_enabled';
  static const String chatAttachmentsEnabled = 'ff_chat_attachments_enabled';
  static const String healthRecordSharingEnabled =
      'ff_health_record_sharing_enabled';
  static const String appointmentRescheduleEnabled =
      'ff_appointment_reschedule_enabled';
  static const String emergencyLocationShareEnabled =
      'ff_emergency_location_share_enabled';
  static const String providerReviewsEnabled = 'ff_provider_reviews_enabled';
  static const String aiTriageEnabled = 'ff_ai_triage_enabled';
  static const String paymentsEnabled = 'ff_payments_enabled';
  static const String adminConsoleEnabled = 'ff_admin_console_enabled';
  static const String mapsEnabled = 'ff_maps_enabled';

  static const List<String> all = [
    chatEnabled,
    chatAttachmentsEnabled,
    healthRecordSharingEnabled,
    appointmentRescheduleEnabled,
    emergencyLocationShareEnabled,
    providerReviewsEnabled,
    aiTriageEnabled,
    paymentsEnabled,
    adminConsoleEnabled,
    mapsEnabled,
  ];
}

class FeatureFlagDefaults {
  FeatureFlagDefaults._();

  static const bool _chatEnabled = bool.fromEnvironment(
    'FF_CHAT_ENABLED',
    defaultValue: true,
  );
  static const bool _chatAttachmentsEnabled = bool.fromEnvironment(
    'FF_CHAT_ATTACHMENTS_ENABLED',
    defaultValue: true,
  );
  static const bool _healthRecordSharingEnabled = bool.fromEnvironment(
    'FF_HEALTH_RECORD_SHARING_ENABLED',
    defaultValue: true,
  );
  static const bool _appointmentRescheduleEnabled = bool.fromEnvironment(
    'FF_APPOINTMENT_RESCHEDULE_ENABLED',
    defaultValue: true,
  );
  static const bool _emergencyLocationShareEnabled = bool.fromEnvironment(
    'FF_EMERGENCY_LOCATION_SHARE_ENABLED',
    defaultValue: false,
  );
  static const bool _providerReviewsEnabled = bool.fromEnvironment(
    'FF_PROVIDER_REVIEWS_ENABLED',
    defaultValue: false,
  );
  static const bool _aiTriageEnabled = bool.fromEnvironment(
    'FF_AI_TRIAGE_ENABLED',
    defaultValue: false,
  );
  static const bool _paymentsEnabled = bool.fromEnvironment(
    'FF_PAYMENTS_ENABLED',
    defaultValue: false,
  );
  static const bool _adminConsoleEnabled = bool.fromEnvironment(
    'FF_ADMIN_CONSOLE_ENABLED',
    defaultValue: false,
  );
  static const bool _mapsEnabled = bool.fromEnvironment(
    'FF_MAPS_ENABLED',
    defaultValue: false,
  );

  static const Map<String, bool> values = {
    FeatureFlagKeys.chatEnabled: _chatEnabled,
    FeatureFlagKeys.chatAttachmentsEnabled: _chatAttachmentsEnabled,
    FeatureFlagKeys.healthRecordSharingEnabled: _healthRecordSharingEnabled,
    FeatureFlagKeys.appointmentRescheduleEnabled: _appointmentRescheduleEnabled,
    FeatureFlagKeys.emergencyLocationShareEnabled:
        _emergencyLocationShareEnabled,
    FeatureFlagKeys.providerReviewsEnabled: _providerReviewsEnabled,
    FeatureFlagKeys.aiTriageEnabled: _aiTriageEnabled,
    FeatureFlagKeys.paymentsEnabled: _paymentsEnabled,
    FeatureFlagKeys.adminConsoleEnabled: _adminConsoleEnabled,
    FeatureFlagKeys.mapsEnabled: _mapsEnabled,
  };

  static bool valueFor(String key) => values[key] ?? false;
}
