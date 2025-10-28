// lib/main.dart
// (This is your provided code - it is correct)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/app.dart'; // Imports app.dart

void main() {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Activate Riverpod for the entire application
  runApp(
    const ProviderScope(
      child: App(), // Runs the 'App' widget
    ),
  );
}
