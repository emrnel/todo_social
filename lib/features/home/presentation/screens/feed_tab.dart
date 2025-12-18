import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/feed/presentation/providers/feed_provider.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_social/features/social/presentation/providers/social_provider.dart';

enum FeedFilter { following, discover }

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  bool _loaded = false;
  FeedFilter _currentFilter = FeedFilter.discover; // Default to discover

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() {
        ref.read(feedProvider.notifier).fetchFeed();
        ref.read(socialProvider.notifier).fetchFollowingUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Column(
      children: [
        // Filter Segmented Button
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

        // Feed Content
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

    // Filter based on current filter mode
    final socialState = ref.watch(socialProvider);
    final authState = ref.watch(authProvider);
    final currentUserId = authState.currentUser?.id;

    final filteredItems = state.feedItems.where((item) {
      // Don't show current user's items
      if (currentUserId != null && item.userId == currentUserId) {
        return false;
      }

      // For following mode, only show items from followed users
      if (_currentFilter == FeedFilter.following) {
        return socialState.followingUserIds.contains(item.userId);
      }

      // For discover mode, show all public items
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
            elevation: 2,
            color: isTodo ? null : Colors.green.shade50,
            child: InkWell(
              onTap: () {
                // Navigate to user profile
                context.push(Routes.userProfilePath(item.username));
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isTodo ? Colors.teal : Colors.green,
                          child: Text(
                            item.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 12),
                    // Content
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
                    if (item.description != null &&
                        item.description!.isNotEmpty)
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
                  ],
                ),
              ),
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
