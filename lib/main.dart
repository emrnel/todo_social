// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Riverpod'ı tüm uygulama genelinde aktif et
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
