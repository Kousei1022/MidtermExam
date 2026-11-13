# Firebase setup for FitTrack

The app uses Firebase Authentication for account sign-in and Cloud Firestore for cloud records. SwiftData remains the on-device cache and supports the existing screen queries.

## Connect your Firebase project

1. Sign in to the Firebase console with your account and create a Firebase project.
2. Add an iOS app with bundle ID `mseuf.edu.ph.MidtermExam`.
3. Download `GoogleService-Info.plist` and place it in the `MidtermExam/` app folder in this Xcode project. The project uses a synchronized folder, so the file is included in the app target automatically.
4. In Firebase Console, open **Authentication > Sign-in method** and enable **Email/Password**.
5. Create a **Cloud Firestore** database. Choose a location appropriate for your users; the location cannot be changed after creation.
6. Publish the contents of `firestore.rules` as the database's Firestore Security Rules.
7. In Xcode, let Swift Package Manager resolve the Firebase packages, then build and run the app.

The `GoogleService-Info.plist` contains app/project identifiers, not a server credential. Do not add a service-account JSON file or Admin SDK credentials to this iOS app.

## Stored data

Each account owns `users/{uid}` with profile fields and subcollections:

- `users/{uid}/workouts/{workoutId}`
- `users/{uid}/meals/{mealId}`
- `users/{uid}/weights/{recordId}`
- `usernames/{lowercaseUsername}` stores the UID for uniqueness checks

Passwords are managed by Firebase Authentication and are never saved in Firestore. Firestore rules restrict profile and record access to the matching authenticated UID.

## Existing local accounts

After Firebase is configured, sign in with an existing on-device account's email and password. If that local account has not yet been linked to Firebase, FitTrack creates its Firebase Auth account and uploads its saved workouts, meals, and weight history. Accounts that only exist on another device must be created or signed into through Firebase.

## Build and package resolution

The Xcode project declares FirebaseCore, FirebaseAuth, and FirebaseFirestore via Swift Package Manager. Resolve packages from Xcode's package prompt or run:

```sh
xcodebuild -resolvePackageDependencies -project MidtermExam.xcodeproj -scheme MidtermExam
```
