# TransConnect Driver

Independent Flutter repository for driver onboarding and organization collaboration. Android, iOS, and web preview scaffolds are included. No Git repository or remote is initialized.

## Implemented

- Operator login/registration, email verification/resend, password recovery/reset.
- Secure stored session, rotating refresh serialization, session restoration and logout revocation.
- Verified-email driver full-name submission and live Pending/Approved/Rejected review status, with reviewer note.
- Approved-driver invitation token acceptance and server receipt.
- Vietnamese Material 3 UI using VIEGO crimson/gold and grouped light surfaces.

Backend source is authoritative: only fullName is accepted for driver submission. Rejected profiles have no resubmit API. Trips, maps, earnings, document uploads, and a self-service engagement list are not implemented by the backend. The acceptance receipt is in-memory for the current session and is not a persisted engagement directory.

## Run

Flutter 3.35.2 / Dart 3.9 or a compatible newer SDK is required.

    flutter pub get
    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5267

Confirm the API port in TransConnect-Backend/TransConnect.Host/Properties/launchSettings.json and adjust the URL. Android emulator uses 10.0.2.2 for the host computer. iOS Simulator and web may use localhost. A physical phone needs a reachable LAN host, firewall access, and a backend bound to that interface.

    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5267
    flutter analyze
    flutter test
    flutter build web --dart-define=API_BASE_URL=https://your-api.example

Web preview requires backend CORS permitting its origin. Secure storage on web requires HTTPS or localhost and the browser security model applies. Production must use HTTPS. Android development HTTP is enabled only in debug/profile manifests; iOS development HTTP requires a local debug ATS configuration or trusted HTTPS endpoint. Do not enable global insecure transport for release builds. Android uses platform encrypted storage; iOS uses Keychain. No token is logged.

## Layout

- lib/main.dart: entry point; app/: bootstrap, theme, navigation and session coordination.
- lib/core/: configuration, HTTP, secure storage, errors and brand tokens.
- lib/features/: auth, account, driver profile and invitation screens/data.
- lib/shared/: reusable presentation widgets and field validation.
- test/: mocked HTTP session lifecycle and phone-size UI checks.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the complete directory map, screen locations, dependency rules and how to add features.

For iOS native builds, use macOS with Xcode and configure signing. For Android native builds, install Android SDK/Java and configure signing before distributing. App identifiers are starter com.transconnect values; replace with owned production IDs. The generated launcher artwork is a placeholder.

## Validation

See .reports/transconnect-frontend/plans/driver-app/00-index.md in the parent workspace for analysis and final validation results. Live backend and email delivery are needed to verify the complete registration-to-approval-to-invitation flow; mocked tests do not replace that verification.

Validated locally: Flutter analyze passed with no issues; all5 tests passed; standard JavaScript web production build succeeded. Web Wasm is not supported by the current secure-storage web dependency. Native Android/iOS builds and live backend/email E2E are not yet verified.
