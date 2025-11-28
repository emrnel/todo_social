// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/auth/auth_provider.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/core/auth/auth_state.dart';

// Import screens
import 'package:todo_social/features/splash/presentation/screens/splash_screen.dart';
import 'package:todo_social/features/auth/presentation/screens/login_screen.dart';
import 'package:todo_social/features/auth/presentation/screens/register_screen.dart';
import 'package:todo_social/features/home/presentation/screens/home_screen.dart';
import 'package:todo_social/features/social/presentation/screens/user_profile_screen.dart';
import 'package:todo_social/features/social/presentation/screens/search_screen.dart';
import 'package:todo_social/features/todo/presentation/screens/add_todo_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // FE-CORE-39: Update myProfile to use UserProfileScreen with null username
      GoRoute(
        path: Routes.myProfile,
        builder: (context, state) => const UserProfileScreen(username: null),
      ),
      GoRoute(
        path: Routes.addTodo,
        builder: (context, state) => const AddTodoScreen(),
      ),
      // FE-CORE-33: Add search route
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      // FE-CORE-36, FE-CORE-37, FE-CORE-38: Add userProfile dynamic route
      GoRoute(
        path: Routes.userProfile,
        builder: (context, state) {
          // FE-CORE-37: Get username from path parameters
          final username = state.pathParameters['username'];

          // FE-CORE-38: Call UserProfileScreen with username
          return UserProfileScreen(username: username);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final currentLocation = state.matchedLocation;

      if (authState == AuthState.unknown) {
        return currentLocation == Routes.splash ? null : Routes.splash;
      }

      if (authState == AuthState.unauthenticated) {
        if (currentLocation == Routes.login ||
            currentLocation == Routes.register) {
          return null;
        }
        return Routes.login;
      }

      if (authState == AuthState.authenticated) {
        if (currentLocation == Routes.splash ||
            currentLocation == Routes.login ||
            currentLocation == Routes.register) {
          return Routes.home;
        }
        return null;
      }

      return null;
    },
  );
});
