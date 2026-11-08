# Campus Incident Report (`campus_report`)

A Flutter application for reporting, tracking, and resolving campus incidents at ALU, powered by Firebase Authentication, Cloud Firestore, Firebase Storage, and Provider state management.

## Setup Instructions

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate or add Firebase configuration files:**
   Because `lib/firebase_options.dart` and `android/app/google-services.json` are excluded from version control via `.gitignore`, run:
   ```bash
   flutterfire configure
   ```
   to generate `lib/firebase_options.dart` and platform config files for your Firebase project.

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Run unit & widget tests:**
   ```bash
   flutter test
   ```
