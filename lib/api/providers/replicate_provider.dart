import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../base_image_provider.dart';

/// Replicate image generation provider using Flux model
class ReplicateProvider extends BaseImageProvider {
  static const String _baseUrl = 'https://api.replicate.com/v1/predictions';
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const Duration _pollInterval = Duration(seconds: 2);
  static const int _maxPollAttempts = 60; // Max 2 minutes of polling

  // Using Flux Schnell model - fast and high quality
  static const String _defaultModel =
      'black-forest-labs/flux-schnell';

  ReplicateProvider({super.apiKey});

  @override
  String get providerName => 'Replicate (Flux)';

  @override
  String get providerId => 'replicate';

  @override
  String get baseUrl => _baseUrl;

  @override
  List<String> get supportedStyles => [
        'Realistic',
        'Artistic',
        'Anime',
        'Fantasy',
        'Sci-Fi',
        'Abstract',
      ];

  @override
  bool get supportsAspectRatio => true;

  @override
  bool get supportsCustomDimensions => true;

  @override
  String get apiKeyInstructions =>
      'Get your Replicate API key from https://replicate.com/account/api-tokens';

  @override
  bool validateApiKey(String key) {
    // Replicate keys start with 'r8_'
    return key.startsWith('r8_') && key.length > 20;
  }

  @override
  Future<List<GeneratedImage>> generateImages(
      ImageGenerationRequest request) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw ImageGenerationException(
        'Replicate API key not configured. Please add your API key in settings.',
      );
    }

    return _generateWithRetry(request);
  }

  Future<List<GeneratedImage>> _generateWithRetry(
    ImageGenerationRequest request, {
    int retryCount = 0,
  }) async {
    try {
      return await _performRequest(request);
    } catch (e) {
      if (retryCount < _maxRetries &&
          (e is SocketException || e is TimeoutException)) {
        final delay = _initialRetryDelay * (retryCount + 1);
        await Future.delayed(delay);
        return _generateWithRetry(request, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  Future<List<GeneratedImage>> _performRequest(
      ImageGenerationRequest request) async {
    // Step 1: Create prediction
    final predictionId = await _createPrediction(request);

    // Step 2: Poll for completion
    final result = await _pollPrediction(predictionId);

    // Step 3: Extract image URLs
    return _extractImages(result, request.prompt);
  }

  Future<String> _createPrediction(ImageGenerationRequest request) async {
    // Calculate dimensions
    int width = request.width ?? 1024;
    int height = request.height ?? 1024;

    if (request.aspectRatio != null) {
      final ratio = request.aspectRatio!;
      if ((ratio - 1.78).abs() < 0.1) {
        width = 1344;
        height = 768;
      } else if ((ratio - 0.56).abs() < 0.1) {
        width = 768;
        height = 1344;
      } else if ((ratio - 1.33).abs() < 0.1) {
        width = 1024;
        height = 768;
      } else if ((ratio - 0.75).abs() < 0.1) {
        width = 768;
        height = 1024;
      }
    }

    final body = {
      'version': _getModelVersion(),
      'input': {
        'prompt': request.prompt,
        'width': width,
        'height': height,
        'num_outputs': request.numberOfImages ?? 1,
        'num_inference_steps': 4, // Flux Schnell is optimized for 4 steps
      },
    };

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as String;
    }

    _handleError(response);
    throw ImageGenerationException('Failed to create prediction');
  }

  String _getModelVersion() {
    // This is the version ID for Flux Schnell
    // In production, you might want to make this configurable
    return 'f2ab8a5bfe79f02f0789a146cf5e73d2a4ff2684a98c2b303d1e1ff3814271db';
  }

  Future<Map<String, dynamic>> _pollPrediction(String predictionId) async {
    for (int i = 0; i < _maxPollAttempts; i++) {
      await Future.delayed(_pollInterval);

      final response = await http.get(
        Uri.parse('$_baseUrl/$predictionId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String;

        if (status == 'succeeded') {
          return data;
        } else if (status == 'failed' || status == 'canceled') {
          final error = data['error'] ?? 'Prediction failed';
          throw ImageGenerationException('Replicate: $error');
        }
        // If still processing, continue polling
      } else {
        _handleError(response);
      }
    }

    throw ImageGenerationException(
      'Replicate: Image generation timed out. Please try again.',
    );
  }

  List<GeneratedImage> _extractImages(
      Map<String, dynamic> data, String prompt) {
    final output = data['output'];
    if (output == null) {
      throw ImageGenerationException('No output received from Replicate');
    }

    List<String> imageUrls = [];
    if (output is List) {
      imageUrls = output.map((url) => url.toString()).toList();
    } else if (output is String) {
      imageUrls = [output];
    }

    return imageUrls
        .map((url) => GeneratedImage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              url: url,
              prompt: prompt,
              metadata: {
                'provider': providerId,
                'model': _defaultModel,
                'prediction_id': data['id'],
              },
            ))
        .toList();
  }

  void _handleError(http.Response response) {
    String errorMessage;
    try {
      final data = jsonDecode(response.body);
      errorMessage = data['detail'] ?? data['error'] ?? 'Unknown error';
    } catch (_) {
      errorMessage = 'Failed to parse error response';
    }

    switch (response.statusCode) {
      case 401:
        errorMessage =
            'Replicate authentication failed. Please check your API key.';
        break;
      case 402:
        errorMessage =
            'Insufficient credits. Please check your Replicate account balance.';
        break;
      case 429:
        errorMessage =
            'Rate limit exceeded. Please wait a moment and try again.';
        break;
      case 400:
        errorMessage = 'Replicate error: $errorMessage';
        break;
      case 500:
      case 502:
      case 503:
        errorMessage =
            'Replicate service is temporarily unavailable. Please try again later.';
        break;
    }

    throw ImageGenerationException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }
}
