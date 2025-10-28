import 'package:flutter/material.dart';
// Placeholder Login Screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(
        child: Text('Login Screen Placeholder'),
      ),
      // We will add text fields and a button here later
    );
  }
}
