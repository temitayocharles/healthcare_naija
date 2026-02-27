#!/usr/bin/env bash
set -euo pipefail

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase CLI not found. Install with: npm i -g firebase-tools"
  exit 1
fi

PROJECT_ID="${FIREBASE_PROJECT_ID_STAGING:-nigeria-health-care-staging}"

flutter pub get
flutter analyze
flutter test
flutter build web --release

firebase deploy \
  --project "${PROJECT_ID}" \
  --only "hosting,firestore:rules,firestore:indexes,storage" \
  --non-interactive

echo "Staging deploy complete for ${PROJECT_ID}."
