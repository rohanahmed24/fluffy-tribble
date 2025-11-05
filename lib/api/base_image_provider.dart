import 'dart:async';

/// Represents a generated image with metadata
class GeneratedImage {
  final String id;
  final String url;
  final String? prompt;
  final Map<String, dynamic>? metadata;

  GeneratedImage({
    required this.id,
    required this.url,
    this.prompt,
    this.metadata,
  });

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      id: json['id'] as String,
      url: json['url'] as String,
      prompt: json['prompt'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'prompt': prompt,
      'metadata': metadata,
    };
  }
}

/// Image generation request parameters
class ImageGenerationRequest {
  final String prompt;
  final String? style;
  final double? aspectRatio;
  final int? width;
  final int? height;
  final int? numberOfImages;
  final Map<String, dynamic>? additionalParams;

  ImageGenerationRequest({
    required this.prompt,
    this.style,
    this.aspectRatio,
    this.width,
    this.height,
    this.numberOfImages = 1,
    this.additionalParams,
  });
}

/// Base exception for image generation errors
class ImageGenerationException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ImageGenerationException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Abstract base class for all image generation API providers
abstract class BaseImageProvider {
  /// The API key for authentication
  String? apiKey;

  BaseImageProvider({this.apiKey});

  /// Returns the name of this provider (e.g., "OpenAI DALL-E", "Stability AI")
  String get providerName;

  /// Returns a short identifier for this provider (e.g., "openai", "stability")
  String get providerId;

  /// Returns the list of supported styles for this provider
  List<String> get supportedStyles;

  /// Returns whether this provider supports aspect ratio configuration
  bool get supportsAspectRatio;

  /// Returns whether this provider supports custom dimensions (width/height)
  bool get supportsCustomDimensions;

  /// Generates images based on the request parameters
  ///
  /// Throws [ImageGenerationException] if the request fails
  Future<List<GeneratedImage>> generateImages(ImageGenerationRequest request);

  /// Validates the API key format (optional implementation)
  bool validateApiKey(String key) {
    return key.isNotEmpty;
  }

  /// Returns helpful information about how to obtain an API key
  String get apiKeyInstructions;

  /// Returns the base URL or endpoint for this provider
  String get baseUrl;
}
