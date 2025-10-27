// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/navigation/app_router.dart';
// TODO: Tema dosyalarını import et (lib/core/theme/app_theme.dart)

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Oluşturduğumuz router provider'ını 'watch' (izle)
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Todo Social',
      debugShowCheckedModeBanner: false,

      // Tema ayarları (Dosya yapından)
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,

      // GoRouter yapılandırması
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
