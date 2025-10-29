import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Geçici olarak bu şekilde, gerçeğini implemente ederseniz.
// (App router hata vermesin diye) - Emre Senel

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Kayıt Ekranı"),
            // Register'dan Login'e dönüşü sağla
            TextButton(
              onPressed: () => context.pop(), // Geri dön
              child: const Text("Zaten hesabın var mı? Giriş yap"),
            ),
          ],
        ),
      ),
    );
  }
}
