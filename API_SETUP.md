# Multi-API Image Generation Setup Guide

This Flutter app now supports multiple image generation API providers, allowing you to choose the one that best fits your needs. You can easily switch between providers and configure multiple API keys.

## Supported API Providers

### 1. **Ideogram** (Default)
- **Description**: High-quality text-to-image generation with excellent text rendering
- **Get API Key**: https://ideogram.ai/api
- **Features**:
  - Supports aspect ratio configuration
  - Multiple artistic styles (Cinematic, Watercolor, 3D Render, etc.)
  - Magic prompt enhancement

### 2. **OpenAI DALL-E**
- **Description**: DALL-E 3 - Advanced AI image generation from OpenAI
- **Get API Key**: https://platform.openai.com/api-keys
- **API Key Format**: Starts with `sk-` or `sk-proj-`
- **Features**:
  - High-quality image generation
  - Natural and Vivid style options
  - Supports custom dimensions (1024x1024, 1792x1024, 1024x1792)
  - Prompt revision for improved results

### 3. **Stability AI**
- **Description**: Stable Diffusion - Powerful open-source image generation
- **Get API Key**: https://platform.stability.ai/account/keys
- **API Key Format**: Starts with `sk-`
- **Features**:
  - Multiple artistic styles (Photographic, Digital Art, Cinematic, Anime, etc.)
  - Aspect ratio support
  - Base64 encoded images
  - Fast generation

### 4. **Replicate (Flux)**
- **Description**: Flux Schnell - Fast and high-quality image generation
- **Get API Key**: https://replicate.com/account/api-tokens
- **API Key Format**: Starts with `r8_`
- **Features**:
  - Very fast generation (4 inference steps)
  - Custom dimensions support
  - Aspect ratio support
  - Multiple output images

## How to Configure API Providers

### Method 1: Using the App UI (Recommended)

1. **Open the app**
2. **Tap the key icon** in the top-right corner
3. **Select your preferred provider** from the list
4. **Expand the provider card** by tapping on it
5. **Enter your API key** in the text field
6. **Repeat for other providers** if you want to configure multiple
7. **Tap "Save"** to apply changes

The app will automatically:
- Store your API keys securely using platform-native encryption
- Switch to your selected provider
- Remember your settings across app restarts

### Method 2: Programmatic Configuration

You can also configure providers programmatically:

```dart
final state = Provider.of<GenerationState>(context, listen: false);

// Set API key for a specific provider
await state.updateProviderApiKey('openai', 'sk-...');

// Switch to a different provider
await state.selectProvider('openai');
```

## Switching Between Providers

1. Open the settings dialog (key icon)
2. Select a different provider by clicking its radio button
3. Make sure that provider has an API key configured
4. Click "Save"

The app will immediately switch to the new provider and show its name in the header.

## API Key Storage

- **Secure**: All API keys are stored using Flutter's secure storage
- **Platform-native encryption**:
  - Android: Encrypted SharedPreferences
  - iOS/macOS: Keychain with first-unlock accessibility
- **Never exposed**: API keys are never logged or exposed in the UI (shown as dots)
- **Easy migration**: Legacy Ideogram keys are automatically migrated to the new system

## Comparison of Providers

| Feature | Ideogram | OpenAI DALL-E | Stability AI | Replicate (Flux) |
|---------|----------|---------------|--------------|------------------|
| **Speed** | Medium | Medium | Fast | Very Fast |
| **Quality** | High | Very High | High | High |
| **Text Rendering** | Excellent | Good | Fair | Good |
| **Custom Styles** | 6 styles | 2 styles | 9 styles | 6 styles |
| **Aspect Ratios** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes |
| **Custom Dimensions** | ❌ No | ✅ Yes | ❌ No | ✅ Yes |
| **Cost** | Varies | $$$ | $$ | $ |

## Troubleshooting

### "API key not configured" error
- Make sure you've entered an API key for the selected provider
- Check that the API key format is correct (see formats above)
- Verify your API key is active on the provider's platform

### "Authentication failed" error
- Your API key may be invalid or expired
- Check your API key on the provider's dashboard
- Generate a new API key if needed

### "Rate limit exceeded" error
- You've made too many requests in a short time
- Wait a few moments and try again
- Consider upgrading your plan on the provider's platform

### "Insufficient credits" error (Stability AI / Replicate)
- Your account balance is too low
- Add credits to your account on the provider's platform

## Building the APK

To build the APK with multi-API support:

```bash
# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

# Or build for specific architecture
flutter build apk --release --target-platform android-arm64
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## Installation

1. Enable "Install from Unknown Sources" on your Android device
2. Transfer the APK to your device
3. Tap the APK file to install
4. Open the app and configure your preferred API provider

## Need Help?

- **API Keys**: Visit each provider's documentation for help obtaining API keys
- **App Issues**: Check the error messages in the app for specific guidance
- **Feature Requests**: Submit an issue on the GitHub repository
