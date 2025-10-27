// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran yüklendiğinde auth durumunu kontrol etmeyi tetikle
    // Not: AuthProvider'ı 'read' ile çağırıyoruz çünkü state değişince
    // router bizi zaten yönlendirecek, burada build'in tekrar tetiklenmesine gerek yok.
    ref.read(authProvider.notifier).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    // Sadece bir yüklenme ekranı göster
    // AuthProvider'ın state'i değiştiği an GoRouter bizi yönlendirecek.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
