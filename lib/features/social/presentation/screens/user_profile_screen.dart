import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_social/features/social/presentation/providers/social_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String? username;

  const UserProfileScreen({super.key, this.username});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      if (widget.username != null) {
        Future.microtask(() => ref
            .read(socialProvider.notifier)
            .fetchUserProfile(widget.username!));
      } else {
        Future.microtask(
            () => ref.read(socialProvider.notifier).fetchMyProfile());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyProfile = widget.username == null;
    final socialState = ref.watch(socialProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isMyProfile
            ? (socialState.currentUser != null
                ? '@${socialState.currentUser!.username}'
                : 'My Profile')
            : '@${widget.username}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              if (!isMyProfile && socialState.userProfile != null) ...[
                Text('@${socialState.userProfile!.user.username}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${socialState.userProfile!.followerCount} followers'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(socialProvider.notifier).toggleFollow(),
                  child: Text(socialState.userProfile!.isFollowing
                      ? 'Unfollow'
                      : 'Follow'),
                ),
              ],
              if (isMyProfile)
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(storageServiceProvider).deleteToken();
                    ref.read(authProvider.notifier).setUnauthenticated();
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
      ),
    );
  }
}
