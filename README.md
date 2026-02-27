# Nigeria Health Care App

Nigeria Health Care App is a Flutter-based digital healthcare platform for Nigeria, built for multi-platform delivery (Android, iOS, Web, Desktop baseline).

The app combines:
- Patient onboarding and authentication
- Provider discovery
- Appointment booking and management
- Health record upload and sharing
- Symptom triage support
- Offline-first synchronization
- Patient-caregiver chat with guarded attachments

## Tech Stack

- Flutter + Dart
- Riverpod (state management)
- Firebase Auth
- Firestore
- Firebase Storage
- Hive (offline/local persistence)
- Go Router (navigation)

## Core Features

- Authentication:
  - Email sign in and registration
  - Guest continuation mode
  - Session state handling in app routing

- Provider discovery:
  - Search, filter, and sort providers
  - Provider details and booking entrypoint

- Appointments:
  - Create booking from provider flow
  - View upcoming/past/cancelled appointments
  - Cancel pending appointments

- Health records:
  - Upload file with guardrails (type/size checks)
  - Persist metadata to Firestore
  - Optional caregiver-share metadata

- Chat:
  - Patient-caregiver messaging
  - Attachment upload with guardrails

- Offline-first:
  - Local cache via Hive
  - Sync queue with retry/dedupe/dead-letter metrics
  - Sync status badge + diagnostics screen

## Architecture

High-level flow:

`UI -> Riverpod Providers -> Repositories -> Local/Remote Data Sources -> Hive/Firebase`

Important boundaries:
- UI does not call Firestore/Hive directly.
- Repositories own online/offline behavior.
- Sync queue handles deferred writes and replay.

## Project Structure

```text
lib/
  app.dart
  main.dart
  core/
    config/
    constants/
    datasources/
      local/
      remote/
    errors/
    providers/
    repositories/
    result/
    services/
    theme/
    utils/
  features/
    auth/
    home/
    provider_search/
    appointments/
    health_records/
    symptom_checker/
    chat/
    profile/
    emergency/
    telemedicine/
  models/
  services/
  widgets/
```

## Getting Started

### 1. Prerequisites

Install:
- Flutter stable SDK
- Node.js 20+
- Firebase CLI (`npm i -g firebase-tools`)

Verify:

```bash
flutter --version
flutter doctor
firebase --version
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run Locally

```bash
flutter run -d chrome
```

### 4. Quality Checks

```bash
flutter analyze
flutter test
```

## Firebase Configuration

### iOS

1. Download `GoogleService-Info.plist` from Firebase Console for the iOS app.
2. Place it at `ios/Runner/GoogleService-Info.plist`.
3. Ensure your iOS bundle ID in Xcode matches Firebase app bundle ID.

### Web

For web builds, provide Firebase values via `--dart-define`:

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=...
```

Quick start with env file:

```bash
source .env.firebase.local
scripts/run_web_with_firebase.sh
```

If Firebase is not configured in the runtime environment, protected Firebase-backed features may not function.

Notes:
- Firebase Web API keys are not secrets, but must be restricted in Google Cloud (HTTP referrers, API scope).
- AI provider keys (example `OPENAI_API_KEY`) are secrets and must not be committed.

## Deployment

### Local script deploys

Staging:

```bash
scripts/deploy_staging.sh
```

Production:

```bash
scripts/deploy_production.sh
```

### GitHub Actions deploys

- `.github/workflows/deploy_staging.yml`
- `.github/workflows/deploy_production.yml`

Required secrets:
- `FIREBASE_TOKEN`
- `FIREBASE_PROJECT_ID_STAGING`
- `FIREBASE_PROJECT_ID_PRODUCTION`

## Security Baseline

- Firestore rules with per-collection schema/role checks
- Storage rules with owner-scoped upload paths
- Upload guardrails:
  - Allowed types: `jpg`, `jpeg`, `png`, `pdf`
  - Max size: `10MB`
- No destructive public write paths by default

Security artifacts:
- `firestore.rules`
- `firestore.indexes.json`
- `storage.rules`

## Assets

Primary UI visuals are in:
- `assets/images/`

These include hero/banner/profile/provider placeholders wired into key screens.

## Documentation

See `docs/` for operational and delivery documentation, including:
- onboarding runbook
- environment setup
- clinical safety guardrails
- security baseline
- testing plan
- release signoff docs

## License

MIT
