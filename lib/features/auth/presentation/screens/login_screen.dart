import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/navigation/routes.dart';

// Geçici olarak bu şekilde, gerçeğini implemente ederseniz.
// (App router hata vermesin diye) - Emre Senel

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login Ekranı"),
            // Login'den Register'a geçişi sağla
            TextButton(
              onPressed: () => context.push(Routes.register),
              child: const Text("Hesabın yok mu? Kayıt ol"),
            ),
            // Simülasyon için:
            ElevatedButton(
                onPressed: () {
                  // TODO: Emre T.'nin (AUTH-2/3) login servisi çağrılacak
                  // ve authProvider.notifier.login("token") tetiklenecek
                },
                child: const Text("Giriş Yap"))
          ],
        ),
      ),
    );
  }
}
