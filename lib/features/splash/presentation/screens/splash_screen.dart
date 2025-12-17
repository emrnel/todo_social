// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';

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
    await Future.delayed(const Duration(seconds: 2));

    // FE-CORE-13: Read token from secure storage
    final token = await ref.read(storageServiceProvider).readToken();

    if (!mounted) return;

    // FE-CORE-14: Update auth state based on token
    if (token != null) {
      // Token exists, set authenticated state
      ref.read(authProvider.notifier).setAuthenticated();
      context.go('/home');
    } else {
      // No token, set unauthenticated state
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
