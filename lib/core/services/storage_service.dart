import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final _storage = const FlutterSecureStorage();

  // Save token securely
  Future<void> writeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Read token from secure storage
  Future<String?> readToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Delete token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}
