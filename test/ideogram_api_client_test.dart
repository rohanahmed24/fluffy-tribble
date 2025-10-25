import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:ideogram_secure_app/api/ideogram_api_client.dart';

void main() {
  group('IdeogramApiClient', () {
    test('sends requests with expected payload and parses response', () async {
      late http.Request capturedRequest;

      final client = IdeogramApiClient(
        baseUrl: 'https://example.com/images',
        httpClient: MockClient((request) async {
          capturedRequest = request;
          final body = jsonEncode({
            'data': [
              {
                'id': 'img-1',
                'url': 'https://example.com/img-1.png',
                'prompt': 'A sample prompt',
              },
            ],
          });
          return http.Response(body, HttpStatus.ok);
        }),
      );

      final images = await client.generateImage(
        apiKey: 'test-key',
        prompt: 'A sample prompt',
        style: ImageStyle.cinematic,
        aspectRatio: 1.5,
      );

      expect(images, hasLength(1));
      expect(images.first.id, 'img-1');
      expect(images.first.url, 'https://example.com/img-1.png');
      expect(
        capturedRequest.headers[HttpHeaders.authorizationHeader],
        'Bearer test-key',
      );

      final decodedBody =
          jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(decodedBody['prompt'], 'A sample prompt');
      expect(decodedBody['image_width'], 1536);
      expect(decodedBody['image_height'], 1024);
      expect(decodedBody['style'], 'cinematic');
    });

    test('throws HttpException when API returns non-200 status', () async {
      final client = IdeogramApiClient(
        baseUrl: 'https://example.com/images',
        httpClient: MockClient(
          (_) async => http.Response('error', HttpStatus.badRequest),
        ),
      );

      expect(
        () => client.generateImage(
          apiKey: 'test-key',
          prompt: 'Failure prompt',
          style: ImageStyle.photorealistic,
        ),
        throwsA(isA<HttpException>()),
      );
    });
  });
}
