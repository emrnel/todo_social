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
import 'package:todo_social/core/theme/app_colors.dart';
import 'package:todo_social/features/social/presentation/widgets/comment_section.dart';
import 'package:todo_social/features/gamification/providers/badge_provider.dart';
import 'package:todo_social/features/gamification/widgets/badge_widget.dart';

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
                // User Header with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.15),
                        AppColors.primaryBlue.withOpacity(0.15),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          user.profilePicture != null &&
                                  user.profilePicture!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      NetworkImage(user.profilePicture!),
                                  backgroundColor: Colors.teal,
                                  onBackgroundImageError: (_, __) {},
                                )
                              : CircleAvatar(
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
                          Container(
                            decoration: BoxDecoration(
                              gradient: isFollowing ? null : AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              color: isFollowing ? Colors.grey.shade300 : null,
                            ),
                            child: ElevatedButton(
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
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: isFollowing ? Colors.grey.shade700 : Colors.white,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: Text(
                                isFollowing ? 'Takipten Çık' : 'Takip Et',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Gamification Stats
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Level, XP, and Streak
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.stars, color: Colors.white, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Level ${user.level}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${user.xp} XP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.currentStreak > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('🔥', style: TextStyle(fontSize: 16)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${user.currentStreak} gün',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Quick Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuickStat(
                                  Icons.check_circle,
                                  '${user.todosCompletedCount}',
                                  'Tamamlanan',
                                  Colors.green,
                                ),
                                _buildQuickStat(
                                  Icons.whatshot,
                                  '${user.longestStreak}',
                                  'En Uzun Seri',
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Badges Section
                Consumer(
                  builder: (context, ref, child) {
                    final badgesAsync = ref.watch(userBadgesProvider(user.id));
                    return badgesAsync.when(
                      data: (badges) {
                        if (badges.isEmpty) return const SizedBox.shrink();
                        final displayBadges = badges.take(6).toList();
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rozetler',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: displayBadges.length,
                                itemBuilder: (context, index) {
                                  return BadgeWidget(
                                    badge: displayBadges[index],
                                    isEarned: true,
                                    showDescription: false,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
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
                            (todo) => _buildTodoCard(todo, context, ref),
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
                                  .map((todo) => _buildTodoCard(todo, context, ref))
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

  Widget _buildTodoCard(PublicTodoModel todo, BuildContext context, WidgetRef ref) {
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
                    color: todo.isLiked ? AppColors.like : Colors.grey,
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
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
                if (todo.likeCount > 0)
                  InkWell(
                    onTap: () {
                      context.push(Routes.todoLikesPath(todo.id));
                    },
                    child: Text(
                      '${todo.likeCount} beğeni',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.copy, color: AppColors.share, size: 20),
                  onPressed: () async {
                    try {
                      await ref.read(todoProvider.notifier).copyTodo(todo.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Görev kopyalandı!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
                const Text('Kopyala', style: TextStyle(fontSize: 12)),
              ],
            ),

            // Comment section
            CommentSection(
              todoId: todo.id,
              initialCommentCount: todo.commentCount,
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

  Widget _buildQuickStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
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
          final publicTodos = (data['publicTodos'] as List?)
                  ?.map((e) => PublicTodoModel.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];

          // Separate completed and active todos
          final activeTodos =
              publicTodos.where((todo) => !todo.isCompleted).toList();
          final completedTodos =
              publicTodos.where((todo) => todo.isCompleted).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myProfileProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                // Profile Header with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.15),
                        AppColors.primaryBlue.withOpacity(0.15),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    children: [
                      user.profilePicture != null &&
                              user.profilePicture!.isNotEmpty
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(user.profilePicture!),
                              backgroundColor: Colors.teal,
                              onBackgroundImageError: (_, __) {},
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.teal,
                              child: Text(
                                user.username[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

                      const SizedBox(height: 20),

                      // Gamification Stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Level and XP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.stars, color: Colors.white, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Level ${user.level}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${user.xp} XP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                // Streak
                                if (user.currentStreak > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('🔥', style: TextStyle(fontSize: 16)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${user.currentStreak} gün',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // XP Progress Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level ${user.level + 1}\'e ${_xpForNextLevel(user.xp, user.level)} XP kaldı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _calculateXpProgress(user.xp, user.level),
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Quick Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuickStat(
                                  Icons.check_circle,
                                  '${user.todosCompletedCount}',
                                  'Tamamlanan',
                                  Colors.green,
                                ),
                                _buildQuickStat(
                                  Icons.whatshot,
                                  '${user.longestStreak}',
                                  'En Uzun Seri',
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Badges Section
                Consumer(
                  builder: (context, ref, child) {
                    final badgesAsync = ref.watch(myBadgesProvider);
                    return badgesAsync.when(
                      data: (badges) {
                        if (badges.isEmpty) return const SizedBox.shrink();
                        final displayBadges = badges.take(6).toList();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Rozetler',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(Routes.badges),
                                    child: const Text('Tümünü Gör'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: displayBadges.length,
                                itemBuilder: (context, index) {
                                  return BadgeWidget(
                                    badge: displayBadges[index],
                                    isEarned: true,
                                    showDescription: false,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),

                // Action Buttons Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(Routes.statistics),
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('İstatistikler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(Routes.badges),
                          icon: const Icon(Icons.emoji_events),
                          label: const Text('Rozetler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

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

                const SizedBox(height: 24),

                // Public Todos Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        ...activeTodos
                            .map((todo) => _buildMyTodoCard(todo, context, ref)),
                      ],

                      // Completed todos - always show section
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.grey.shade100,
                        child: ExpansionTile(
                          leading: const Icon(Icons.check_circle,
                              color: Colors.green),
                          title: Text(
                            'Tamamlananlar (${completedTodos.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: completedTodos.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Henüz herkese açık tamamlanmış görev yok',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                ]
                              : completedTodos
                                  .map((todo) => _buildMyTodoCard(todo, context, ref))
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                ],
              ),
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

  Widget _buildMyTodoCard(PublicTodoModel todo, BuildContext context, WidgetRef ref) {
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
            // Like count (no interactive buttons on own profile)
            if (todo.likeCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${todo.likeCount} beğeni',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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

  double _calculateXpProgress(int xp, int level) {
    final currentLevelXp = (level - 1) * (level - 1) * 100;
    final nextLevelXp = level * level * 100;
    final progressInLevel = xp - currentLevelXp;
    final xpNeededForLevel = nextLevelXp - currentLevelXp;
    return (progressInLevel / xpNeededForLevel).clamp(0.0, 1.0);
  }

  int _xpForNextLevel(int xp, int level) {
    final nextLevelXp = level * level * 100;
    return nextLevelXp - xp;
  }

  Widget _buildQuickStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
