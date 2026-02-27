# Clinical Safety Guardrails

This application provides **symptom triage guidance**, not diagnosis.

## What Is Implemented

1. Triage-only framing in product language
- UI now labels output as triage guidance and potential causes (non-diagnostic).

2. Mandatory safety acknowledgement
- Users must explicitly confirm understanding before running symptom triage.

3. Emergency red-flag escalation
- Known red-flag symptoms force emergency urgency and immediate escalation guidance.

4. Output bounding and normalization
- Symptoms are normalized and bounded to a max list length.
- Severity values constrained to `emergency|urgent|normal`.

5. Safety metadata in results
- Every response includes a safety disclaimer and emergency contacts payload.

6. Persistence path
- Symptom records are saved through the symptom repository for auditability and continuity.

## Remaining Due-Diligence Work (Required Before Broad Public Launch)

1. Clinical governance board
- Establish medical oversight for symptom ontology, severity mappings, and review cadence.

2. Regulatory assessment
- Perform country-specific legal/regulatory review for triage decision support positioning.

3. Human-in-the-loop escalation
- Add explicit handoff path to licensed clinician (telemedicine or callback) for urgent cases.

4. Safety QA protocol
- Run adversarial safety tests (false reassurance, dangerous ambiguity, red-flag misses).

5. Incident monitoring
- Add safety event telemetry (red-flag rate, escalation taps, adverse feedback) with alerting.

6. Policy and consent records
- Maintain versioned consent text and legal policy acceptance evidence.

## Non-Claims

- The app does not provide definitive diagnosis.
- The app is not a substitute for emergency care or licensed professional judgment.
