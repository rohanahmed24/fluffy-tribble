import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class IdeogramApiClient {
  IdeogramApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<List<GeneratedImage>> generateImage({
    required String apiKey,
    required String prompt,
    required ImageStyle style,
    double aspectRatio = 1.0,
  }) async {
    final uri = Uri.parse(baseUrl);
    final requestBody = jsonEncode(<String, dynamic>{
      'prompt': prompt,
      'image_width': (1024 * aspectRatio).round(),
      'image_height': 1024,
      'style': style.apiValue,
    });

    final response = await _httpClient.post(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $apiKey',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == HttpStatus.ok) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['data'] as List<dynamic>? ?? [];
      return results
          .map((dynamic item) =>
              GeneratedImage.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw HttpException(
      'Failed with status: ${response.statusCode}',
      uri: uri,
    );
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

class GeneratedImage {
  const GeneratedImage({
    required this.id,
    required this.url,
    this.prompt,
  });

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      prompt: json['prompt'] as String?,
    );
  }

  final String id;
  final String url;
  final String? prompt;
}
