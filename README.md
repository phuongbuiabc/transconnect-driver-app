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

See [ARCHITECTURE.md](ARCHITECTURE.md) for the current feature structure and coding rules, and [AGENTS.md](AGENTS.md) for contributor instructions.

- `app`: bootstrap, navigation and controller composition.
- `core`: transport, typed decoding, session lifecycle and secure storage.
- `features`: typed models, repositories, controllers and presentation.
- `shared`: theme, reusable widgets and validation.
- `scripts/Check.ps1`: format check, analyze and tests; optional `-NoRestore`.

Local API defaults: Android native/emulator `http://10.0.2.2:5267`; web/desktop/iOS simulator `http://localhost:5267`. Override with `--dart-define=API_BASE_URL=...` for a real device or deployment. Both apps use the same backend; their account groups and storage keys remain separate.

## Validation


Foundation verification (18/10/2026): static analysis and 14 tests passed. Tests ran with a writable local copy of the installed Flutter SDK because the agent cannot write the system SDK cache. No native build or live BE/email E2E was performed in this refactor.

Run all checks: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Check.ps1`.
