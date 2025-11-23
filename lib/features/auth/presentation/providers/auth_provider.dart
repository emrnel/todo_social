import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/data/models/user_model.dart';
import 'package:todo_social/features/auth/data/repositories/auth_repository.dart';
import 'package:todo_social/core/services/storage_service.dart';

/// State class for authentication provider.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? currentUser;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? currentUser,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

/// StateNotifier for authentication logic.
class AuthProvider extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final StorageService storageService;

  AuthProvider({required this.authRepository, required this.storageService}) : super(AuthState());

  /// Logs in the user using repository and saves token on success.
  Future<void> loginUser({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await authRepository.login(email: email, password: password);

      if (resp.token != null && resp.user != null) {
        // Save token using repository helper which uses StorageService
        await authRepository.saveToken(resp.token!, storageService);
        state = state.copyWith(isLoading: false, currentUser: resp.user, errorMessage: null);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: resp.message.isNotEmpty ? resp.message : 'Login failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Registers a new user and stores token on success.
  Future<void> registerUser({required String username, required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await authRepository.register(username: username, email: email, password: password);

      if (resp.token != null && resp.user != null) {
        await authRepository.saveToken(resp.token!, storageService);
        state = state.copyWith(isLoading: false, currentUser: resp.user, errorMessage: null);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: resp.message.isNotEmpty ? resp.message : 'Registration failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Logs out the user by clearing token and resetting state.
  Future<void> logoutUser() async {
    await storageService.deleteToken();
    state = AuthState();
  }
}
