# Nigeria Health Care App

## Project Overview

A comprehensive healthcare application for Nigeria with AI-powered symptom diagnosis and nationwide care provider search. This is a 3-tier SaaS application with the following key features:

- AI-powered symptom diagnosis
- Search for physicians, nurses, caregivers, pharmacies nationwide
- Appointment booking
- Telemedicine (video consultations)
- Digital health records
- Offline mode support
- Provider dashboard

## Technology Stack

- **Frontend**: Flutter 3.x (Dart)
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **AI**: Hybrid (Local + External APIs)
- **State Management**: Riverpod
- **Offline Support**: Hive + SharedPreferences

---

## Project Progress

### Phase 1: Core Infrastructure

| Task | Status | Notes |
|------|--------|-------|
| Project Setup | ✅ Complete | Flutter project initialized |
| Dependencies Configuration | 🔄 In Progress | pubspec.yaml configured |
| Directory Structure | 🔄 In Progress | Core, features, models, widgets |
| Theme & Constants | 🔄 In Progress | App theme, colors, constants |
| Data Models | 🔄 In Progress | User, Provider, Appointment, SymptomRecord |

### Phase 2: Authentication

| Task | Status | Notes |
|------|--------|-------|
| Firebase Setup | ⬜ Pending | Auth, Firestore config |
| Phone Auth | ⬜ Pending | Nigerian phone numbers |
| Email Auth | ⬜ Pending | Fallback authentication |
| User Roles | ⬜ Pending | Patient, Physician, Nurse, etc. |
| Profile Management | ⬜ Pending | Profile editing, verification |

### Phase 3: AI Symptom Diagnosis

| Task | Status | Notes |
|------|--------|-------|
| Symptom Input UI | ⬜ Pending | Text input, symptom selection |
| Local AI Engine | ⬜ Pending | On-device symptom matching |
| External AI Integration | ⬜ Pending | OpenAI/Anthropic API |
| Severity Assessment | ⬜ Pending | Emergency, Urgent, Normal |
| Diagnosis History | ⬜ Pending | Save and view past diagnoses |

### Phase 4: Provider Search

| Task | Status | Notes |
|------|--------|-------|
| Provider Listing | ⬜ Pending | List view with filters |
| Map Integration | ⬜ Pending | Google Maps for location |
| Search & Filters | ⬜ Pending | By type, specialty, rating |
| Provider Details | ⬜ Pending | Full profile page |
| Reviews & Ratings | ⬜ Pending | User feedback system |

### Phase 5: Appointments

| Task | Status | Notes |
|------|--------|-------|
| Booking Flow | ⬜ Pending | Schedule appointments |
| Appointment Management | ⬜ Pending | View, cancel, reschedule |
| Notifications | ⬜ Pending | SMS/Email alerts |
| Calendar Integration | ⬜ Pending | Provider availability |

### Phase 6: Telemedicine

| Task | Status | Notes |
|------|--------|-------|
| Video Call UI | ⬜ Pending | Video consultation interface |
| WebRTC Integration | ⬜ Pending | Real-time video/audio |
| Call Controls | ⬜ Pending | Mute, camera, end call |
| Waiting Room | ⬜ Pending | Patient waiting area |

### Phase 7: Health Records

| Task | Status | Notes |
|------|--------|-------|
| Records Storage | ⬜ Pending | Upload medical documents |
| Lab Results | ⬜ Pending | View and share lab results |
| Prescription History | ⬜ Pending | Past prescriptions |
| Sharing | ⬜ Pending | Share with providers |

### Phase 8: Offline Mode

| Task | Status | Notes |
|------|--------|-------|
| Local Caching | ⬜ Pending | Cache providers, appointments |
| Offline Symptom Check | ⬜ Pending | AI works offline |
| Sync Mechanism | ⬜ Pending | Sync when online |
| Connectivity Detection | ⬜ Pending | Network status handling |

### Phase 9: Provider Dashboard

| Task | Status | Notes |
|------|--------|-------|
| Patient List | ⬜ Pending | Manage patients |
| Appointments View | ⬜ Pending | Today's schedule |
| Availability Settings | ⬜ Pending | Set working hours |
| Analytics | ⬜ Pending | Reviews, ratings, earnings |

### Phase 10: Polish & Launch

| Task | Status | Notes |
|------|--------|-------|
| UI/UX Refinement | ⬜ Pending | Final design improvements |
| Performance | ⬜ Pending | Optimize for speed |
| Testing | ⬜ Pending | Unit & integration tests |
| iOS Build | ⬜ Pending | Build for iOS |
| Android Build | ⬜ Pending | Build for Android |
| Web Build | ⬜ Pending | Build for Web |

---

## Current Checkpoint

**Status Date:** 2026-02-27  
**Maturity Stage:** Prototype moving toward MVP-ready

For environment setup, tokens, deployment, and engineer handoff, see `docs/ONBOARDING_RUNBOOK.md`.

### Goal
Ship a stable MVP foundation for Nigeria healthcare workflows:
- identity and auth
- provider discovery
- appointment and health-record data flows
- Firebase-backed sync with offline support

### What Is At Stake
- Incorrect model/schema changes can corrupt persisted Hive data and break app-layer wiring.
- Inconsistent naming (`Provider` vs `HealthcareProvider`) can collide with Riverpod types and create widespread compile errors.
- Dependency drift in `pubspec.yaml` can block `flutter pub get`, `flutter analyze`, and build automation.

### What Has Been Done
- Flutter project root and platform scaffolding were restored.
- Core dependencies for Firebase, Riverpod, Hive, and code generation were re-added.
- Type wiring was stabilized for key models/services (`HealthcareProvider`, auth/firestore/messaging integration points).
- CI-local quality gate was re-run and reached a clean `flutter analyze` state before later dependency drift.
- Branch divergence/conflicts with `origin/main` were resolved and pushed.

### Current Risks / Gaps
- `dev_dependencies` currently include `analyzer: ^10.2.0`, which conflicts with Flutter SDK-pinned `flutter_test`/`meta` and blocks dependency resolution.
- Some model and architecture areas still need explicit verification against product requirements (not only compile status).
- Feature modules are scaffolded but still require end-to-end wiring and tests.

### Immediate Next Steps
1. Fix dependency resolution by removing/pinning incompatible `analyzer` in `pubspec.yaml`.
2. Run `flutter pub get`, `flutter analyze`, and `dart run build_runner build --delete-conflicting-outputs`.
3. Verify model constructors/JSON/Hive adapters are consistent (`Provider` constructor naming, generated parts, adapter registration).
4. Validate provider-layer wiring in `lib/core/providers/providers.dart` and service injection boundaries.
5. Add smoke tests for auth, provider fetch, and appointment creation flow.
6. Document environment setup (Firebase config, required `.env`/keys) in onboarding notes.
7. Define MVP acceptance criteria and freeze schema-changing model edits until tests are in place.

---

## Architecture

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration
├── core/
│   ├── constants/            # App constants
│   ├── theme/                # Theme configuration
│   ├── utils/                # Utility functions
│   └── services/             # Core services
├── features/
│   ├── auth/                # Authentication
│   ├── home/                # Home/Dashboard
│   ├── symptom_checker/      # AI Diagnosis
│   ├── provider_search/     # Provider search
│   ├── appointments/         # Booking system
│   ├── profile/             # User profile
│   ├── emergency/            # Emergency services
│   ├── telemedicine/        # Video consultations
│   └── health_records/      # Medical records
├── models/                   # Data models
└── widgets/                  # Reusable widgets
```

---

## Build Commands

```bash
# Install dependencies
flutter pub get

# Run on iOS Simulator
flutter run -d "iPhone 16"

# Build iOS
flutter build ios --simulator

# Build Android
flutter build apk

# Build Web
flutter build web
```

---

## Milestones

### Milestone 1: MVP (Week 1-2)
- Authentication (Phone + Email)
- AI Symptom Checker
- Provider Search
- Basic Booking

### Milestone 2: Enhanced Features (Week 3-4)
- Telemedicine
- Health Records
- Offline Mode

### Milestone 3: Provider Tools (Week 5-6)
- Provider Dashboard
- Analytics
- Reviews System

### Milestone 4: Launch Ready (Week 7-8)
- Polish & Testing
- All platform builds
- Documentation

---

## Contributing

This is an open-source project for Nigeria's healthcare. Contributions are welcome!

---

## License

Open Source - MIT License
