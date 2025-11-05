import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../base_image_provider.dart';

/// Ideogram image generation provider
class IdeogramProvider extends BaseImageProvider {
  static const String _defaultBaseUrl = 'https://api.ideogram.ai/v1/images';
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 60);

  final String _baseUrl;

  IdeogramProvider({
    super.apiKey,
    String? baseUrl,
  }) : _baseUrl = baseUrl ?? _defaultBaseUrl;

  @override
  String get providerName => 'Ideogram';

  @override
  String get providerId => 'ideogram';

  @override
  String get baseUrl => _baseUrl;

  @override
  List<String> get supportedStyles => [
        'Cinematic',
        'Watercolor',
        '3D Render',
        'Line Art',
        'Concept Art',
        'Photorealistic',
      ];

  @override
  bool get supportsAspectRatio => true;

  @override
  bool get supportsCustomDimensions => false;

  @override
  String get apiKeyInstructions =>
      'Get your Ideogram API key from https://ideogram.ai/api';

  @override
  bool validateApiKey(String key) {
    return key.isNotEmpty && key.length > 10;
  }

  @override
  Future<List<GeneratedImage>> generateImages(
      ImageGenerationRequest request) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw ImageGenerationException(
        'Ideogram API key not configured. Please add your API key in settings.',
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

  String _getAspectRatioString(double? ratio) {
    if (ratio == null) return 'ASPECT_1_1';
    if ((ratio - 1.0).abs() < 0.01) return 'ASPECT_1_1';
    if ((ratio - 1.78).abs() < 0.02) return 'ASPECT_16_9';
    if ((ratio - 0.75).abs() < 0.02) return 'ASPECT_3_4';
    if ((ratio - 0.56).abs() < 0.02) return 'ASPECT_9_16';
    return 'ASPECT_1_1'; // Default fallback
  }

  Future<List<GeneratedImage>> _performRequest(
      ImageGenerationRequest request) async {
    final aspectRatio = _getAspectRatioString(request.aspectRatio);

    final body = {
      'image_request': {
        'prompt': request.prompt,
        'aspect_ratio': aspectRatio,
        'model': 'V_2',
        'magic_prompt_option': 'AUTO',
      },
    };

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'Api-Key': apiKey!,
          },
          body: jsonEncode(body),
        )
        .timeout(_requestTimeout);

    return _handleResponse(response, request.prompt);
  }

  List<GeneratedImage> _handleResponse(
      http.Response response, String prompt) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['data'] ?? [];

        if (results.isEmpty) {
          throw ImageGenerationException('No images returned from Ideogram API');
        }

        return results
            .map((item) => GeneratedImage(
                  id: item['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  url: item['url'] as String,
                  prompt: item['prompt'] as String? ?? prompt,
                  metadata: {
                    'provider': providerId,
                  },
                ))
            .toList();
      } catch (e) {
        if (e is ImageGenerationException) rethrow;
        throw ImageGenerationException('Failed to parse Ideogram API response: $e');
      }
    }

    // Handle errors
    String errorMessage;
    try {
      final data = jsonDecode(response.body);
      errorMessage = data['message'] ?? data['error'] ?? 'Unknown error';
    } catch (_) {
      errorMessage = 'Failed to parse error response';
    }

    switch (response.statusCode) {
      case 401:
      case 403:
        errorMessage =
            'Ideogram authentication failed. Please check your API key.';
        break;
      case 429:
        errorMessage =
            'Rate limit exceeded. Please wait a moment and try again.';
        break;
      case 400:
        errorMessage = 'Ideogram error: $errorMessage';
        break;
      case 500:
      case 502:
      case 503:
        errorMessage =
            'Ideogram service is temporarily unavailable. Please try again later.';
        break;
    }

    throw ImageGenerationException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }
}
