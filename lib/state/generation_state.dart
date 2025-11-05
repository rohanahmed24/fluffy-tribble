import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../api/ideogram_api_client.dart';
import '../api/base_image_provider.dart';
import '../api/provider_factory.dart';
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
  String _selectedProviderId = 'ideogram';
  BaseImageProvider? _currentProvider;
  Map<String, String> _apiKeys = {};

  /// Whether an image generation request is currently in progress.
  bool get isLoading => _isLoading;

  /// The currently stored API key, if any.
  String? get apiKey => _apiKey;

  /// The most recent error message, if any.
  String? get error => _error;

  /// The list of all generated images in chronological order.
  List<GeneratedImage> get images => _images;

  /// The currently selected provider ID
  String get selectedProviderId => _selectedProviderId;

  /// The current provider instance
  BaseImageProvider? get currentProvider => _currentProvider;

  /// All stored API keys
  Map<String, String> get apiKeys => _apiKeys;

  /// Get all available providers
  List<ProviderInfo> get availableProviders => ProviderFactory.availableProviders;

  /// Get the current provider info
  ProviderInfo? get currentProviderInfo =>
      ProviderFactory.getProviderInfo(_selectedProviderId);

  /// Loads the API key from secure storage on app startup.
  Future<void> loadApiKey() async {
    // Migrate legacy key if needed
    await _storage.migrateLegacyKey();

    // Load all API keys
    _apiKeys = await _storage.getAllApiKeys();

    // Load selected provider
    final selectedProvider = await _storage.getSelectedProvider();
    if (selectedProvider != null) {
      _selectedProviderId = selectedProvider;
    }

    // Load API key for current provider
    _apiKey = await _storage.readProviderApiKey(_selectedProviderId);

    // Initialize current provider
    if (_apiKey != null) {
      _currentProvider = ProviderFactory.createProvider(
        _selectedProviderId,
        apiKey: _apiKey,
      );
    }

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

    await _storage.writeProviderApiKey(_selectedProviderId, trimmed);
    _apiKey = trimmed;
    _apiKeys[_selectedProviderId] = trimmed;

    // Update current provider
    _currentProvider = ProviderFactory.createProvider(
      _selectedProviderId,
      apiKey: trimmed,
    );

    _error = null;
    notifyListeners();
  }

  /// Updates API key for a specific provider
  Future<void> updateProviderApiKey(String providerId, String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      await _storage.deleteProviderApiKey(providerId);
      _apiKeys.remove(providerId);
    } else {
      await _storage.writeProviderApiKey(providerId, trimmed);
      _apiKeys[providerId] = trimmed;
    }

    // If updating current provider, update the current instance
    if (providerId == _selectedProviderId) {
      _apiKey = trimmed.isEmpty ? null : trimmed;
      _currentProvider = trimmed.isEmpty
          ? null
          : ProviderFactory.createProvider(providerId, apiKey: trimmed);
    }

    notifyListeners();
  }

  /// Switches to a different provider
  Future<void> selectProvider(String providerId) async {
    if (!ProviderFactory.isValidProvider(providerId)) {
      _error = 'Invalid provider: $providerId';
      notifyListeners();
      return;
    }

    _selectedProviderId = providerId;
    await _storage.setSelectedProvider(providerId);

    // Load API key for new provider
    _apiKey = await _storage.readProviderApiKey(providerId);

    // Update current provider instance
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _currentProvider = ProviderFactory.createProvider(
        providerId,
        apiKey: _apiKey,
      );
    } else {
      _currentProvider = null;
    }

    _error = null;
    notifyListeners();
  }

  /// Generates images using the selected provider and adds them to the gallery.
  ///
  /// Images are accumulated (not replaced), so each generation adds to the existing gallery.
  /// Requires a valid API key to be set before calling.
  Future<void> generateImage({
    required String prompt,
    String? style,
    double? aspectRatio,
    int? width,
    int? height,
    // Legacy parameters for backward compatibility
    ImageStyle? legacyStyle,
  }) async {
    if (prompt.trim().isEmpty) {
      _error = 'Prompt cannot be empty.';
      notifyListeners();
      return;
    }

    final key = _apiKey;
    if (key == null || key.isEmpty) {
      _error = 'Please provide a valid API key in Settings for ${currentProviderInfo?.name ?? 'the selected provider'}.';
      notifyListeners();
      return;
    }

    if (_currentProvider == null) {
      _error = 'Provider not initialized. Please check your settings.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert legacy style to string if provided
      final styleString = style ?? legacyStyle?.displayName;

      final request = ImageGenerationRequest(
        prompt: prompt,
        style: styleString,
        aspectRatio: aspectRatio,
        width: width,
        height: height,
      );

      final newImages = await _currentProvider!.generateImages(request);
      // Accumulate images instead of replacing them
      _images = [..._images, ...newImages];
    } on ImageGenerationException catch (error) {
      debugPrint('API error: $error');
      _error = error.message;
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

  /// Generates images using the legacy method (for backward compatibility)
  Future<void> generateImageLegacy({
    required String prompt,
    required ImageStyle style,
    double aspectRatio = 1.0,
  }) async {
    return generateImage(
      prompt: prompt,
      legacyStyle: style,
      aspectRatio: aspectRatio,
    );
  }

  /// Deletes the stored API key and clears all generated images.
  Future<void> deleteKey() async {
    await _storage.deleteProviderApiKey(_selectedProviderId);
    _apiKeys.remove(_selectedProviderId);
    _apiKey = null;
    _currentProvider = null;
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
