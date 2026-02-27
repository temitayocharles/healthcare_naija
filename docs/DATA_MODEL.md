# Data Model

## Core Entities
- User
- HealthcareProvider
- Appointment
- HealthRecord
- SymptomRecord

## Persistence
- Hive (local cache)
- Firestore (remote source of truth)

## Constraints
- Preserve Hive typeIds and field numbers.
- Changes require migration documentation.
