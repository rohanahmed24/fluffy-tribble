import 'dart:convert';

import 'package:flutter/material.dart';

import '../api/ideogram_api_client.dart';
import '../config/app_config.dart';
import '../services/secure_storage_service.dart';

class GenerationState extends ChangeNotifier {
  GenerationState({
    required AppConfig config,
    IdeogramApiClient? client,
    SecureStorageService? storage,
  })  : _client = client ??
            IdeogramApiClient(
              baseUri: config.baseUrl,
              timeout: config.requestTimeout,
            ),
        _storage = storage ?? const SecureStorageService();

  final IdeogramApiClient _client;
  final SecureStorageService _storage;

  bool _isLoading = false;
  String? _apiKey;
  String? _error;
  List<GeneratedImage> _images = const [];

  bool get isLoading => _isLoading;
  String? get apiKey => _apiKey;
  String? get error => _error;
  List<GeneratedImage> get images => _images;

  Future<void> loadApiKey() async {
    _apiKey = await _storage.readApiKey();
    notifyListeners();
  }

  Future<void> updateApiKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      _error = 'API key cannot be empty.';
      notifyListeners();
      return;
    }

    await _storage.writeApiKey(trimmed);
    _apiKey = trimmed;
    _error = null;
    notifyListeners();
  }

  Future<void> generateImage({
    required String prompt,
    required ImageStyle style,
    double aspectRatio = 1.0,
  }) async {
    if (_isLoading) {
      return;
    }

    if (prompt.trim().isEmpty) {
      _error = 'Prompt cannot be empty.';
      notifyListeners();
      return;
    }

    if (!_isValidAspectRatio(aspectRatio)) {
      _error = 'Aspect ratio must be between 0.25 and 4.0.';
      notifyListeners();
      return;
    }

    final key = _apiKey;
    if (key == null || key.isEmpty) {
      _error = 'Please provide a valid API key in Settings.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _images = await _client.generateImage(
        apiKey: key,
        prompt: prompt,
        style: style,
        aspectRatio: aspectRatio,
      );
      if (_images.isEmpty) {
        _error = 'No secure image URLs were returned. Try another prompt.';
      }
    } catch (error, stackTrace) {
      debugPrint('Image generation failed: $error\n$stackTrace');
      _error = 'Failed to generate image. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteKey() async {
    await _storage.deleteApiKey();
    _apiKey = null;
    _error = null;
    notifyListeners();
  }

  Future<void> importKeyFromJson(String jsonInput) async {
    try {
      final data = json.decode(jsonInput) as Map<String, dynamic>;
      final key = data['ideogramApiKey'] as String?;
      if (key == null || key.isEmpty) {
        throw const FormatException('Missing Ideogram API key');
      }
      await updateApiKey(key);
    } on FormatException catch (error) {
      _error = error.message;
      notifyListeners();
    }
  }

  bool _isValidAspectRatio(double ratio) => ratio >= 0.25 && ratio <= 4.0;
}
