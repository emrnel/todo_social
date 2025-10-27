// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/auth/auth_provider.dart';
import 'package:todo_social/core/navigation/routes.dart';

// Ekranları import et (Henüz olmasalar da)
import 'package:todo_social/features/splash/presentation/screens/splash_screen.dart';
import 'package:todo_social/features/auth/presentation/screens/login_screen.dart';
import 'package:todo_social/features/auth/presentation/screens/register_screen.dart';
import 'package:todo_social/features/home/presentation/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Yönlendirme mantığı için AuthProvider'ı dinle
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      // 1. Splash Ekranı
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // 2. Auth Ekranları
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      // 3. Ana Ekran
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    // 4. YÖNLENDİRME (SENİN GÖREVİNİN EN KRİTİK KISMI)
    redirect: (BuildContext context, GoRouterState state) {
      final currentLocation = state.matchedLocation;

      // Durum 1: Uygulama daha ne olduğunu bilmiyor (unknown)
      if (authState == AuthState.unknown) {
        // Splash'te değilse Splash'e yolla, orası durumu belirleyecek
        return currentLocation == Routes.splash ? null : Routes.splash;
      }

      // Durum 2: Kullanıcı giriş yapmamış (unauthenticated)
      if (authState == AuthState.unauthenticated) {
        // Login veya Register ekranındaysa dokunma
        if (currentLocation == Routes.login ||
            currentLocation == Routes.register) {
          return null;
        }
        // Başka bir yerdeyse (örn: /home'a gitmeye çalıştı) Login'e yolla
        return Routes.login;
      }

      // Durum 3: Kullanıcı giriş yapmış (authenticated)
      if (authState == AuthState.authenticated) {
        // Splash, Login veya Register ekranındaysa Ana Sayfaya yolla
        if (currentLocation == Routes.splash ||
            currentLocation == Routes.login ||
            currentLocation == Routes.register) {
          return Routes.home;
        }
        // Zaten /home veya altındaysa dokunma
        return null;
      }

      // Varsayılan olarak hiçbir şey yapma
      return null;
    },
  );
});
