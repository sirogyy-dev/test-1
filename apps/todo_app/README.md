# ProTodo Flutter App

## Phase 1: Project Setup

This Flutter app is a professional starter for a production-ready todo list using:
- Flutter
- Firebase Authentication
- Cloud Firestore
- Riverpod state management
- Material 3 design

## App Folder Structure

- `lib/main.dart` - App entrypoint and Firebase initialization
- `lib/src/app.dart` - Material app setup
- `lib/src/firebase/firebase_initializer.dart` - Firebase startup logic
- `lib/src/core/` - App constants and shared core utilities
- `lib/src/features/auth/` - Authentication domain, data, and controller
- `lib/src/features/todo/` - Todo feature with Clean Architecture layers
  - `domain/` - Entities, repository contracts, use cases
  - `data/` - Firestore datasource and repository implementation
  - `presentation/` - Views, controllers, state, widgets

## pubspec.yaml dependencies

- `flutter_riverpod: ^2.4.0`
- `firebase_core: ^2.17.0`
- `firebase_auth: ^4.7.0`
- `cloud_firestore: ^4.9.0`
- `google_sign_in: ^6.1.0`
- `intl: ^0.18.1`

## Setup Guide

1. Install Flutter and Dart SDKs.
2. In `apps/todo_app`, run `flutter pub get`.
3. Setup Firebase project at `https://console.firebase.google.com`.
4. Add Android and iOS apps in Firebase.
5. Download and place `google-services.json` into `apps/todo_app/android/app/`.
6. Download and place `GoogleService-Info.plist` into `apps/todo_app/ios/Runner/`.
7. In Firebase console, enable Authentication > Sign-in method > Google.
8. In Firestore, create `users/{uid}/todos` documents.
9. Run the app with `flutter run`.

## Notes

- The current code initializes Firebase with `Firebase.initializeApp()`.
- The app uses Google Sign-In for Authentication and stores todos under each user in Firestore.
- The app now includes offline sync with Hive and local notification scheduling.
- `DEPLOYMENT_CHECKLIST.md` explains Android and Play Store release preparation.
- `TESTING_GUIDE.md` and `COVERAGE_REPORT.md` describe testing and coverage workflows.

## Deployment

The repository currently lacks native platform directories for Android and iOS. To prepare for release:

1. Generate the missing platform folders with Flutter:
   ```bash
   cd apps/todo_app
   flutter create .
   ```
2. Add or update app icons and splash screen assets in `android/` and `ios/`.
3. Configure Android signing and build a release bundle:
   ```bash
   flutter build appbundle --release
   ```
4. Upload the generated `.aab` to Google Play Console.
