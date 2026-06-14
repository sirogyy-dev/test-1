# Deployment Checklist for ProTodo

## 1. Verify Flutter app structure

The current app folder contains:

- `lib/`
- `pubspec.yaml`
- `test/`
- `integration_test/`
- `README.md`
- `TESTING_GUIDE.md`
- `COVERAGE_REPORT.md`

> Note: `android/` and `ios/` platform directories are currently missing in this repository. To prepare for Android release, add them with `flutter create .` in the app folder or restore the platform folders from the Flutter app template.

## 2. Required before release

- Install Flutter SDK.
- Run `flutter pub get` inside `apps/todo_app`.
- Confirm `flutter doctor` reports no missing dependencies.
- Ensure `pubspec.yaml` includes all runtime dependencies.
- Add `android/` and `ios/` directories if missing.
- Confirm `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` exist.

## 3. App icon and splash screen

### App icons
- Use the Flutter `flutter_launcher_icons` package or generate icons manually.
- Replace the app launcher icon files in `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

### Splash screen
- For Android, update `android/app/src/main/res/drawable/launch_background.xml` and `android/app/src/main/res/values/styles.xml`.
- For iOS, update `ios/Runner/Assets.xcassets/LaunchImage.launchimage` and `ios/Runner/Info.plist`.
- Keep the splash style simple and brand-consistent.

## 4. Android release build commands

From `apps/todo_app`:

```bash
flutter pub get
flutter build appbundle --release
```

Or for APK only:

```bash
flutter build apk --release
```

If you need ABI-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

## 5. Android signing

- Create a signing key:

```bash
keytool -genkey -v -keystore ~/protodo-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias protodo-key
```

- Add `key.properties` to `apps/todo_app/android/`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=protodo-key
storeFile=../protodo-release-key.jks
```

- Configure `android/app/build.gradle` to use the signing config.

## 6. Play Store preparation

- Create a Google Play Console account.
- Set up app listing:
  - App name
  - Short description
  - Full description
  - App category
  - Privacy policy URL
  - Contact email
- Prepare assets:
  - Feature graphic
  - Screenshots for phone/tablet
  - App icon (512x512)
- Verify content rating and target audience.
- Upload the generated `app-release.aab`.
- Complete release notes and roll out to production or internal testing.

## 7. Final project structure

```text
apps/todo_app/
  COVERAGE_REPORT.md
  DEPLOYMENT_CHECKLIST.md
  README.md
  TESTING_GUIDE.md
  android/  <-- required for Android release
  ios/      <-- required for iOS release
  integration_test/
    app_test.dart
  lib/
    main.dart
    src/
      app.dart
      firebase/firebase_initializer.dart
      features/
        auth/
        categories/
        notifications/
        theme/
        todo/
  pubspec.yaml
  test/
    unit/
      todo_item_test.dart
    widget/
      home_page_test.dart
```

## 8. Recommended release flow

1. `cd apps/todo_app`
2. `flutter pub get`
3. `flutter test`
4. `flutter build appbundle --release`
5. Upload to Google Play Console

## 9. Notes

- If this repo is missing `android/` or `ios/`, the first step is to generate platform folders using Flutter tooling.
- For Play Store, prefer `appbundle` over APK for modern distribution.
- Keep versioning updated in `pubspec.yaml` and `android/app/build.gradle`.
