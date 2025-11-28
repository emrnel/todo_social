// lib/features/social/presentation/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/core/auth/auth_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  final String? username;

  const UserProfileScreen({super.key, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMyProfile = username == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMyProfile ? 'My Profile' : '@$username'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              isMyProfile ? 'My Profile' : '@$username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            if (isMyProfile)
              ElevatedButton.icon(
                // FE-CORE-29: Find the logout button onPressed
                onPressed: () async {
                  // FE-CORE-30: Delete token
                  await ref.read(storageServiceProvider).deleteToken();

                  // Update auth state
                  ref.read(authProvider.notifier).setUnauthenticated();

                  // FE-CORE-31: Navigate to login
                  if (context.mounted) {
                    context.go(Routes.login);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
