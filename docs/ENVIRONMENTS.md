# Environments

## dev
- Local iteration and emulator usage

## staging
- Pre-production integration and UAT

## prod
- Live user traffic

Each environment must use separate Firebase config and credentials.

## Firebase Project Mapping
- default: `healthcare-naija`
- staging alias: `healthcare-naija-staging`
- production alias: `healthcare-naija`

## GitHub Actions Secrets
Required repository/environment secrets:
- `FIREBASE_TOKEN`
- `FIREBASE_PROJECT_ID_STAGING`
- `FIREBASE_PROJECT_ID_PRODUCTION`

## Deployment Commands
Local staging deploy:
`scripts/deploy_staging.sh`

Local production deploy:
`scripts/deploy_production.sh`

CI deploy workflows:
- `.github/workflows/deploy_staging.yml`
- `.github/workflows/deploy_production.yml`
