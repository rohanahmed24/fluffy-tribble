import 'package:flutter_test/flutter_test.dart';
import 'package:ideogram_secure_app/api/ideogram_api_client.dart';
import 'package:ideogram_secure_app/config/app_config.dart';
import 'package:ideogram_secure_app/services/secure_storage_service.dart';
import 'package:ideogram_secure_app/state/generation_state.dart';

class FakeSecureStorageService extends SecureStorageService {
  String? value;

  @override
  Future<void> writeApiKey(String apiKey) async {
    value = apiKey;
  }

  @override
  Future<String?> readApiKey() async => value;

  @override
  Future<void> deleteApiKey() async {
    value = null;
  }
}

class FakeIdeogramApiClient extends IdeogramApiClient {
  FakeIdeogramApiClient(this._images)
    : super(baseUri: Uri.parse('https://example.com/images'));

  final List<GeneratedImage> _images;
  bool wasCalled = false;

  @override
  Future<List<GeneratedImage>> generateImage({
    required String apiKey,
    required String prompt,
    required ImageStyle style,
    double aspectRatio = 1.0,
  }) async {
    wasCalled = true;
    return _images;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GenerationState', () {
    final config = AppConfig(
      baseUrl: Uri.parse('https://example.com/images'),
      requestTimeout: const Duration(seconds: 5),
    );

    test('updateApiKey trims, validates, and persists the key', () async {
      final storage = FakeSecureStorageService();
      final state = GenerationState(
        config: config,
        client: FakeIdeogramApiClient(const []),
        storage: storage,
      );

      await state.updateApiKey('  test-key  ');

      expect(state.apiKey, 'test-key');
      expect(storage.value, 'test-key');
      expect(state.error, isNull);
    });

    test('updateApiKey reports validation error for empty keys', () async {
      final storage = FakeSecureStorageService();
      final state = GenerationState(
        config: config,
        client: FakeIdeogramApiClient(const []),
        storage: storage,
      );

      await state.updateApiKey('   ');

      expect(state.apiKey, isNull);
      expect(state.error, 'API key cannot be empty.');
    });

    test('generateImage guards against empty prompt and missing key', () async {
      final storage = FakeSecureStorageService();
      final client = FakeIdeogramApiClient(const []);
      final state = GenerationState(
        config: config,
        client: client,
        storage: storage,
      );

      await state.generateImage(prompt: '', style: ImageStyle.cinematic);

      expect(state.error, 'Prompt cannot be empty.');
      expect(client.wasCalled, isFalse);

      await state.updateApiKey('test-key');
      await state.generateImage(
        prompt: 'valid prompt',
        style: ImageStyle.cinematic,
      );

      expect(client.wasCalled, isTrue);
    });

    test('generateImage validates aspect ratio bounds', () async {
      final storage = FakeSecureStorageService();
      final client = FakeIdeogramApiClient(const []);
      final state = GenerationState(
        config: config,
        client: client,
        storage: storage,
      );

      await state.updateApiKey('test-key');
      await state.generateImage(
        prompt: 'prompt',
        style: ImageStyle.photorealistic,
        aspectRatio: 10,
      );

      expect(state.error, 'Aspect ratio must be between 0.25 and 4.0.');
      expect(client.wasCalled, isFalse);
    });

    test('generateImage updates images on success', () async {
      final storage = FakeSecureStorageService();
      final client = FakeIdeogramApiClient(const [
        GeneratedImage(id: '1', url: 'https://example.com/1.png'),
      ]);
      final state = GenerationState(
        config: config,
        client: client,
        storage: storage,
      );

      await state.updateApiKey('test-key');
      await state.generateImage(
        prompt: 'prompt',
        style: ImageStyle.photorealistic,
      );

      expect(state.images, hasLength(1));
      expect(state.images.first.url, 'https://example.com/1.png');
      expect(state.error, isNull);
    });

    test('generateImage reports when no secure URLs are returned', () async {
      final storage = FakeSecureStorageService();
      final client = FakeIdeogramApiClient(const []);
      final state = GenerationState(
        config: config,
        client: client,
        storage: storage,
      );

      await state.updateApiKey('test-key');
      await state.generateImage(prompt: 'prompt', style: ImageStyle.cinematic);

      expect(state.images, isEmpty);
      expect(
        state.error,
        'No secure image URLs were returned. Try another prompt.',
      );
    });

    test('importKeyFromJson handles malformed payloads gracefully', () async {
      final storage = FakeSecureStorageService();
      final state = GenerationState(
        config: config,
        client: FakeIdeogramApiClient(const []),
        storage: storage,
      );

      await state.importKeyFromJson('{"wrong":"value"}');
      expect(state.error, 'Missing Ideogram API key');

      await state.importKeyFromJson('{"ideogramApiKey":"abc123"}');
      expect(state.apiKey, 'abc123');
      expect(state.error, isNull);
    });
  });
}
