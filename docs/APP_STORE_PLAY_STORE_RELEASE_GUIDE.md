# App Store and Play Store Release Guide

This runbook explains exactly how to publish this app for end users.

Current app identifiers in this repo:
- App display name: `CareRoviq`
- Android package name: `hcn.temitayocharles.online`
- iOS bundle ID: `hcn.temitayocharles.online`
- Flutter app version source: `pubspec.yaml` (`version: x.y.z+buildNumber`)

## 1. Pre-Release Checklist (Required)

1. `flutter analyze` passes
2. `flutter test` passes
3. Firebase config files are present:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Store metadata and screenshots are ready
5. Privacy policy URL and support URL are ready
6. Release notes are prepared

## 2. Versioning Rules

Update version in `pubspec.yaml` before each release:

```yaml
version: 1.0.1+2
```

- `1.0.1` = marketing version shown to users
- `2` = build number/code (must always increase)

Then run:

```bash
flutter pub get
```

## 3. Android (Google Play Console)

## 3.1 One-time setup

1. Create app in Play Console.
2. Complete app content forms (privacy, data safety, target audience, etc.).
3. Set up signing:
   - Recommended: Play App Signing enabled.
4. Ensure Firebase Android app exists for package `hcn.temitayocharles.online`.

## 3.2 Build AAB

From repo root:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output:
- `build/app/outputs/bundle/release/app-release.aab`

Optional preflight:

```bash
flutter analyze
flutter test
```

## 3.3 Upload and release

1. Play Console -> Your app -> `Test and release` -> `Production` (or Internal first).
2. Create new release.
3. Upload `app-release.aab`.
4. Add release notes.
5. Review warnings.
6. Roll out.

Recommended release path:
1. Internal testing
2. Closed testing
3. Production

## 4. iOS (Apple App Store Connect)

## 4.1 One-time setup

1. Apple Developer account active.
2. App ID and bundle ID exist: `hcn.temitayocharles.online`.
3. App record created in App Store Connect.
4. Certificates/profiles configured in Xcode Signing.
5. `ios/Runner/GoogleService-Info.plist` is added.

## 4.2 Build iOS archive

Option A (Xcode recommended for first releases):

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select target `Runner`.
3. Confirm Signing & Capabilities.
4. Set build/version to match `pubspec.yaml`.
5. Product -> Archive.
6. In Organizer -> Distribute App -> App Store Connect -> Upload.

Option B (CLI):

```bash
flutter clean
flutter pub get
flutter build ipa --release
```

Then upload IPA via Transporter or Xcode Organizer.

## 4.3 Submit for review

1. App Store Connect -> My Apps -> select app.
2. Create new version.
3. Attach uploaded build.
4. Fill App Privacy and required compliance forms.
5. Add screenshots, description, keywords, support/privacy URLs.
6. Submit for review.

## 5. Required Store Assets

Minimum recommended:
- App icon (all required sizes)
- Screenshots:
  - Android phone
  - iPhone 6.7" + 6.1"
  - Optional tablet sizes
- Feature graphic (Play Store)
- Short and full descriptions
- Privacy policy URL
- Support URL/email

## 6. Common Errors and Fixes

1. "Version code already used" (Android)
- Increase build number (`+N`) in `pubspec.yaml`.

2. "Invalid bundle" (iOS)
- Ensure Xcode signing/team/profile are correct.
- Ensure bundle ID exactly matches App Store Connect app.

3. Firebase runtime failures
- Check platform config files exist in correct paths.
- Confirm Firebase app IDs/package IDs match platform project IDs.

4. Rejected for privacy declarations
- Align app behavior with declared data usage in Play/App Store forms.

## 7. Recommended Release Workflow (Each Release)

1. Create release branch `release/x.y.z`
2. Update `pubspec.yaml` version
3. Run quality gates:

```bash
flutter analyze
flutter test
```

4. Build Android AAB and iOS archive
5. Upload to internal testing tracks (Android + TestFlight)
6. Validate smoke test on real devices
7. Promote to production with phased rollout

## 8. Phased Rollout Recommendation

- Day 1: 5%
- Day 2: 20%
- Day 3: 50%
- Day 4: 100% (if crash and error rates remain healthy)

## 9. Post-Release Monitoring

Track first 72h:
- Crash-free sessions
- Authentication failures
- Sync queue failure rate
- Upload errors (chat/records attachments)
- Appointment create/cancel errors

If severe regression appears:
- Halt rollout
- Hotfix branch and expedited patch release

## 10. Required Accounts and Access

Before publishing, ensure:
1. Google Play Console owner or release-manager access
2. Apple Developer + App Store Connect access
3. Firebase project admin/editor access for `healthcare-naija`
4. Legal pages live and reachable:
   - Privacy Policy URL
   - Support URL
