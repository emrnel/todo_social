import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/feed/presentation/providers/feed_provider.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_social/features/social/presentation/providers/social_provider.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';
import 'package:todo_social/core/theme/app_colors.dart';
import 'package:todo_social/features/social/presentation/widgets/comment_section.dart';

enum FeedFilter { following, discover }

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  bool _loaded = false;
  FeedFilter _currentFilter = FeedFilter.discover;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() async {
        await ref.read(feedProvider.notifier).fetchFeed();
        await ref.read(socialProvider.notifier).fetchFollowingUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<FeedFilter>(
            segments: const [
              ButtonSegment(
                value: FeedFilter.following,
                label: Text('Takip Ettiklerim'),
                icon: Icon(Icons.people),
              ),
              ButtonSegment(
                value: FeedFilter.discover,
                label: Text('Keşfet'),
                icon: Icon(Icons.explore),
              ),
            ],
            selected: {_currentFilter},
            onSelectionChanged: (Set<FeedFilter> newSelection) {
              setState(() {
                _currentFilter = newSelection.first;
              });
            },
          ),
        ),
        Expanded(
          child: _buildFeedContent(state),
        ),
      ],
    );
  }

  Widget _buildFeedContent(FeedState state) {
    if (state.isLoading && state.feedItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.feedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(feedProvider.notifier).fetchFeed(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final authState = ref.watch(authProvider);
    final socialState = ref.watch(socialProvider);
    final currentUserId = authState.currentUser?.id;
    final followingUserIds = socialState.followingUserIds;

    final filteredItems = state.feedItems.where((item) {
      if (currentUserId != null && item.userId == currentUserId) {
        return false;
      }

      if (_currentFilter == FeedFilter.following) {
        return followingUserIds.contains(item.userId);
      }

      return true;
    }).toList();

    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).fetchFeed(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          final isTodo = item.type == 'todo';

          return Card(
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info header
                InkWell(
                  onTap: () {
                    context.push(Routes.userProfilePath(item.username));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: isTodo
                                ? AppColors.primaryGradient
                                : AppColors.successGradient,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 20,
                            child: Text(
                              item.username[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '@${item.username}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isTodo ? Icons.check_box : Icons.repeat,
                                    size: 16,
                                    color: isTodo ? Colors.blue : Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isTodo ? 'Todo' : 'Routine',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatDate(item.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isTodo && item.isCompleted != null)
                          Icon(
                            item.isCompleted!
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color:
                                item.isCompleted! ? Colors.green : Colors.grey,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Category badge
                      if (item.category != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.category!.color != null
                                  ? Color(int.parse(item.category!.color!.replaceFirst('#', '0xFF')))
                                      .withOpacity(0.15)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.category!.icon != null)
                                  Text(item.category!.icon!, style: const TextStyle(fontSize: 14)),
                                if (item.category!.icon != null) const SizedBox(width: 4),
                                Text(
                                  item.category!.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item.category!.color != null
                                        ? Color(int.parse(item.category!.color!.replaceFirst('#', '0xFF')))
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: (isTodo && item.isCompleted == true)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (item.description != null && item.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            item.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      // Hashtags
                      if (item.hashtags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: item.hashtags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      // Show recurrence info for routines
                      if (!isTodo && item.recurrenceType != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tekrar: ${item.recurrenceType}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Action buttons for todos
                      if (isTodo) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            // Like button
                            IconButton(
                              icon: Icon(
                                item.isLiked == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: item.isLiked == true
                                    ? AppColors.like
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(feedProvider.notifier)
                                      .toggleLike(item.id);
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
                            if (item.likeCount != null && item.likeCount! > 0)
                              InkWell(
                                onTap: () {
                                  context.push(Routes.todoLikesPath(item.id));
                                },
                                child: Text(
                                  '${item.likeCount} beğeni',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // Copy button
                            IconButton(
                              icon: Icon(Icons.copy, color: AppColors.share),
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(todoProvider.notifier)
                                      .copyTodo(item.id);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Görev kopyalandı!'),
                                        backgroundColor: AppColors.success,
                                        duration: const Duration(seconds: 2),
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
                            const Text(
                              'Kopyala',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        // Comment section
                        CommentSection(
                          todoId: item.id,
                          initialCommentCount: item.commentCount ?? 0,
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentFilter == FeedFilter.following
                  ? Icons.people_outline
                  : Icons.explore_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _currentFilter == FeedFilter.following
                  ? 'Akışınız boş'
                  : 'Henüz keşfedecek bir şey yok',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == FeedFilter.following
                  ? 'Kullanıcıları takip etmeye başlayın'
                  : 'Kullanıcılar henüz public görev veya rutin paylaşmamış',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push(Routes.search);
              },
              icon: const Icon(Icons.search),
              label: const Text('Kullanıcı Ara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
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
}
