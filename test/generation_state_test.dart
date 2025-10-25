import 'package:flutter_test/flutter_test.dart';
import 'package:ideogram_secure_app/api/ideogram_api_client.dart';
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
      : super(baseUrl: 'https://example.com/images');

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
    test('updateApiKey trims, validates, and persists the key', () async {
      final storage = FakeSecureStorageService();
      final state = GenerationState(
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
      final state = GenerationState(client: client, storage: storage);

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

    test('generateImage updates images on success', () async {
      final storage = FakeSecureStorageService();
      final client = FakeIdeogramApiClient(const [
        GeneratedImage(id: '1', url: 'https://example.com/1.png'),
      ]);
      final state = GenerationState(client: client, storage: storage);

      await state.updateApiKey('test-key');
      await state.generateImage(
        prompt: 'prompt',
        style: ImageStyle.photorealistic,
      );

      expect(state.images, hasLength(1));
      expect(state.images.first.url, 'https://example.com/1.png');
      expect(state.error, isNull);
    });

    test('importKeyFromJson handles malformed payloads gracefully', () async {
      final storage = FakeSecureStorageService();
      final state = GenerationState(
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
