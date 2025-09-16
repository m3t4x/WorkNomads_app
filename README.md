# WorkNomads App

This is a Flutter app featuring authentication, a media gallery (images and audio), theme control, and on-device API configuration.

## Features

- Auth: Login, Signup, and token refresh (JWT). Tokens persisted and auto-refreshed.
- Media: List, upload and delete images/audio, play audio, full-screen image viewer with blur/zoom.
- Theming: Light/Dark theme.
- Config: 3‑finger tap anywhere (Login/Signup/Home) to set the Auth API URL and the Media API URL (persisted).

## Requirements

- Flutter 3.22+ (or a recent stable)
- Dart 3+
- Android Studio or Xcode (for mobile builds)

## Getting Started

1. Install Flutter and ensure `flutter doctor` shows green.
2. Fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Run on your target platform:

   - Android emulator/device:
     ```bash
     flutter run -d android
     ```
   - iOS simulator/device:
     ```bash
     flutter run -d ios
     ```

## Runtime Configuration (3‑finger tap)

You can set/change the base URLs at runtime from within the app:

- Perform a 3‑finger tap anywhere on the screen (Login, Signup, or Home).
- Enter:
  - Auth API URL (e.g., `http://192.168.1.12:8001`)
  - Media API URL (e.g., `http://192.168.1.12:8002`)
- Saved values persist and apply instantly.

## Building a Release APK

1. Build the APK:

   ```bash
   flutter build apk --release
   ```

2. Output:

   - The unsigned APK is generated at:
     - `build/app/outputs/flutter-apk/app-release.apk`


### Release Notes Template

```
## Under the hood
- Auth (login, signup, auto-refresh tokens)
- Media gallery (images & audio), uploads, and per-item delete
- Full-screen image viewer (blur + zoom)
- Audio player (mobile/desktop downloads then plays locally; web uses direct URL)
- 3-finger tap to configure Auth/Media API URLs
- Theme toggle (light/dark)

## Requirements
- Android 7.0+ recommended

```

## Troubleshooting

- Network/timeout errors:
  - The app shows: “Network error or unreachable API. Triple-tap to set API URLs.”
  - Verify the Auth/Media URLs via the 3‑finger tap dialog.

- iOS App Transport Security (ATS):
  - For non-HTTPS local endpoints, add ATS exceptions in `Info.plist` (development only).

## Project Structure (highlights)

- `lib/core/services/api_controller.dart` — Auth, tokens, interceptor-based refresh, base URL persistence.
- `lib/core/services/media_service.dart` — Media list/upload/delete, media base URL persistence.
- `lib/features/auth/` — Login/Signup screens + runtime config dialog.
- `lib/features/home/home_screen.dart` — Gallery UI, filters, upload, audio player, full-screen image viewer, delete, theme toggle.
- `lib/features/splash/splash_screen.dart` — Splash logic.
- `lib/core/widgets/three_finger_tap_detector.dart` — 3‑finger tap gesture detector.

## License

This project is for internal testing and evaluation.
