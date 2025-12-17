import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/social/presentation/providers/social_provider.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/features/user/data/repositories/user_repository.dart';

final userProfileProvider =
    FutureProvider.family<dynamic, String>((ref, username) async {
  final dio = ref.watch(apiServiceProvider);
  final repository = UserRepository(dio);
  return await repository.getUserProfile(username);
});

class UserProfileScreen extends ConsumerWidget {
  final String? username;

  const UserProfileScreen({super.key, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If username is null, this is "My Profile" - redirect or show current user's profile
    final usernameToFetch =
        username ?? 'me'; // 'me' için özel handling gerekebilir

    if (username == null) {
      // "My Profile" için farklı bir provider kullanabilirsiniz
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: const Center(child: Text('My Profile - Not implemented yet')),
      );
    }

    final profileAsync = ref.watch(userProfileProvider(usernameToFetch));

    return Scaffold(
      appBar: AppBar(
        title: Text('@$usernameToFetch'),
      ),
      body: profileAsync.when(
        data: (profileData) {
          final user = profileData.user;
          final publicTodos = profileData.publicTodos;
          final isFollowing = profileData.isFollowing;
          final followerCount = user.followerCount ?? 0;
          final followingCount = user.followingCount ?? 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.teal,
                            child: Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatItem('Takipçi', followerCount),
                          const SizedBox(width: 24),
                          _buildStatItem('Takip', followingCount),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(socialProvider.notifier)
                                  .toggleFollow(user.id, isFollowing);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isFollowing ? Colors.grey : Colors.teal,
                            ),
                            child: Text(
                              isFollowing ? 'Takipten Çık' : 'Takip Et',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Public Todos Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Herkese Açık Görevler (${publicTodos.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (publicTodos.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Henüz herkese açık görev yok',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: publicTodos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final todo = publicTodos[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  todo.isCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: todo.isCompleted
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                title: Text(
                                  todo.title,
                                  style: TextStyle(
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: todo.description != null &&
                                        todo.description!.isNotEmpty
                                    ? Text(todo.description!)
                                    : null,
                                trailing: Text(
                                  _formatDate(todo.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(userProfileProvider(usernameToFetch)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }
}
