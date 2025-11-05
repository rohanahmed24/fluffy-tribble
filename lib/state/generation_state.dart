import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../api/ideogram_api_client.dart';
import '../services/secure_storage_service.dart';

/// Manages the application state for image generation.
///
/// Handles API key management, image generation requests,
/// and maintains the history of generated images.
class GenerationState extends ChangeNotifier {
  GenerationState() {
    _client = IdeogramApiClient(
      baseUrl: dotenv.env['IDEOGRAM_BASE_URL'] ??
          'https://api.ideogram.ai/generate',
    );
  }

  late final IdeogramApiClient _client;
  final SecureStorageService _storage = const SecureStorageService();

  bool _isLoading = false;
  String? _apiKey;
  String? _error;
  List<GeneratedImage> _images = const [];

  /// Whether an image generation request is currently in progress.
  bool get isLoading => _isLoading;

  /// The currently stored API key, if any.
  String? get apiKey => _apiKey;

  /// The most recent error message, if any.
  String? get error => _error;

  /// The list of all generated images in chronological order.
  List<GeneratedImage> get images => _images;

  /// Loads the API key from secure storage on app startup.
  Future<void> loadApiKey() async {
    _apiKey = await _storage.readApiKey();
    notifyListeners();
  }

  /// Updates and securely stores a new API key.
  ///
  /// Validates that the key is non-empty before storing.
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

  /// Generates images using the Ideogram API and adds them to the gallery.
  ///
  /// Images are accumulated (not replaced), so each generation adds to the existing gallery.
  /// Requires a valid API key to be set before calling.
  Future<void> generateImage({
    required String prompt,
    required ImageStyle style,
    double aspectRatio = 1.0,
  }) async {
    if (prompt.trim().isEmpty) {
      _error = 'Prompt cannot be empty.';
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
      final newImages = await _client.generateImage(
        apiKey: key,
        prompt: prompt,
        style: style,
        aspectRatio: aspectRatio,
      );
      // Accumulate images instead of replacing them
      _images = [..._images, ...newImages];
    } on ApiException catch (error) {
      debugPrint('API error: $error');
      _error = error.message;
    } catch (error, stackTrace) {
      debugPrint('Image generation failed: $error\n$stackTrace');
      _error = 'Unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes the stored API key and clears all generated images.
  Future<void> deleteKey() async {
    await _storage.deleteApiKey();
    _apiKey = null;
    _error = null;
    _images = [];
    notifyListeners();
  }

  /// Clears all generated images from the gallery.
  void clearImages() {
    _images = [];
    _error = null;
    notifyListeners();
  }

  /// Imports an API key from a JSON string.
  ///
  /// Expected format: `{"ideogramApiKey": "your-key-here"}`
  Future<void> importKeyFromJson(String jsonInput) async {
    try {
      final data = json.decode(jsonInput) as Map<String, dynamic>;
      final key = data['ideogramApiKey'] as String?;
      if (key == null || key.isEmpty) {
        throw const FormatException('Missing Ideogram API key');
      }
      await updateApiKey(key);
      _error = null;
      notifyListeners();
    } on FormatException catch (error) {
      _error = error.message;
      notifyListeners();
    }
  }
}
