import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/data/models/user_model.dart';
import 'package:todo_social/features/auth/data/repositories/auth_repository.dart';
import 'package:todo_social/core/services/storage_service.dart';

/// State class for authentication provider.
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? currentUser;
  final bool initialized;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
    this.initialized = false,
  });

  /// Returns true if user is authenticated (has currentUser).
  bool get authenticated => currentUser != null;

  /// Returns true if user is NOT authenticated after initialization.
  bool get unauthenticated => initialized && currentUser == null;

  /// Returns unknown state before an auth check completes.
  bool get unknown => !initialized;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? currentUser,
    bool? initialized,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentUser: currentUser ?? this.currentUser,
      initialized: initialized ?? this.initialized,
    );
  }
}

/// StateNotifier for authentication logic.
class AuthProvider extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final StorageService storageService;

  AuthProvider({required this.authRepository, required this.storageService})
      : super(AuthState());

  /// Logs in the user using repository and saves token on success.
  Future<void> loginUser(
      {required String email, required String password}) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearError: true);
    try {
      final resp = await authRepository.login(email: email, password: password);

      if (resp.token != null && resp.user != null) {
        // Save token using repository helper which uses StorageService
        await authRepository.saveToken(resp.token!, storageService);
        state = state.copyWith(
          isLoading: false,
          currentUser: resp.user,
          errorMessage: null,
          initialized: true,
          clearError: true,
        );
      } else {
        state = state.copyWith(
            isLoading: false,
            initialized: true,
            errorMessage:
                resp.message.isNotEmpty ? resp.message : 'Login failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Registers a new user and stores token on success.
  Future<void> registerUser(
      {required String username,
      required String email,
      required String password}) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearError: true);
    try {
      final resp = await authRepository.register(
          username: username, email: email, password: password);

      if (resp.token != null && resp.user != null) {
        await authRepository.saveToken(resp.token!, storageService);
        state = state.copyWith(
          isLoading: false,
          currentUser: resp.user,
          errorMessage: null,
          initialized: true,
          clearError: true,
        );
      } else {
        state = state.copyWith(
            isLoading: false,
            initialized: true,
            errorMessage:
                resp.message.isNotEmpty ? resp.message : 'Registration failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Logs out the user by clearing token and resetting state.
  Future<void> logoutUser() async {
    await storageService.deleteToken();
    state = AuthState(initialized: true);
  }

  /// Marks user as authenticated with user data (used for splash screen after token verification).
  void setAuthenticatedWithUser(UserModel user) {
    state = state.copyWith(
      currentUser: user,
      isLoading: false,
      initialized: true,
      clearError: true,
    );
  }

  /// Marks user as authenticated (deprecated - use setAuthenticatedWithUser instead).
  @Deprecated('Use setAuthenticatedWithUser instead')
  void setAuthenticated() {
    state = state.copyWith(
      currentUser: state.currentUser,
      isLoading: false,
      initialized: true,
    );
  }

  /// Marks user as unauthenticated (used for splash screen when no token found).
  void setUnauthenticated() {
    state = AuthState(isLoading: false, currentUser: null, initialized: true);
  }
}

/// Riverpod provider for AuthProvider.
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthProvider(
      authRepository: authRepository, storageService: storageService);
});
