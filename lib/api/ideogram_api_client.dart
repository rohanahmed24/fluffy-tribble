import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// Export GeneratedImage from base provider for backward compatibility
export 'base_image_provider.dart' show GeneratedImage;

/// Custom exception for API-related errors
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final String? details;

  @override
  String toString() => 'ApiException: $message${details != null ? ' - $details' : ''}';
}

class IdeogramApiClient {
  IdeogramApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 60),
    this.maxRetries = 3,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;
  final Duration timeout;
  final int maxRetries;

  /// Generates images using the Ideogram API with retry logic
  Future<List<GeneratedImage>> generateImage({
    required String apiKey,
    required String prompt,
    required ImageStyle style,
    double aspectRatio = 1.0,
  }) async {
    int retryCount = 0;
    Duration retryDelay = const Duration(seconds: 2);

    while (retryCount <= maxRetries) {
      try {
        return await _performRequest(
          apiKey: apiKey,
          prompt: prompt,
          style: style,
          aspectRatio: aspectRatio,
        );
      } on SocketException catch (e) {
        if (retryCount == maxRetries) {
          throw ApiException(
            'Network error: Unable to connect to server',
            details: e.message,
          );
        }
        retryCount++;
        await Future.delayed(retryDelay);
        retryDelay *= 2; // Exponential backoff
      } on TimeoutException {
        if (retryCount == maxRetries) {
          throw ApiException('Request timed out after ${timeout.inSeconds} seconds');
        }
        retryCount++;
        await Future.delayed(retryDelay);
        retryDelay *= 2;
      } on ApiException {
        rethrow; // Don't retry on API errors (auth, validation, etc.)
      } catch (e) {
        if (retryCount == maxRetries) {
          throw ApiException('Unexpected error: ${e.toString()}');
        }
        retryCount++;
        await Future.delayed(retryDelay);
        retryDelay *= 2;
      }
    }

    throw ApiException('Failed after $maxRetries retries');
  }

  Future<List<GeneratedImage>> _performRequest({
    required String apiKey,
    required String prompt,
    required ImageStyle style,
    required double aspectRatio,
  }) async {
    final uri = Uri.parse(baseUrl);
    final requestBody = jsonEncode(<String, dynamic>{
      'image_request': {
        'prompt': prompt,
        'aspect_ratio': _getAspectRatioString(aspectRatio),
        'model': 'V_2',
        'magic_prompt_option': 'AUTO',
      },
    });

    final response = await _httpClient
        .post(
          uri,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $apiKey',
            HttpHeaders.contentTypeHeader: 'application/json',
            'Api-Key': apiKey,
          },
          body: requestBody,
        )
        .timeout(timeout);

    return _handleResponse(response, uri);
  }

  String _getAspectRatioString(double ratio) {
    // Convert decimal to aspect ratio string (e.g., 1.0 -> "ASPECT_1_1", 1.78 -> "ASPECT_16_9")
    if (ratio == 1.0) return 'ASPECT_1_1';
    if (ratio >= 1.77 && ratio <= 1.79) return 'ASPECT_16_9';
    if (ratio >= 0.74 && ratio <= 0.76) return 'ASPECT_3_4';
    if (ratio >= 0.56 && ratio <= 0.57) return 'ASPECT_9_16';
    return 'ASPECT_1_1'; // Default fallback
  }

  List<GeneratedImage> _handleResponse(http.Response response, Uri uri) {
    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['data'] as List<dynamic>? ?? [];

        if (results.isEmpty) {
          throw ApiException('No images returned from API');
        }

        return results
            .map((dynamic item) =>
                GeneratedImage.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Failed to parse API response', details: e.toString());
      }
    }

    // Handle specific error status codes
    switch (response.statusCode) {
      case HttpStatus.unauthorized:
      case HttpStatus.forbidden:
        throw ApiException(
          'Authentication failed: Invalid or expired API key',
          statusCode: response.statusCode,
        );
      case HttpStatus.badRequest:
        String details = 'Invalid request';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          details = errorData['message']?.toString() ?? details;
        } catch (_) {}
        throw ApiException(
          'Invalid request parameters',
          statusCode: response.statusCode,
          details: details,
        );
      case HttpStatus.tooManyRequests:
        throw ApiException(
          'Rate limit exceeded. Please try again later.',
          statusCode: response.statusCode,
        );
      case HttpStatus.internalServerError:
      case HttpStatus.badGateway:
      case HttpStatus.serviceUnavailable:
        throw ApiException(
          'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      default:
        throw ApiException(
          'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
          details: response.body,
        );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

enum ImageStyle {
  cinematic,
  watercolor,
  threeD,
  lineArt,
  concept,
  photorealistic,
}

extension ImageStyleExtension on ImageStyle {
  String get displayName {
    switch (this) {
      case ImageStyle.cinematic:
        return 'Cinematic';
      case ImageStyle.watercolor:
        return 'Watercolor';
      case ImageStyle.threeD:
        return '3D Render';
      case ImageStyle.lineArt:
        return 'Line Art';
      case ImageStyle.concept:
        return 'Concept Art';
      case ImageStyle.photorealistic:
        return 'Photorealistic';
    }
  }

  String get apiValue {
    switch (this) {
      case ImageStyle.cinematic:
        return 'cinematic';
      case ImageStyle.watercolor:
        return 'watercolor';
      case ImageStyle.threeD:
        return '3d';
      case ImageStyle.lineArt:
        return 'line_art';
      case ImageStyle.concept:
        return 'concept';
      case ImageStyle.photorealistic:
        return 'photorealistic';
    }
  }

  static ImageStyle fromDisplayName(String name) {
    return ImageStyle.values.firstWhere(
      (style) => style.displayName == name,
      orElse: () => ImageStyle.photorealistic,
    );
  }
}
