// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';

// Placeholder Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Feed')),
      body: const Center(
        child: Text('Home Screen Placeholder'),
      ),
    );
  }
}
