// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/navigation/app_router.dart';
import 'package:todo_social/core/theme/app_theme.dart';

// Root widget now reads the GoRouter from Riverpod and provides it to
// the MaterialApp.router so `GoRouter.of(context)` is available.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Todo Social',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Provide the GoRouter to MaterialApp
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
