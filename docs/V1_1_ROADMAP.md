# v1.1 Roadmap

This roadmap prioritizes product impact, safety, and launch-readiness improvements on top of the current v1 baseline.

Assumptions:
- Team: 1 primary Flutter engineer + part-time backend/devops support
- Sprint length: 2 weeks
- Platform targets: Android, iOS, Web

## 1. Prioritized Backlog With Estimates

| Priority | Feature | Why it matters | Effort | Dependencies | Target Sprint |
|---|---|---|---|---|---|
| P0 | In-app chat (patient/provider) + file attachments | Core continuity of care; highest UX gap | 3-4 weeks | Firestore message schema, Storage rules, push notifications | Sprint 1-2 |
| P0 | Appointment UX upgrade (slots, reminders, reschedule/cancel polish) | Reduces no-shows and user friction | 2-3 weeks | Provider availability model, notification scheduling | Sprint 2 |
| P0 | Emergency flow hardening (state-aware routing, one-tap SOS, location share) | Critical safety and trust requirement | 1-2 weeks | Location permissions, emergency directory data | Sprint 2 |
| P0 | Clinical safety expansion for symptom triage | Reduces legal and patient-safety risk | 1-2 weeks | Existing symptom module, safety guardrails doc | Sprint 2 |
| P1 | Provider trust signals (verification, response time, reviews) | Improves conversion and confidence | 2-3 weeks | Provider metadata, moderation/admin checks | Sprint 3 |
| P1 | Role-based onboarding rewrite | Improves activation and first-session completion | 1-2 weeks | UX copy, starter data, role logic | Sprint 3 |
| P1 | Accessibility + low-data mode | Improves inclusion and real-world usability | 1-2 weeks | UI audit, image optimization strategy | Sprint 3 |
| P1 | Care plan + medication reminders | Improves long-term retention and outcomes | 2-3 weeks | Reminder scheduler, model changes | Sprint 4 |
| P2 | Payments + receipts | Enables provider monetization and billing clarity | 3-4 weeks | Payment provider integration, compliance review | Sprint 4-5 |
| P2 | Admin operations console | Required for scale: verification, moderation, support | 3-4 weeks | Admin auth/roles, audit trail, analytics | Sprint 5 |

## 2. Execution Order

1. Chat and file attachments
2. Appointment flow polish
3. Emergency and clinical safety hardening
4. Provider trust signals + onboarding + accessibility
5. Care plan and medication reminders
6. Payments and admin console

## 3. Feature-Level Definition of Done

Every feature is done only when all checks below pass:

1. UX states complete for loading, empty, error, and offline
2. Repository + sync logic implemented (no direct Firebase in UI)
3. Firestore/Storage rules updated and tested
4. Unit and widget tests added for core behaviors
5. Integration test added for the happy path and one failure path
6. Analytics events added for adoption and reliability metrics
7. Onboarding runbook and README updated where relevant

## 4. Sprint Breakdown

## Sprint 1

- Chat domain model + repository contracts
- Firestore message collections + rules
- Basic chat list/thread UI
- Attachment upload guardrails and storage paths
- Notification events for new messages

Exit criteria:
- Patient/provider can exchange text messages reliably
- Attachments upload and render with role-appropriate access control

## Sprint 2

- Appointment slots and provider availability constraints
- Reminder scheduling and cancellation updates
- Emergency flow improvements and location share
- Symptom triage safety hardening and escalation consistency

Exit criteria:
- Appointment lifecycle and emergency flows validated in integration tests
- Triage shows consistent disclaimers and escalation CTAs

## Sprint 3

- Provider trust metadata and review UI
- New role-aware onboarding journey
- Accessibility pass: text scale, contrast, screen reader labels
- Low-data mode toggle and image loading optimization

Exit criteria:
- New user activation improves in analytics
- Accessibility and low-data acceptance checklist passed

## Sprint 4

- Care plan and medication reminders
- Treatment follow-up tasks
- Payment architecture and provider billing MVP

Exit criteria:
- Patients can track meds/care tasks and receive reminders
- Payment flow passes staging smoke tests

## Sprint 5

- Admin console for provider verification and moderation
- Support tooling and audit trail
- Final hardening for release metrics and observability

Exit criteria:
- Operations team can manage providers/incidents without DB console access
- Production release checklist passes

## 5. Metrics and Success Thresholds

Track weekly:

- Onboarding completion rate
- Appointment completion rate
- Message delivery success rate
- Offline sync success rate
- Crash-free sessions
- Median screen load time

Minimum v1.1 shipment bar:

- Crash-free sessions >= 99.5%
- Offline sync success >= 99%
- No open P0 security/rules defects
- No open P0/P1 regressions in core journeys

## 6. Risks and Mitigations

1. Chat abuse/spam risk
- Mitigation: rate limiting, abuse report flow, moderation queue

2. Attachment security risk
- Mitigation: strict mime/size checks, owner-scoped paths, virus scan extension point

3. Reminder reliability risk
- Mitigation: idempotent schedule writes, retry policy, background execution validation

4. Clinical liability risk
- Mitigation: triage disclaimers, emergency escalations, no deterministic diagnosis wording

5. Scope creep risk
- Mitigation: lock sprint scope to acceptance criteria and defer non-P0/P1 changes

## 7. Immediate Task Pack (Next 10 Tasks)

1. Add chat message and thread models with repositories
2. Add Firestore rules for message collections and role-based access
3. Add chat list and chat thread screens with Riverpod providers
4. Add secure attachment pipeline for chat files
5. Add push notification handling for chat events
6. Add appointment slot model and availability query path
7. Add reminder scheduling service and cancellation updates
8. Add emergency one-tap actions with state-aware contact rendering
9. Add symptom triage compliance checklist into test plan
10. Add integration tests for chat, appointments, and emergency journeys

## 8. Shipping Decision Rule

Ship v1.1 only when:

1. All P0 roadmap items are complete
2. All mandatory tests and security checks pass in CI
3. Staging UAT is signed off with no open severe defects
4. Production rollout checklist is approved in `docs/RELEASE_SIGNOFF.md`
