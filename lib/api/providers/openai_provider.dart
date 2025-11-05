import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../base_image_provider.dart';

/// OpenAI DALL-E image generation provider
class OpenAIProvider extends BaseImageProvider {
  static const String _baseUrl = 'https://api.openai.com/v1/images/generations';
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 60);

  OpenAIProvider({super.apiKey});

  @override
  String get providerName => 'OpenAI DALL-E';

  @override
  String get providerId => 'openai';

  @override
  String get baseUrl => _baseUrl;

  @override
  List<String> get supportedStyles => [
        'Natural',
        'Vivid',
      ];

  @override
  bool get supportsAspectRatio => false;

  @override
  bool get supportsCustomDimensions => true;

  @override
  String get apiKeyInstructions =>
      'Get your OpenAI API key from https://platform.openai.com/api-keys';

  @override
  bool validateApiKey(String key) {
    // OpenAI keys start with 'sk-' or 'sk-proj-'
    return key.startsWith('sk-') && key.length > 20;
  }

  @override
  Future<List<GeneratedImage>> generateImages(
      ImageGenerationRequest request) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw ImageGenerationException(
        'OpenAI API key not configured. Please add your API key in settings.',
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
    // Determine size based on dimensions or use default
    String size = '1024x1024'; // Default DALL-E 3 size
    if (request.width != null && request.height != null) {
      // DALL-E 3 supports: 1024x1024, 1792x1024, 1024x1792
      if (request.width == 1792 && request.height == 1024) {
        size = '1792x1024';
      } else if (request.width == 1024 && request.height == 1792) {
        size = '1024x1792';
      }
    }

    final body = {
      'model': 'dall-e-3',
      'prompt': request.prompt,
      'n': 1, // DALL-E 3 only supports n=1
      'size': size,
      'quality': 'standard', // 'standard' or 'hd'
      'style': request.style?.toLowerCase() ?? 'vivid', // 'natural' or 'vivid'
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

    return _handleResponse(response, request.prompt);
  }

  List<GeneratedImage> _handleResponse(
      http.Response response, String prompt) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> imageData = data['data'] ?? [];

      return imageData
          .map((img) => GeneratedImage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                url: img['url'] as String,
                prompt: prompt,
                metadata: {
                  'provider': providerId,
                  'revised_prompt': img['revised_prompt'],
                },
              ))
          .toList();
    }

    // Handle errors
    String errorMessage;
    switch (response.statusCode) {
      case 401:
        errorMessage =
            'OpenAI API authentication failed. Please check your API key.';
        break;
      case 429:
        errorMessage =
            'Rate limit exceeded. Please wait a moment and try again.';
        break;
      case 400:
        final data = jsonDecode(response.body);
        final error = data['error']?['message'] ?? 'Invalid request';
        errorMessage = 'OpenAI API error: $error';
        break;
      case 500:
      case 502:
      case 503:
        errorMessage =
            'OpenAI service is temporarily unavailable. Please try again later.';
        break;
      default:
        errorMessage =
            'Failed to generate image. Status code: ${response.statusCode}';
    }

    throw ImageGenerationException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }
}
