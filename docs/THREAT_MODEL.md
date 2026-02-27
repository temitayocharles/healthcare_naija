# Threat Model (Initial)

## Key Risks
- Unauthorized data access
- Queue replay abuse
- Credential leakage

## Mitigations
- Firestore rules + auth guards
- Queue operation ownership checks
- Environment-based secrets management
