# Ideogram Studio (Flutter)

A secure Flutter application for generating custom imagery via the Ideogram API. The app emphasises secure credential storage, clean architecture, and a user-friendly workflow for personal creative projects.

## Features

- 🔐 Encrypted API key storage using `flutter_secure_storage`
- ✨ Prompt-driven image generation via the Ideogram API
- 🎨 Predefined visual styles and adjustable aspect ratios
- 📱 Material 3 interface optimised for Android APK builds
- 🛡️ Input validation, error handling, and key management utilities

## Getting Started

1. Ensure you have Flutter 3.16 or newer installed and configured.
2. Clone the repository and install dependencies:
   ```bash
   flutter pub get
   ```
3. (Optional) Create a `.env` file in the project root to override defaults. By default the app falls back to `.env.example`:
   ```env
   IDEOGRAM_BASE_URL=https://api.ideogram.ai/v1/images
   IDEOGRAM_TIMEOUT_SECONDS=30
   ```
   `IDEOGRAM_BASE_URL` must use HTTPS. Any invalid or insecure value automatically falls back to the default endpoint. Adjust `IDEOGRAM_TIMEOUT_SECONDS` to configure how long the client waits for Ideogram responses.
4. Run the app:
   ```bash
   flutter run
   ```

## Providing the API Key

- On first launch, tap the key icon in the AppBar to securely store your Ideogram API key.
- Keys are written to the platform keychain (encrypted shared preferences on Android).
- Optionally import from a JSON snippet using `{ "ideogramApiKey": "YOUR_KEY" }`.

## Building an APK

Follow Flutter's official guidance to produce a release APK:

```bash
flutter build apk --release
```

Then sign and distribute the APK according to [Flutter's Android deployment documentation](https://docs.flutter.dev/deployment/android).

## Security Considerations

- API keys are never stored in plaintext files or bundled in source control.
- Network requests enforce HTTPS and authenticated headers.
- Errors are surfaced to the UI without leaking sensitive details.
- External documentation links open outside the app to avoid embedded web views.

## Testing

Add widget and integration tests under the `test/` directory. Example command:

```bash
flutter test
```

## License

This project is intended for private use. Adapt as needed for your personal workflows.
