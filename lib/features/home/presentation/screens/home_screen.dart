import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/auth/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ana Sayfa (Todo Social)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // AuthProvider üzerinden çıkış yap
              ref.read(authProvider.notifier).logout();
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Giriş Başarılı! Burası Ana Sayfa."),
      ),
    );
  }
}
