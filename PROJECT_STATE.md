# Nigeria Healthcare App – Project State

## 1. Vision

Build a scalable digital healthcare platform for Nigeria that enables:

- Patient registration & authentication
- Healthcare provider discovery
- Appointment scheduling
- Health record management
- Symptom tracking
- AI-assisted triage (future)
- Firebase-backed cloud sync
- Offline-first support via Hive

Target: MVP -> Production-grade mobile/web healthcare platform.

---

## 2. Current Architecture

### Stack
- Flutter
- Riverpod (state management)
- Hive (local persistence)
- Firebase:
  - Auth
  - Firestore
  - Storage
  - Messaging

---

### Domain Layer (Models)

- User
- HealthcareProvider
- Appointment
- HealthRecord
- SymptomRecord

All models:
- Support JSON serialization
- Support copyWith
- Hive annotated for offline storage

---

### Persistence Strategy

Local:
- Hive for offline caching

Cloud:
- Firestore as primary source of truth

Strategy:
- Sync-first architecture (Firestore primary, Hive cache)

---

## 3. What Is Working

- Project compiles clean
- Hive adapters generate successfully
- Firebase dependencies resolve
- App runs on Chrome
- Domain models structurally consistent

---

## 4. What Is NOT Yet Production-Ready

- No documented data sync strategy
- No repository abstraction layer
- No CI/CD
- No environment separation (dev/staging/prod)
- No secure secret management strategy
- No encryption-at-rest for Hive
- No role-based access enforcement layer
- No API boundary for AI triage

---

## 5. Project Maturity Level

Current Stage: Early MVP Foundation

Not:
- Prototype
Not:
- Production-ready

---

## 6. Architectural Risks

- Direct Firebase calls inside UI (if present)
- No repository pattern abstraction
- Potential duplication between Hive and Firestore models
- No error boundary standardization

---

## 7. Immediate Next 7 Milestones

1. Implement Repository Layer (abstraction over Hive + Firestore)
2. Define Data Sync Strategy (online/offline)
3. Add Role-Based Access Guards
4. Implement Structured Logging
5. Introduce Feature Modules (appointments, providers, records)
6. Add CI Pipeline (analyze + test + build)
7. Prepare Environment Configuration Strategy

---

## 8. Long-Term Roadmap

- AI symptom triage microservice
- Notification strategy
- Payment integration
- HIPAA-style compliance adaptation
- Encryption + token hardening
