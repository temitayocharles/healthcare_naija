# Feature Flags Baseline

This document defines the initial rollout policy for runtime feature flags.

Runtime source:
- Firestore document: `config/feature_flags`

Fallback source:
- Build-time defaults via `--dart-define` (`FF_*` vars in `.env.firebase.example`)

Precedence:
1. Firestore runtime values
2. Build-time values
3. App fallback defaults

## Initial Recommended Values

## Production (`prod`)

Use conservative defaults until monitored rollout is complete:

```json
{
  "ff_chat_enabled": true,
  "ff_chat_attachments_enabled": false,
  "ff_health_record_sharing_enabled": true,
  "ff_appointment_reschedule_enabled": true,
  "ff_emergency_location_share_enabled": false,
  "ff_provider_reviews_enabled": false,
  "ff_ai_triage_enabled": false,
  "ff_payments_enabled": false,
  "ff_admin_console_enabled": false,
  "ff_maps_enabled": false
}
```

## Staging (`staging`)

Enable broader validation scope:

```json
{
  "ff_chat_enabled": true,
  "ff_chat_attachments_enabled": true,
  "ff_health_record_sharing_enabled": true,
  "ff_appointment_reschedule_enabled": true,
  "ff_emergency_location_share_enabled": true,
  "ff_provider_reviews_enabled": true,
  "ff_ai_triage_enabled": false,
  "ff_payments_enabled": false,
  "ff_admin_console_enabled": true,
  "ff_maps_enabled": true
}
```

## Development (`dev`)

Use permissive values for testing:

```json
{
  "ff_chat_enabled": true,
  "ff_chat_attachments_enabled": true,
  "ff_health_record_sharing_enabled": true,
  "ff_appointment_reschedule_enabled": true,
  "ff_emergency_location_share_enabled": true,
  "ff_provider_reviews_enabled": true,
  "ff_ai_triage_enabled": false,
  "ff_payments_enabled": false,
  "ff_admin_console_enabled": true,
  "ff_maps_enabled": true
}
```

## Rollout Policy

1. Every high-risk feature starts disabled in `prod`.
2. Enable in phases: internal -> 5% -> 20% -> 50% -> 100%.
3. Track errors/crash rate for 24-48h per phase.
4. If severity-1 issues appear, set flag to `false` as kill switch.

## Update Procedure

1. Open Firestore Console for the target Firebase project.
2. Edit document `config/feature_flags`.
3. Set only known keys (unknown keys are ignored).
4. Validate behavior in app and check logs/metrics.

## Security

- Rules permit public read of `config/*` and admin-only write.
- Never store secrets in feature-flag documents.
