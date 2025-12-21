import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/data/models/user_model.dart';
import 'package:todo_social/features/social/presentation/providers/social_provider.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/features/user/data/repositories/user_repository.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/feed/presentation/providers/feed_provider.dart';
import 'package:todo_social/features/social/presentation/screens/edit_profile_screen.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';
import 'package:todo_social/features/user/data/models/public_todo_model.dart';

final userProfileProvider =
    FutureProvider.family<dynamic, String>((ref, username) async {
  final dio = ref.watch(apiServiceProvider);
  final repository = UserRepository(dio);
  return await repository.getUserProfile(username);
});

final myProfileProvider = FutureProvider<dynamic>((ref) async {
  final dio = ref.watch(apiServiceProvider);
  final repository = UserRepository(dio);
  return await repository.getMyProfile();
});

class UserProfileScreen extends ConsumerStatefulWidget {
  final String? username;

  const UserProfileScreen({super.key, this.username});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.username != null) {
        ref.invalidate(userProfileProvider(widget.username!));
      } else {
        ref.invalidate(myProfileProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.username == null) {
      return const _MyProfileScreen();
    }

    final usernameToFetch = widget.username!;
    final profileAsync = ref.watch(userProfileProvider(usernameToFetch));

    return Scaffold(
      appBar: AppBar(
        title: Text('@$usernameToFetch'),
      ),
      body: profileAsync.when(
        data: (profileData) {
          final user = profileData.user;
          final publicTodos = profileData.publicTodos as List<PublicTodoModel>;
          final isFollowing = profileData.isFollowing;
          final followerCount = profileData.followerCount;
          final followingCount = profileData.followingCount;

          // Separate completed and active todos - FIX: Type casting
          final activeTodos = publicTodos
              .where((PublicTodoModel todo) => !todo.isCompleted)
              .toList();
          final completedTodos = publicTodos
              .where((PublicTodoModel todo) => todo.isCompleted)
              .toList();

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
                            backgroundImage: user.profilePicture != null &&
                                    user.profilePicture!.isNotEmpty
                                ? NetworkImage(user.profilePicture!)
                                : null,
                            backgroundColor: Colors.teal,
                            onBackgroundImageError: (_, __) {},
                            child: user.profilePicture == null ||
                                    user.profilePicture!.isEmpty
                                ? Text(
                                    user.username[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
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
                                if (user.email != null)
                                  Text(
                                    user.email!,
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
                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          user.bio!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatItem('Takipçi', followerCount),
                          const SizedBox(width: 24),
                          _buildStatItem('Takip', followingCount),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              final dio = ref.read(apiServiceProvider);
                              final repository = UserRepository(dio);

                              try {
                                if (isFollowing) {
                                  await repository.unfollowUser(user.id);
                                } else {
                                  await repository.followUser(user.id);
                                }

                                ref.invalidate(
                                    userProfileProvider(usernameToFetch));

                                await ref
                                    .read(socialProvider.notifier)
                                    .fetchFollowingUsers();

                                ref.read(feedProvider.notifier).fetchFeed();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Hata: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
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
                      else ...[
                        // Active todos
                        if (activeTodos.isNotEmpty) ...[
                          const Text(
                            'Aktif Görevler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...activeTodos.map(
                            (todo) => _buildTodoCard(todo, context),
                          ),
                        ],

                        // Completed todos
                        if (completedTodos.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.grey.shade100,
                            child: ExpansionTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              title: Text(
                                'Tamamlananlar (${completedTodos.length})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              children: completedTodos
                                  .map((todo) => _buildTodoCard(todo, context))
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
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
                    ref.invalidate(userProfileProvider(usernameToFetch)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoCard(PublicTodoModel todo, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  todo.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: todo.isCompleted ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (todo.description != null &&
                          todo.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            todo.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      // Show "from username" if copied
                      if (todo.originalAuthor != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: InkWell(
                            onTap: () {
                              final username = todo.originalAuthor!['username'];
                              if (username != null) {
                                context.push(Routes.userProfilePath(username));
                              }
                            },
                            child: Text(
                              'from @${todo.originalAuthor!['username']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(todo.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            // Like and copy buttons
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    todo.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: todo.isLiked ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () async {
                    try {
                      await ref.read(todoProvider.notifier).toggleLike(todo.id);
                      ref.invalidate(userProfileProvider(widget.username!));
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                if (todo.likeCount > 0)
                  Text(
                    '${todo.likeCount}',
                    style: const TextStyle(fontSize: 12),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue, size: 20),
                  onPressed: () async {
                    try {
                      await ref.read(todoProvider.notifier).copyTodo(todo.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Görev kopyalandı!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                const Text('Kopyala', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
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

// My Profile Screen - ENHANCED VERSION
class _MyProfileScreen extends ConsumerWidget {
  const _MyProfileScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (data) {
          final user = data['user'] as UserModel;
          final followerCount = data['followerCount'] as int? ?? 0;
          final followingCount = data['followingCount'] as int? ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.teal.shade50,
                  width: double.infinity,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profilePicture != null &&
                                user.profilePicture!.isNotEmpty
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        backgroundColor: Colors.teal,
                        child: user.profilePicture == null ||
                                user.profilePicture!.isEmpty
                            ? Text(
                                user.username[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(height: 16),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.email != null)
                        Text(
                          user.email!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),

                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn('Takipçi', followerCount),
                          const SizedBox(width: 40),
                          _buildStatColumn('Takip', followingCount),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            currentBio: user.bio ?? '',
                            currentProfilePicture: user.profilePicture,
                          ),
                        ),
                      );

                      if (result == true) {
                        ref.invalidate(myProfileProvider);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Profili Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Çıkış Yap'),
                          content: const Text(
                              'Çıkış yapmak istediğinizden emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Çıkış Yap'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await ref.read(authProvider.notifier).logoutUser();
                        if (context.mounted) {
                          context.go(Routes.login);
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
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
                onPressed: () => ref.invalidate(myProfileProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 24,
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
}
