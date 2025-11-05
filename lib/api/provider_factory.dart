import 'base_image_provider.dart';
import 'providers/ideogram_provider.dart';
import 'providers/openai_provider.dart';
import 'providers/stability_provider.dart';
import 'providers/replicate_provider.dart';

/// Factory class for creating and managing image generation providers
class ProviderFactory {
  static final ProviderFactory _instance = ProviderFactory._internal();
  factory ProviderFactory() => _instance;
  ProviderFactory._internal();

  /// Get all available providers
  static List<ProviderInfo> get availableProviders => [
        ProviderInfo(
          id: 'ideogram',
          name: 'Ideogram',
          description: 'High-quality text-to-image generation with excellent text rendering',
          requiresApiKey: true,
        ),
        ProviderInfo(
          id: 'openai',
          name: 'OpenAI DALL-E',
          description: 'DALL-E 3 - Advanced AI image generation from OpenAI',
          requiresApiKey: true,
        ),
        ProviderInfo(
          id: 'stability',
          name: 'Stability AI',
          description: 'Stable Diffusion - Powerful open-source image generation',
          requiresApiKey: true,
        ),
        ProviderInfo(
          id: 'replicate',
          name: 'Replicate (Flux)',
          description: 'Flux Schnell - Fast and high-quality image generation',
          requiresApiKey: true,
        ),
      ];

  /// Create a provider instance by ID
  static BaseImageProvider createProvider(String providerId, {String? apiKey}) {
    switch (providerId) {
      case 'ideogram':
        return IdeogramProvider(apiKey: apiKey);
      case 'openai':
        return OpenAIProvider(apiKey: apiKey);
      case 'stability':
        return StabilityProvider(apiKey: apiKey);
      case 'replicate':
        return ReplicateProvider(apiKey: apiKey);
      default:
        throw ArgumentError('Unknown provider: $providerId');
    }
  }

  /// Get provider info by ID
  static ProviderInfo? getProviderInfo(String providerId) {
    try {
      return availableProviders.firstWhere((p) => p.id == providerId);
    } catch (_) {
      return null;
    }
  }

  /// Validate if a provider ID is valid
  static bool isValidProvider(String providerId) {
    return availableProviders.any((p) => p.id == providerId);
  }
}

/// Information about an image generation provider
class ProviderInfo {
  final String id;
  final String name;
  final String description;
  final bool requiresApiKey;

  ProviderInfo({
    required this.id,
    required this.name,
    required this.description,
    this.requiresApiKey = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'requiresApiKey': requiresApiKey,
    };
  }

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      requiresApiKey: json['requiresApiKey'] as bool? ?? true,
    );
  }
}
