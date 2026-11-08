# Campus Incident Report (`campus_report`)

A Flutter mobile application built with Firebase (Authentication, Cloud Firestore, and Firebase Storage) and `Provider` state management for reporting, tracking, and resolving campus incidents at ALU.

## Repository Structure

- [`campus_report/`](./campus_report) — Main Flutter application source code, assets, platform configurations, and widget/unit tests.
  - `lib/models/` — Data models (`UserModel`, `IncidentModel`) with Firestore serialization and role/privacy helpers.
  - `lib/providers/` — `ChangeNotifier` state providers (`AuthProvider`, `IncidentProvider`).
  - `lib/services/` — Firebase service layers (`AuthService`, `IncidentService`, `StorageService`).
  - `lib/screens/` — Authentication (`LoginScreen`, `RegisterScreen`, `VerifyEmailScreen`), Student screens (`HomeScreen`, `ReportIncidentScreen`, `ReportsListScreen`, `MyReportsScreen`, `IncidentDetailScreen`), and Staff screens (`StaffDashboardScreen`).
  - `lib/widgets/` — Reusable UI components (`IncidentCard`, `StatusBadge`, `StatusTimeline`).
  - `test/widget_test.dart` — Unit and widget tests for ALU email validation, RBAC/anonymity models, and UI widgets.

## Key Features

- **ALU Domain Authentication & Email Verification:** Restricts registration/login to `@alustudent.com` and `@alueducation.com` email addresses with Firebase Email Verification enforcement.
- **Role-Based Access Control (Student & Staff):** Students can submit and track campus incidents; authorized staff can manage statuses (`Submitted` -> `In Progress` -> `Resolved`) and attach resolution notes.
- **Anonymous Reporting:** Supports privacy-safe incident reporting (`Anonymous Student` masking).
- **Real-Time Status Timeline & Photo Evidence:** Live Firestore streams and photo uploads via Firebase Storage.

## Getting Started & Firebase Setup

> **Note:** For security best practices, Firebase configuration files (`lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist`) are excluded via `.gitignore`.

1. **Navigate to the Flutter project directory:**
   ```bash
   cd campus_report
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Generate your local Firebase configuration files using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```
   *(Alternatively, place your `google-services.json` in `campus_report/android/app/` and `firebase_options.dart` in `campus_report/lib/`).*

4. **Run the application:**
   ```bash
   flutter run
   ```

5. **Run tests:**
   ```bash
   flutter test
   ```
