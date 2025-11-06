import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform detection utilities for cross-platform apps
class PlatformHelper {
  /// Check if running on mobile (Android or iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Check if running on desktop (Windows, macOS, or Linux)
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Get platform name as string
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Check if platform supports desktop-specific features
  static bool get supportsDesktopFeatures => isDesktop || isWeb;

  /// Check if platform needs special mobile considerations
  static bool get needsMobileOptimization => isMobile;
}
