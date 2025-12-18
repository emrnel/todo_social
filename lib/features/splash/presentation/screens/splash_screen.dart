// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/features/user/data/repositories/user_repository.dart';
import 'dart:developer' as developer;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Simulate a short delay for splash effect
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Read token from secure storage
      final token = await ref.read(storageServiceProvider).readToken();

      if (!mounted) return;

      // If token exists, verify it by fetching user profile
      if (token != null) {
        try {
          final dio = ref.read(apiServiceProvider);
          final userRepository = UserRepository(dio);
          final currentUser = await userRepository.getMyProfile();

          if (!mounted) return;

          // Set authenticated with user data
          ref.read(authProvider.notifier).setAuthenticatedWithUser(currentUser);
          context.go('/home');
        } catch (e) {
          developer.log('Token validation failed: $e', name: 'SplashScreen');

          // Token is invalid, clear it
          await ref.read(storageServiceProvider).deleteToken();

          if (!mounted) return;
          ref.read(authProvider.notifier).setUnauthenticated();
          context.go('/login');
        }
      } else {
        // No token, set unauthenticated state
        ref.read(authProvider.notifier).setUnauthenticated();
        context.go('/login');
      }
    } catch (e) {
      developer.log('Splash error: $e', name: 'SplashScreen');
      if (!mounted) return;

      ref.read(authProvider.notifier).setUnauthenticated();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
