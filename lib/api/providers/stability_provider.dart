import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../base_image_provider.dart';

/// Stability AI image generation provider
class StabilityProvider extends BaseImageProvider {
  static const String _baseUrl =
      'https://api.stability.ai/v2beta/stable-image/generate/sd3';
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 90);

  StabilityProvider({super.apiKey});

  @override
  String get providerName => 'Stability AI';

  @override
  String get providerId => 'stability';

  @override
  String get baseUrl => _baseUrl;

  @override
  List<String> get supportedStyles => [
        'Photographic',
        'Digital Art',
        'Cinematic',
        'Anime',
        'Fantasy Art',
        '3D Model',
        'Analog Film',
        'Neon Punk',
        'Low Poly',
      ];

  @override
  bool get supportsAspectRatio => true;

  @override
  bool get supportsCustomDimensions => false;

  @override
  String get apiKeyInstructions =>
      'Get your Stability AI API key from https://platform.stability.ai/account/keys';

  @override
  bool validateApiKey(String key) {
    // Stability AI keys start with 'sk-'
    return key.startsWith('sk-') && key.length > 20;
  }

  @override
  Future<List<GeneratedImage>> generateImages(
      ImageGenerationRequest request) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw ImageGenerationException(
        'Stability AI API key not configured. Please add your API key in settings.',
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

  String _getAspectRatio(double? ratio) {
    if (ratio == null) return '1:1';
    if ((ratio - 1.0).abs() < 0.1) return '1:1';
    if ((ratio - 1.78).abs() < 0.1) return '16:9';
    if ((ratio - 0.56).abs() < 0.1) return '9:16';
    if ((ratio - 1.33).abs() < 0.1) return '4:3';
    if ((ratio - 0.75).abs() < 0.1) return '3:4';
    if ((ratio - 2.39).abs() < 0.1) return '21:9';
    return '1:1';
  }

  Future<List<GeneratedImage>> _performRequest(
      ImageGenerationRequest request) async {
    final aspectRatio = _getAspectRatio(request.aspectRatio);

    // Create multipart request
    final uri = Uri.parse(_baseUrl);
    final multipartRequest = http.MultipartRequest('POST', uri);

    multipartRequest.headers.addAll({
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    });

    // Add form fields
    multipartRequest.fields['prompt'] = request.prompt;
    multipartRequest.fields['aspect_ratio'] = aspectRatio;
    multipartRequest.fields['output_format'] = 'png';
    multipartRequest.fields['mode'] = 'text-to-image';

    if (request.style != null && request.style!.isNotEmpty) {
      multipartRequest.fields['style_preset'] =
          request.style!.toLowerCase().replaceAll(' ', '-');
    }

    final streamedResponse =
        await multipartRequest.send().timeout(_requestTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response, request.prompt);
  }

  List<GeneratedImage> _handleResponse(
      http.Response response, String prompt) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Stability AI returns base64 image or a URL depending on the API
      if (data['image'] != null) {
        // Base64 encoded image
        final imageBase64 = data['image'] as String;
        return [
          GeneratedImage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            url: 'data:image/png;base64,$imageBase64',
            prompt: prompt,
            metadata: {
              'provider': providerId,
              'seed': data['seed'],
              'finish_reason': data['finish_reason'],
            },
          ),
        ];
      } else if (data['artifacts'] != null) {
        // Multiple artifacts format
        final List<dynamic> artifacts = data['artifacts'];
        return artifacts
            .map((artifact) => GeneratedImage(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  url: 'data:image/png;base64,${artifact['base64']}',
                  prompt: prompt,
                  metadata: {
                    'provider': providerId,
                    'seed': artifact['seed'],
                    'finish_reason': artifact['finishReason'],
                  },
                ))
            .toList();
      }

      throw ImageGenerationException('Unexpected response format from Stability AI');
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
        errorMessage =
            'Stability AI authentication failed. Please check your API key.';
        break;
      case 402:
        errorMessage =
            'Insufficient credits. Please check your Stability AI account balance.';
        break;
      case 429:
        errorMessage =
            'Rate limit exceeded. Please wait a moment and try again.';
        break;
      case 400:
        errorMessage = 'Stability AI error: $errorMessage';
        break;
      case 500:
      case 502:
      case 503:
        errorMessage =
            'Stability AI service is temporarily unavailable. Please try again later.';
        break;
    }

    throw ImageGenerationException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }
}
