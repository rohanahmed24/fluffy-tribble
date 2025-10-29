import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({required this.baseUrl, required this.requestTimeout});

  final Uri baseUrl;
  final Duration requestTimeout;

  static final Uri _defaultBaseUrl = Uri.parse(
    'https://api.ideogram.ai/v1/images',
  );
  static const Duration _defaultTimeout = Duration(seconds: 30);

  static Future<AppConfig> load({
    String primaryFile = '.env',
    String fallbackFile = '.env.example',
  }) async {
    if (!dotenv.isInitialized) {
      await _loadEnvFile(primaryFile);
    }

    if (!dotenv.isInitialized) {
      await _loadEnvFile(fallbackFile);
    }

    final uri = _parseBaseUrl(dotenv.env['IDEOGRAM_BASE_URL']);
    final timeout = _parseTimeout(dotenv.env['IDEOGRAM_TIMEOUT_SECONDS']);

    return AppConfig(baseUrl: uri, requestTimeout: timeout);
  }

  static Future<void> _loadEnvFile(String fileName) async {
    try {
      await dotenv.load(fileName: fileName);
    } on FlutterError catch (error) {
      debugPrint('Failed to load $fileName: ${error.message}');
    } on FileSystemException catch (error) {
      debugPrint('Failed to read $fileName: ${error.message}');
    }
  }

  static Uri _parseBaseUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _defaultBaseUrl;
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.isScheme('https')) {
      debugPrint('Invalid IDEOGRAM_BASE_URL "$value". Using default.');
      return _defaultBaseUrl;
    }

    return uri;
  }

  static Duration _parseTimeout(String? value) {
    if (value == null) {
      return _defaultTimeout;
    }

    final seconds = int.tryParse(value);
    if (seconds == null || seconds <= 0) {
      debugPrint('Invalid IDEOGRAM_TIMEOUT_SECONDS "$value". Using default.');
      return _defaultTimeout;
    }

    return Duration(seconds: seconds);
  }
}
