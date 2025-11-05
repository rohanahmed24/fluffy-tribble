import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving API keys for multiple providers.
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

  // Legacy key name for backward compatibility
  static const String _legacyKeyName = 'ideogram_api_key';
  static const String _selectedProviderKey = 'selected_provider';

  /// Gets the storage key for a specific provider
  String _getProviderKey(String providerId) => 'api_key_$providerId';

  /// Securely stores an API key for a specific provider
  Future<void> writeProviderApiKey(String providerId, String apiKey) async {
    await _storage.write(key: _getProviderKey(providerId), value: apiKey);
  }

  /// Retrieves the stored API key for a specific provider
  Future<String?> readProviderApiKey(String providerId) async {
    final key = await _storage.read(key: _getProviderKey(providerId));

    // Backward compatibility: if looking for ideogram and not found, check legacy key
    if (key == null && providerId == 'ideogram') {
      return _storage.read(key: _legacyKeyName);
    }

    return key;
  }

  /// Permanently deletes the stored API key for a specific provider
  Future<void> deleteProviderApiKey(String providerId) async {
    await _storage.delete(key: _getProviderKey(providerId));
  }

  /// Stores the selected provider ID
  Future<void> setSelectedProvider(String providerId) async {
    await _storage.write(key: _selectedProviderKey, value: providerId);
  }

  /// Retrieves the selected provider ID
  Future<String?> getSelectedProvider() async {
    final provider = await _storage.read(key: _selectedProviderKey);

    // If no provider is selected, check if we have a legacy ideogram key
    if (provider == null) {
      final legacyKey = await _storage.read(key: _legacyKeyName);
      if (legacyKey != null) {
        return 'ideogram'; // Default to ideogram for backward compatibility
      }
    }

    return provider;
  }

  /// Get all stored API keys (returns map of providerId -> apiKey)
  Future<Map<String, String>> getAllApiKeys() async {
    final allKeys = await _storage.readAll();
    final apiKeys = <String, String>{};

    for (final entry in allKeys.entries) {
      if (entry.key.startsWith('api_key_')) {
        final providerId = entry.key.substring('api_key_'.length);
        apiKeys[providerId] = entry.value;
      } else if (entry.key == _legacyKeyName) {
        // Include legacy key as ideogram
        apiKeys['ideogram'] = entry.value;
      }
    }

    return apiKeys;
  }

  /// Migrate legacy API key to new format
  Future<void> migrateLegacyKey() async {
    final legacyKey = await _storage.read(key: _legacyKeyName);
    if (legacyKey != null) {
      // Copy to new format
      await writeProviderApiKey('ideogram', legacyKey);
      // Set ideogram as selected provider
      await setSelectedProvider('ideogram');
      // Delete legacy key
      await _storage.delete(key: _legacyKeyName);
    }
  }

  // Legacy methods for backward compatibility

  /// Securely stores the API key in encrypted storage (legacy - defaults to ideogram)
  @Deprecated('Use writeProviderApiKey instead')
  Future<void> writeApiKey(String apiKey) async {
    await writeProviderApiKey('ideogram', apiKey);
  }

  /// Retrieves the stored API key, or null if not found (legacy - defaults to ideogram)
  @Deprecated('Use readProviderApiKey instead')
  Future<String?> readApiKey() => readProviderApiKey('ideogram');

  /// Permanently deletes the stored API key (legacy - defaults to ideogram)
  @Deprecated('Use deleteProviderApiKey instead')
  Future<void> deleteApiKey() async {
    await deleteProviderApiKey('ideogram');
  }
}
