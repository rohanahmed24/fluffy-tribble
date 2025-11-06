# Cross-Platform Build Guide

AI Image Studio is a comprehensive cross-platform application that runs on **6 platforms**: Android, iOS, Web, Windows, macOS, and Linux.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Platform-Specific Setup](#platform-specific-setup)
  - [Android](#android)
  - [iOS](#ios)
  - [Web](#web)
  - [Windows](#windows)
  - [macOS](#macos)
  - [Linux](#linux)
- [Building for Each Platform](#building-for-each-platform)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required for All Platforms
1. **Flutter SDK 3.16.0 or later**
   ```bash
   # Install Flutter
   git clone https://github.com/flutter/flutter.git -b stable --depth 1
   export PATH="$PATH:`pwd`/flutter/bin"
   flutter doctor -v
   ```

2. **Project Dependencies**
   ```bash
   cd fluffy-tribble
   flutter pub get
   ```

3. **Environment Configuration**
   - Copy `.env.example` to `.env`
   - Configure API keys (see [API_SETUP.md](API_SETUP.md))

---

## Platform-Specific Setup

### Android

**Requirements:**
- Android Studio or Android SDK Tools
- Java JDK 11 or later
- Android NDK 27.0.12077973

**Setup:**
```bash
# Install Android NDK (if not installed)
sdkmanager --install "ndk;27.0.12077973"

# Accept licenses
flutter doctor --android-licenses
```

**Supported Architectures:**
- ARM64 (arm64-v8a) - Modern devices like Samsung S24 Ultra
- ARMv7 (armeabi-v7a) - Older devices
- x86_64 - Emulators

---

### iOS

**Requirements:**
- macOS (required)
- Xcode 14.0 or later
- CocoaPods

**Setup:**
```bash
# Install CocoaPods (if not installed)
sudo gem install cocoapods

# Navigate to iOS directory and install pods
cd ios
pod install
cd ..
```

**Supported Architectures:**
- ARM64 (iPhone 5s and later, iPad Air and later)

---

### Web

**Requirements:**
- Modern web browser (Chrome, Firefox, Safari, Edge)
- No additional setup required!

**Features:**
- Progressive Web App (PWA) support
- Responsive design for all screen sizes
- Works on any device with a modern browser

---

### Windows

**Requirements:**
- Windows 10 or later (64-bit)
- Visual Studio 2022 or Visual Studio Build Tools
  - Desktop development with C++
- CMake 3.14 or later

**Setup:**
```bash
# Enable Windows desktop support
flutter config --enable-windows-desktop

# Verify setup
flutter doctor -v
```

---

### macOS

**Requirements:**
- macOS 10.14 (Mojave) or later
- Xcode 14.0 or later
- CocoaPods

**Setup:**
```bash
# Enable macOS desktop support
flutter config --enable-macos-desktop

# Verify setup
flutter doctor -v
```

---

### Linux

**Requirements:**
- Ubuntu 20.04 or later (or equivalent)
- Clang 12 or later
- CMake 3.10 or later
- GTK 3.0 development libraries

**Setup:**
```bash
# Install required dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y \
  clang cmake ninja-build \
  pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev

# Enable Linux desktop support
flutter config --enable-linux-desktop

# Verify setup
flutter doctor -v
```

---

## Building for Each Platform

### Android

**Build APK (for distribution):**
```bash
# Build split APKs for different architectures (recommended)
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/
# - app-arm64-v8a-release.apk (use this for modern phones)
# - app-armeabi-v7a-release.apk (for older phones)
# - app-x86_64-release.apk (for emulators)
```

**Build App Bundle (for Google Play):**
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Run on device/emulator:**
```bash
flutter run --release
```

---

### iOS

**Build for device:**
```bash
flutter build ios --release

# Open in Xcode for signing and distribution
open ios/Runner.xcworkspace
```

**Run on simulator:**
```bash
flutter run -d "iPhone 14"
```

**Build IPA (requires Xcode):**
```bash
flutter build ipa --release

# Output: build/ios/ipa/
```

---

### Web

**Build for production:**
```bash
flutter build web --release

# Output: build/web/
```

**Deploy options:**
- **Firebase Hosting**: `firebase deploy`
- **GitHub Pages**: Copy `build/web/` to gh-pages branch
- **Netlify**: Drag and drop `build/web/` folder
- **Vercel**: Deploy `build/web/` directory
- **Self-hosted**: Serve `build/web/` with any web server

**Run locally:**
```bash
flutter run -d chrome

# Or run on a local server
cd build/web
python3 -m http.server 8000
# Visit http://localhost:8000
```

---

### Windows

**Build for Windows:**
```bash
flutter build windows --release

# Output: build/windows/runner/Release/
```

**Create installer (optional):**
- Use Inno Setup or NSIS to create a Windows installer
- Include all files from `build/windows/runner/Release/`

**Run locally:**
```bash
flutter run -d windows
```

---

### macOS

**Build for macOS:**
```bash
flutter build macos --release

# Output: build/macos/Build/Products/Release/
```

**Create DMG (optional):**
```bash
# Use create-dmg or similar tools
npm install --global create-dmg
create-dmg 'build/macos/Build/Products/Release/ai_image_studio.app'
```

**Run locally:**
```bash
flutter run -d macos
```

---

### Linux

**Build for Linux:**
```bash
flutter build linux --release

# Output: build/linux/x64/release/bundle/
```

**Create AppImage (optional):**
- Use `appimagetool` to package the app
- More portable and easier to distribute

**Run locally:**
```bash
flutter run -d linux
```

---

## Building All Platforms at Once

For CI/CD or batch building:

```bash
# Android
flutter build apk --release --split-per-abi
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release --no-codesign

# Web
flutter build web --release

# Windows (Windows only)
flutter build windows --release

# macOS (macOS only)
flutter build macos --release

# Linux (Linux only)
flutter build linux --release
```

---

## Troubleshooting

### Common Issues

**1. "GeneratedImage not found" error**
- Solution: Make sure you're on the latest commit with all fixes
- Run: `git pull origin main && flutter clean && flutter pub get`

**2. Android NDK version mismatch**
- Solution: Update to NDK 27.0.12077973
- The app is configured to use this version in `android/app/build.gradle.kts`

**3. Web build fails**
- Clear build cache: `flutter clean`
- Rebuild: `flutter build web --release`

**4. iOS signing issues**
- Open `ios/Runner.xcworkspace` in Xcode
- Configure signing team and certificates

**5. Windows/macOS/Linux desktop not working**
- Ensure desktop support is enabled:
  ```bash
  flutter config --enable-windows-desktop
  flutter config --enable-macos-desktop
  flutter config --enable-linux-desktop
  ```

**6. flutter_secure_storage issues on Linux**
- Install libsecret: `sudo apt-get install libsecret-1-dev`

---

## Platform-Specific Notes

### Android
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Best Architecture**: ARM64 (arm64-v8a) for modern devices

### iOS
- **Minimum**: iOS 12.0
- **Best Target**: iOS 14.0+
- Requires Apple Developer account for device testing and App Store

### Web
- Works on all modern browsers
- Progressive Web App (PWA) features available
- No app store required - just deploy to any web hosting

### Windows
- Requires Windows 10 1809 or later
- 64-bit only
- Can be distributed as standalone .exe or installer

### macOS
- Requires macOS 10.14 (Mojave) or later
- Supports both Intel (x64) and Apple Silicon (ARM64)
- Can be distributed as .app bundle or DMG

### Linux
- Tested on Ubuntu 20.04+
- Should work on most modern distros
- Can be distributed as AppImage, Snap, or Flatpak

---

## Distribution Recommendations

| Platform | Recommended Distribution Method |
|----------|-------------------------------|
| Android | Google Play Store (AAB) or Direct APK download |
| iOS | Apple App Store (IPA) |
| Web | Firebase Hosting, Netlify, Vercel, GitHub Pages |
| Windows | Microsoft Store, Direct download (.exe), or Installer |
| macOS | Mac App Store or DMG file |
| Linux | Snap Store, Flatpak, AppImage, or .deb package |

---

## Next Steps

1. **Configure API Keys**: See [API_SETUP.md](API_SETUP.md)
2. **Test on target platforms**: Run the app on each platform you want to support
3. **Customize branding**: Update app icons, splash screens, and metadata
4. **Set up CI/CD**: Use GitHub Actions, AppVeyor, or other services for automated builds

---

## Need Help?

- Check the main [README.md](README.md) for general information
- Review [API_SETUP.md](API_SETUP.md) for API configuration
- File issues on GitHub: https://github.com/rohanahmed24/fluffy-tribble/issues

---

**Congratulations!** You now have a true cross-platform mega application that runs everywhere! 🎉
