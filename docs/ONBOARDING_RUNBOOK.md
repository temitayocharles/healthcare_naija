# Onboarding Runbook

This document is the operational onboarding guide for engineers and operators working on `nigeria_healthcare_app`.

## 1. Current Baseline (as of 2026-02-27)

- Repository/data-source architecture is in place.
- Offline sync queue foundation is implemented (pending/failed/last-sync metrics).
- Firebase hosting/rules/index deployment workflow is added.
- CI workflow runs analyze + tests.
- `flutter analyze` and `flutter test` pass locally on latest validated branch.

## 2. Prerequisites

Install the following before doing anything else:

- Flutter stable SDK
- Dart SDK (comes with Flutter)
- Xcode (for iOS/macOS builds)
- Android Studio + SDK (for Android builds)
- Node.js 20+
- Firebase CLI (`npm i -g firebase-tools`)
- Git

Verify:

```bash
flutter --version
flutter doctor
node --version
firebase --version
git --version
```

## 3. First-Time Local Setup

From repo root:

```bash
flutter pub get
flutter analyze
flutter test
```

Generate code if needed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run app:

```bash
flutter run -d chrome
```

## 4. Environment and Tokens

## 4.1 Firebase Projects
Configured aliases are in `.firebaserc`:

- `default` -> `healthcare-naija`
- `staging` -> `healthcare-naija-staging`
- `production` -> `healthcare-naija`

## 4.2 GitHub Actions Secrets (Required)
Set in GitHub repo settings:

- `FIREBASE_TOKEN`
- `FIREBASE_PROJECT_ID_STAGING`
- `FIREBASE_PROJECT_ID_PRODUCTION`

Generate token:

```bash
firebase login:ci
```

## 4.3 Local Deploy Environment Variables
For local deploy scripts:

- `FIREBASE_PROJECT_ID_STAGING`
- `FIREBASE_PROJECT_ID_PRODUCTION`

Example:

```bash
export FIREBASE_PROJECT_ID_STAGING=healthcare-naija-staging
export FIREBASE_PROJECT_ID_PRODUCTION=healthcare-naija
```

## 4.4 AI API Token
AI token is **not auto-generated** for external providers. If using external AI APIs, you must supply keys explicitly (for example `OPENAI_API_KEY`) through secure env/secret management.

If no external key is provided, keep AI features in local/mock/fallback mode.

To enable remote AI triage safely, configure:

- `OPENAI_API_KEY`
- `OPENAI_BASE_URL` (optional)
- `OPENAI_MODEL` (optional)
- `ENABLE_AI_TRIAGE=true`

## 4.5 Firebase App Credentials (iOS + Web)

Use your Firebase project values:

- Project ID: `healthcare-naija`
- Storage bucket: `healthcare-naija.firebasestorage.app`
- Web `appId`: format `1:<sender-id>:web:<hash>`
- iOS `GoogleService-Info.plist` from Firebase Console
- Android `google-services.json` from Firebase Console

Android setup:

1. Firebase Console -> Project settings -> Your apps -> Add app -> Android.
2. Android package name must match app config exactly:
   `com.nigeriacare.nigeria_health_care`
3. Download `google-services.json`.
4. Place file at `android/app/google-services.json`.
5. Re-run `flutter clean && flutter pub get` once after adding it.

iOS setup:

1. Download `GoogleService-Info.plist` from Firebase Console (iOS app).
2. Place file at `ios/Runner/GoogleService-Info.plist`.
3. Confirm iOS bundle ID in Xcode equals Firebase iOS bundle ID.

Current iOS bundle ID in repo:
`com.nigeriacare.nigeriaHealthCare`

Web setup:

1. Copy `.env.firebase.example` to `.env.firebase.local`.
2. Fill your real Firebase values.
3. Source and run:

```bash
source .env.firebase.local
scripts/run_web_with_firebase.sh
```

Important:

- Firebase Web API keys are public identifiers; enforce restrictions in Google Cloud.
- `FIREBASE_TOKEN` (for deploy) and AI keys are secrets; keep in shell/CI secrets only.

## 4.6 Feature Flags (Build-Time + Runtime)

Build-time defaults:

- Set `FF_*` variables in `.env.firebase.local` (see `.env.firebase.example`).
- `scripts/run_web_with_firebase.sh` forwards those values as `--dart-define`.

Runtime overrides:

- Create/update Firestore document: `config/feature_flags`
- Use `docs/FEATURE_FLAGS_BASELINE.md` for recommended `dev/staging/prod` values
- Example keys:
  - `ff_chat_enabled`
  - `ff_chat_attachments_enabled`
  - `ff_health_record_sharing_enabled`
  - `ff_ai_triage_enabled`

Behavior:

- Runtime Firestore values override build-time defaults.
- Unknown keys are ignored.
- If Firestore flags cannot be loaded, app safely falls back to build-time defaults.

## 5. Deploy Commands

Local staging deploy:

```bash
source .env.firebase.local
scripts/deploy_staging.sh
```

Local production deploy:

```bash
source .env.firebase.local
scripts/deploy_production.sh
```

CI workflows:

- `.github/workflows/ci.yml`
- `.github/workflows/deploy_staging.yml`
- `.github/workflows/deploy_production.yml`

Firebase deploy config sources:

- `firebase.json`
- `.firebaserc`
- `firestore.rules`
- `firestore.indexes.json`

## 6. Storage and Media Strategy

## 6.1 Do We Need S3?
No, S3 is not required for this baseline. Media should use **Firebase Storage** for default production path.

## 6.2 Current Media State
- App currently uses mostly iconography/placeholders in UI.
- No full production media catalog has been committed yet.

## 6.3 Required Next Media Work
- Add real provider profile images
- Add health-record sample assets for UAT
- Add app-store screenshots (Android/iOS/web)
- Implement image resizing/compression policy before upload

Recommended path: create `assets/images/` (local placeholders) and use Firebase Storage for remote production media.

## 7. Maps Integration Status

Maps integration is not fully wired yet as a production map experience.

Pending items:

- Select provider (Google Maps or Mapbox)
- Add API key handling per environment
- Wire provider location list -> map markers
- Add privacy notice and location permission UX

## 8. Daily Engineer Workflow

1. Pull latest `main`.
2. Run `flutter pub get`.
3. Run `flutter analyze`.
4. Run `flutter test`.
5. Implement scoped changes in feature branch.
6. Re-run analyze/tests.
7. Open PR with evidence (logs/screenshots).

## 9. Release Checklist (Minimum)

- Analyzer clean
- Tests green
- Firestore rules validated
- Staging deploy successful
- UAT smoke pass
- Production deploy approved

## 10. Guardrails (Non-Negotiable)

- Do not remove Hive `part` directives.
- Do not delete model fields without migration.
- Do not convert constructors to `factory` unless explicitly required and tested.
- Do not bypass repository layer from UI.
- Do not commit secrets.
- Do not force push to `main`.

## 11. Troubleshooting Quick Notes

`No pubspec.yaml file found`:
- You are in wrong directory. Move to repo root and rerun.

`Could not find package build_runner`:
- Ensure `build_runner` exists in `dev_dependencies`, then run `flutter pub get`.

Firebase deploy auth failure:
- Regenerate `FIREBASE_TOKEN` with `firebase login:ci`.

Analyzer suddenly fails with package URI errors:
- Check `pubspec.yaml` dependency drift and run `flutter pub get`.

## 12. Ownership and Handoff

Primary source of project status:

- `PROJECT_STATE.md`
- `MASTER_DELIVERY_PLAN.md`
- `docs/ONBOARDING_RUNBOOK.md` (this file)

Any architectural or release-impacting decision must be logged in:

- `docs/DECISION_LOG.md`
