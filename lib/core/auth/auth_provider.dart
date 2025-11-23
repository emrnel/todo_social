import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'package:todo_social/core/auth/auth_state.dart';

/// StateNotifier that manages the global authentication state.
/// It initializes by reading the token from StorageService and
/// updates the state to `authenticated` or `unauthenticated`.
class AuthStateNotifier extends StateNotifier<AuthState> {
  final StorageService _storageService;

  AuthStateNotifier(this._storageService) : super(AuthState.unknown) {
    _init();
  }

  Future<void> _init() async {
    final token = await _storageService.readToken();
    if (token != null) {
      state = AuthState.authenticated;
    } else {
      state = AuthState.unauthenticated;
    }
  }

  /// Forces authenticated state (useful after login)
  void setAuthenticated() => state = AuthState.authenticated;

  /// Forces unauthenticated state (useful after logout)
  void setUnauthenticated() => state = AuthState.unauthenticated;
}

/// Global provider exposing the current [AuthState].
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthStateNotifier(storage);
});
