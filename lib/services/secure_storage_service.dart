import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving the Ideogram API key.
///
/// Uses platform-native secure storage mechanisms:
/// - Android: Encrypted shared preferences
/// - iOS/macOS: Keychain with first_unlock accessibility
class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyName = 'ideogram_api_key';

  /// Securely stores the API key in encrypted storage.
  Future<void> writeApiKey(String apiKey) async {
    await _storage.write(key: _keyName, value: apiKey);
  }

  /// Retrieves the stored API key, or null if not found.
  Future<String?> readApiKey() => _storage.read(key: _keyName);

  /// Permanently deletes the stored API key.
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyName);
  }
}
