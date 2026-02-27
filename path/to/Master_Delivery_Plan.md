# Nigeria Healthcare App - End-to-End Master Delivery Plan

## 0. Purpose of This Document

This is the single execution plan for completing the project from current state to production launch.

Audience:
- Primary executor: lower-capability agent (Ollama/Qwen)
- Reviewer: project owner

This document is intentionally explicit and operational. Follow it step-by-step.

---

## 1. Non-Negotiable Rules (Read First)

1. Do not apply model-corrupting edits.
2. Do not convert normal constructors into `factory` constructors unless there is a valid design reason and tests prove correctness.
3. Do not remove Hive `part` directives from model files.
4. Do not delete model fields without an explicit migration plan.
5. Do not rename domain entities unless a full propagation pass is included (models, providers, repositories, UI, tests, adapters).
6. Do not commit generated files blindly; inspect generated output and run analyzer/tests.
7. Every phase must end with verification evidence:
   - `flutter pub get`
   - `flutter analyze`
   - required tests for phase

---

## 2. Current State Snapshot (What Has Already Been Done)

Completed:
- Flutter project root/scaffold restored.
- Repository layer foundation added:
  - `UserRepository`, `ProviderRepository`
- Riverpod wiring updated to use repository boundaries for key flows.
- Offline sync queue service implemented:
  - queue enqueue for user/provider/appointment upserts
  - flush on connectivity restore
  - pending count stream provider
  - manual flush trigger
- Sync status badge wired into app bars.
- Analyzer warnings cleaned; currently analyzer passes.
- `PROJECT_STATE.md` created for architecture context.

Known remaining scope:
- Harden Firebase integration and rule model.
- Complete offline-first conflict strategy.
- Add CI/CD and release automation.
- Add test pyramid (unit/integration/UAT).
- Implement missing feature depth (appointments, records, auth lifecycle).
- Production readiness (security, observability, performance, stores, marketing assets).

---

## 3. Final Product Vision (Launch Definition)

Launch-ready means:
- Reliable patient-facing app (mobile + web baseline)
- Authenticated access with role-aware behavior
- Provider discovery with robust filtering + detail views
- Appointment lifecycle end-to-end
- Health records upload/view/share
- Symptom triage with clear risk disclaimers and escalation
- Offline queue sync with transparent user feedback
- Secure Firebase backend rules and monitoring
- CI/CD pipelines with quality gates
- Deployment environments (dev/staging/prod)
- Launch assets (screenshots, branding, app store readiness, landing page copy)

---

## 4. System Architecture (Target)

### 4.1 Layered Architecture

