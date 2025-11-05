# Ideogram Studio (Flutter)

A secure, polished Flutter application for generating custom imagery via the Ideogram AI API. The app emphasizes secure credential storage, robust error handling, and a user-friendly workflow for personal creative projects.

## ✨ Features

### Security & API Management
- 🔐 **Encrypted API key storage** using `flutter_secure_storage`
  - Platform-native keychain (iOS/macOS)
  - Encrypted shared preferences (Android)
- 🔑 **Flexible key management**: Manual entry or JSON import
- 🛡️ **Secure communication**: HTTPS-only API calls with Bearer token authentication

### Image Generation
- ✨ **AI-powered image generation** via Ideogram API v2
- 🎨 **6 predefined visual styles**: Cinematic, Watercolor, 3D Render, Line Art, Concept Art, Photorealistic
- 📐 **Adjustable aspect ratios**: 1:1, 16:9, 3:4, 9:16, and custom ratios
- 🔄 **Automatic retry logic** with exponential backoff for network failures
- ⏱️ **Configurable timeouts** (60s default) for API requests

### User Experience
- 📱 **Material 3 interface** optimized for Android
- 🌓 **Dark mode support** with system theme detection
- 🖼️ **Persistent image gallery** - images accumulate across generations
- 👆 **Interactive image viewer** - tap to view full size
- 📋 **Copy prompts** to clipboard for reuse
- 🔗 **Share image URLs** directly from the app
- 🗑️ **Clear all images** with confirmation dialog

### Code Quality
- ✅ **Comprehensive error handling** with specific error types
- 📝 **Extensive documentation** with dartdoc comments
- 🧪 **Strict lint rules** for code quality
- 🏗️ **Clean architecture** with separation of concerns
- 📊 **State management** using Provider pattern

## 🚀 Getting Started

### Prerequisites
- Flutter 3.16 or newer
- Dart SDK 3.2.0 or newer
- An Ideogram API key ([Get one here](https://ideogram.ai))

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fluffy-tribble
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment** (already created)
   The `.env` file is already configured with:
   ```env
   IDEOGRAM_BASE_URL=https://api.ideogram.ai/generate
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Key Setup

### First Launch
1. Tap the **key icon** (🔑) in the top AppBar
2. Enter your Ideogram API key manually
3. Click **Save** to securely store it

### Alternative: JSON Import
1. Tap the key icon, then **Import from JSON**
2. Paste your JSON in this format:
   ```json
   { "ideogramApiKey": "your-api-key-here" }
   ```
3. Click **Import**

### Managing Your Key
- **View**: Tap the key icon (shows obscured)
- **Update**: Enter a new key and save
- **Delete**: Tap the key icon, then **Delete** (also clears images)

## 🎨 Using the App

1. **Enter a prompt**: Describe what you want to generate
2. **Select a style**: Choose from 6 visual styles
3. **Set aspect ratio**: Use 1.0 for square, 1.78 for 16:9, etc.
4. **Generate**: Tap the generate button and wait for results
5. **View images**: Tap any generated image to view full size
6. **Copy/Share**: In the image viewer, copy the prompt or share the URL
7. **Clear all**: Tap the sweep icon (🗑️) to clear the gallery

## 📦 Building an APK

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

For more details, see [Flutter's Android deployment documentation](https://docs.flutter.dev/deployment/android).

## 🔒 Security Considerations

- ✅ **No plaintext storage**: API keys are encrypted using platform keychains
- ✅ **HTTPS-only**: All network requests use secure HTTPS
- ✅ **Bearer token auth**: Proper authentication headers
- ✅ **No sensitive logging**: Errors don't leak API keys or sensitive data
- ✅ **External links**: Documentation opens externally (no embedded WebViews)
- ✅ **Input validation**: All user inputs are validated before processing
- ✅ **Timeout protection**: Requests timeout after 60 seconds
- ✅ **Retry logic**: Automatic retry with exponential backoff for transient failures

## 🏗️ Architecture

```
lib/
├── main.dart                      # App entry point & theme configuration
├── api/
│   └── ideogram_api_client.dart   # API client with retry logic & error handling
├── screens/
│   └── home_screen.dart           # Main UI with image gallery
├── services/
│   └── secure_storage_service.dart # Encrypted key storage
├── state/
│   └── generation_state.dart      # State management (Provider)
└── widgets/
    └── generation_form.dart       # Image generation input form
```

## 🧪 Error Handling

The app provides specific error messages for:
- **Authentication errors** (401/403): Invalid or expired API key
- **Rate limiting** (429): Too many requests
- **Network errors**: Connection failures with automatic retry
- **Timeout errors**: Requests taking too long (60s+)
- **Server errors** (5xx): API server issues
- **Validation errors**: Invalid prompts or parameters

## 🌟 What's New

This refined version includes:
- ✨ **Image history accumulation** (no longer replaced on each generation)
- 🔄 **Automatic retry** with exponential backoff
- 🌓 **Dark mode support**
- 👆 **Interactive image viewer** with copy/share
- 🗑️ **Clear all images** functionality
- ⏱️ **Timeout configuration** (60s)
- 📝 **Comprehensive documentation** (dartdoc)
- 🧪 **Strict lint rules** for code quality
- 🎯 **Better error messages** with specific error types
- 🔐 **Enhanced security** practices

## 📝 Development

### Code Quality
Run the analyzer to check for issues:
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

### Testing
Add tests under the `test/` directory:
```bash
flutter test
```

## 📄 License

This project is intended for private use. Adapt as needed for your personal workflows.

## 🤝 Contributing

This is a personal project, but feel free to fork and customize for your needs!
