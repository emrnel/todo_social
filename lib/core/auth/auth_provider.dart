// lib/core/auth/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
// import 'package:todo_social/core/services/storage_service.dart';

// 1. Auth Durumlarını Tanımla
enum AuthState {
  unknown, // Uygulama ilk açıldığında
  authenticated, // Giriş yapmış
  unauthenticated, // Giriş yapmamış
}

// 2. StateNotifier'ı Oluştur
class AuthNotifier extends StateNotifier<AuthState> {
  // CORE-2'deki servise bağımlıyız
  final IStorageService _storageService;

  AuthNotifier(this._storageService) : super(AuthState.unknown) {
    checkAuthStatus(); // Uygulama başlarken durumu kontrol et
  }

  // 3. Durumu Kontrol Eden Fonksiyon
  Future<void> checkAuthStatus() async {
    // Cihazdan token'ı oku
    final token = await _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      state = AuthState.authenticated;
    } else {
      state = AuthState.unauthenticated;
    }
  }

  // 4. Login ve Logout Fonksiyonları
  Future<void> login(String token) async {
    await _storageService.saveToken(token);
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    state = AuthState.unauthenticated;
  }
}

// 5. Riverpod Provider'ını Tanımla
// Dışarıdan bu provider'ı çağıracağız.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // TODO: StorageService provider'ını buraya bağla
  final storageService = StorageService(); // Şimdilik böyle
  return AuthNotifier(storageService);
});
