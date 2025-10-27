// lib/core/services/storage_service.dart
// BU DOSYA MUHAMMED'İN (CORE-2). Sadece bağımlılığımızı bilmek için.
// flutter_secure_storage kullanacak.

abstract class IStorageService {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

// Gerçek implementasyonu Muhammed yapacak, (Null dönüyorum)
class StorageService implements IStorageService {
  // ... Muhammed'in kodu
  @override
  Future<String?> getToken() async {
    // TODO: Implement using flutter_secure_storage
    return null;
  }

  @override
  Future<void> saveToken(String token) async {
    // TODO: Implement
  }

  @override
  Future<void> deleteToken() async {
    // TODO: Implement
  }
}
