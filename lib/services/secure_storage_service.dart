import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyName = 'ideogram_api_key';

  Future<void> writeApiKey(String apiKey) async {
    await _storage.write(key: _keyName, value: apiKey);
  }

  Future<String?> readApiKey() => _storage.read(key: _keyName);

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyName);
  }
}
