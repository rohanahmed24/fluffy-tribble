# AI Image Studio (Flutter)

A **cross-platform mega application** for generating custom imagery via **multiple AI image generation APIs**. Built with Flutter, this app runs on **6 platforms**: Android, iOS, Web, Windows, macOS, and Linux. Features secure credential storage, robust error handling, and a beautiful responsive UI for all screen sizes.

## 🌐 Platform Support

| Platform | Status | Architecture | Distribution |
|----------|--------|-------------|--------------|
| 🤖 **Android** | ✅ Ready | ARM64, ARMv7, x86_64 | APK, Google Play |
| 🍎 **iOS** | ✅ Ready | ARM64 | App Store, TestFlight |
| 🌍 **Web** | ✅ Ready | All browsers | PWA, Direct hosting |
| 🪟 **Windows** | ✅ Ready | x64 | Exe, Microsoft Store |
| 🍏 **macOS** | ✅ Ready | ARM64, x64 | DMG, Mac App Store |
| 🐧 **Linux** | ✅ Ready | x64 | AppImage, Snap, Flatpak |

> **📖 Build Guide**: See [BUILD_GUIDE.md](BUILD_GUIDE.md) for detailed platform-specific build instructions.

## ✨ Features

### Multi-API Support 🎯 **NEW!**
- 🔄 **4 AI Providers**: Ideogram, OpenAI DALL-E 3, Stability AI, Replicate (Flux)
- 🔌 **Easy switching**: Change providers with a single tap
- 💾 **Multiple API keys**: Store keys for all providers simultaneously
- 🎨 **Provider-specific features**: Each provider's unique capabilities supported

### Security & API Management
- 🔐 **Encrypted API key storage** using `flutter_secure_storage`
  - Platform-native keychain (iOS/macOS)
  - Encrypted shared preferences (Android)
  - Separate secure storage for each provider
- 🔑 **Flexible key management**: Configure multiple providers at once
- 🛡️ **Secure communication**: HTTPS-only API calls with Bearer token authentication
- 🔄 **Automatic migration**: Legacy API keys automatically migrated

### Image Generation
- ✨ **AI-powered image generation** via multiple providers
- 🎨 **Multiple artistic styles**: Varies by provider (6-9 styles each)
- 📐 **Flexible dimensions**: Aspect ratios and custom sizes (provider-dependent)
- 🔄 **Automatic retry logic** with exponential backoff for network failures
- ⏱️ **Configurable timeouts** (60-90s) for API requests

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
- At least one API key from any supported provider:
  - **Ideogram**: https://ideogram.ai/api
  - **OpenAI DALL-E**: https://platform.openai.com/api-keys
  - **Stability AI**: https://platform.stability.ai/account/keys
  - **Replicate**: https://replicate.com/account/api-tokens

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

### First Launch - Multi-Provider Setup
1. Tap the **key icon** (🔑) in the top AppBar
2. Select your preferred provider from the list:
   - **Ideogram** - High-quality with excellent text rendering
   - **OpenAI DALL-E** - Advanced AI from OpenAI
   - **Stability AI** - Powerful Stable Diffusion
   - **Replicate (Flux)** - Fast and high-quality
3. Expand the provider card and enter your API key
4. (Optional) Configure additional providers for easy switching
5. Click **Save** to securely store your settings

### Switching Providers
1. Tap the key icon
2. Select a different provider (must have API key configured)
3. Click **Save**
4. The app header will show your current provider

### Managing API Keys
- **View**: Tap the key icon (keys shown as dots for security)
- **Update**: Modify any provider's key and save
- **Delete**: Clear the key field for a provider
- **Multiple keys**: Store keys for all providers simultaneously

> 📖 **For detailed setup instructions**, see [API_SETUP.md](./API_SETUP.md)

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
├── main.dart                          # App entry point & theme configuration
├── api/
│   ├── base_image_provider.dart       # Abstract base for all providers
│   ├── provider_factory.dart          # Factory for creating providers
│   ├── ideogram_api_client.dart       # Legacy Ideogram client
│   └── providers/
│       ├── ideogram_provider.dart     # Ideogram implementation
│       ├── openai_provider.dart       # OpenAI DALL-E implementation
│       ├── stability_provider.dart    # Stability AI implementation
│       └── replicate_provider.dart    # Replicate Flux implementation
├── screens/
│   └── home_screen.dart               # Main UI with image gallery
├── services/
│   └── secure_storage_service.dart    # Multi-provider encrypted key storage
├── state/
│   └── generation_state.dart          # State management (Provider pattern)
├── widgets/
│   ├── generation_form.dart           # Image generation input form
│   ├── provider_settings_dialog.dart  # Multi-provider configuration UI
│   └── premium_widgets.dart           # Reusable UI components
└── theme/
    └── premium_theme.dart             # App-wide theme configuration
```

## 🧪 Error Handling

The app provides specific error messages for:
- **Authentication errors** (401/403): Invalid or expired API key
- **Rate limiting** (429): Too many requests
- **Network errors**: Connection failures with automatic retry
- **Timeout errors**: Requests taking too long (60s+)
- **Server errors** (5xx): API server issues
- **Validation errors**: Invalid prompts or parameters

## 🌟 What's New - Multi-API Support!

### Latest Updates
- 🎯 **Multi-API Support**: Choose from 4 different AI image generation providers
- 🔄 **Provider Switching**: Easily switch between APIs with preserved settings
- 💾 **Multiple API Keys**: Store and manage keys for all providers simultaneously
- 🎨 **Provider-Specific UI**: Settings dialog shows each provider's unique features
- 📖 **Comprehensive Documentation**: Detailed API setup guide with comparison table
- 🔐 **Enhanced Security**: Separate encrypted storage for each provider
- 🔄 **Automatic Migration**: Legacy Ideogram keys automatically upgraded

### Previous Features
- ✨ **Image history accumulation** (no longer replaced on each generation)
- 🔄 **Automatic retry** with exponential backoff
- 🌓 **Dark mode support**
- 👆 **Interactive image viewer** with copy/share
- 🗑️ **Clear all images** functionality
- ⏱️ **Timeout configuration** (60-90s)
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
