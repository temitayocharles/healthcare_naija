#!/usr/bin/env bash
set -euo pipefail

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase CLI not found. Install with: npm i -g firebase-tools"
  exit 1
fi

PROJECT_ID="${FIREBASE_PROJECT_ID_PRODUCTION:-healthcare-naija}"
FIREBASE_TOKEN_ARG=()

if [ -n "${FIREBASE_TOKEN:-}" ]; then
  FIREBASE_TOKEN_ARG=(--token "${FIREBASE_TOKEN}")
else
  LOGIN_STATUS="$(firebase login:list 2>&1 || true)"
  if echo "${LOGIN_STATUS}" | grep -qi "No authorized accounts"; then
    echo "Firebase auth not found. Run 'firebase login' or set FIREBASE_TOKEN."
    exit 1
  fi
fi

flutter clean
flutter pub get
flutter analyze
flutter test
flutter build web --release

firebase deploy \
  --project "${PROJECT_ID}" \
  --only "hosting,firestore:rules,firestore:indexes,storage" \
  "${FIREBASE_TOKEN_ARG[@]}" \
  --non-interactive

echo "Production deploy complete for ${PROJECT_ID}."
