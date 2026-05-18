# Health Tracker

A production-oriented Flutter health tracking app foundation with Provider-style state management, persistent local storage, responsive Material 3 UI, form validation, loading/error states, and Firebase-ready integration boundaries.

## Implemented app areas

- Firebase Authentication for login, signup, forgot password, and Google sign-in through `AuthRepository`.
- User profile management with persisted name, email, gender, body metrics, goal, calorie target, protein target, and BMI.
- Local offline persistence using `SharedPreferences` with JSON model serialization.
- Clean structure across `core`, `data`, `domain`, reusable `ui/widgets`, and feature screens.
- Dashboard with daily calories, protein, water, BMI, meal CRUD, search, and meal-type filtering.
- Water tracking, workout tracking, weight/BMI trend chart, reminders settings, dark mode, responsive grid layout, loading indicators, validation, and animated navigation.
- Firestore cloud sync for meals, water entries, workouts, and weight, with local offline fallback.
- API and notification service boundaries ready for real backends.
- Secure Firestore rules in `firebase/firestore.rules`, wired in `firebase.json`.
- App icon and splash assets already wired through platform folders and `assets/logo.png`.

## Firebase setup

Firebase has been configured with FlutterFire and initialized from `lib/firebase_options.dart`.

Next Firebase tasks:

1. Enable Email/Password and Google providers in Firebase Console > Authentication > Sign-in method.
2. Add Android SHA-1 and SHA-256 fingerprints in Firebase Console for Google sign-in.
3. Deploy rules after edits with `firebase deploy --only firestore:rules`.

## Quality checks

Run:

```sh
flutter analyze
flutter test
```

## Store readiness notes

Before Play Store or App Store submission, add production Firebase credentials, notification permissions, privacy policy links, release signing, crash reporting, analytics consent, and real app icon/splash generation for each platform.
