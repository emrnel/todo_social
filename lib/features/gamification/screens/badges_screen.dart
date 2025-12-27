import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/gamification/providers/badge_provider.dart';
import 'package:todo_social/features/gamification/widgets/badge_widget.dart';
import 'package:todo_social/data/models/badge_model.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBadgesAsync = ref.watch(myBadgesProvider);
    final allBadgesAsync = ref.watch(allBadgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozetler'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Kazandıklarım'),
                Tab(text: 'Tümü'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // My Badges Tab
                  myBadgesAsync.when(
                    data: (badges) => RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(myBadgesProvider);
                      },
                      child: badges.isEmpty
                          ? _buildEmptyState()
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: BadgeGridView(
                                badges: badges,
                                showDescription: true,
                              ),
                            ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Hata: $error')),
                  ),

                  // All Badges Tab
                  allBadgesAsync.when(
                    data: (badges) => RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(allBadgesProvider);
                        ref.invalidate(myBadgesProvider);
                      },
                      child: myBadgesAsync.when(
                        data: (myBadges) {
                          final myBadgeIds = myBadges.map((b) => b.id).toSet();
                          final badgesWithStatus = badges.map((badge) {
                            return BadgeModel(
                              id: badge.id,
                              name: badge.name,
                              description: badge.description,
                              icon: badge.icon,
                              condition: badge.condition,
                              threshold: badge.threshold,
                              tier: badge.tier,
                              earnedAt: myBadgeIds.contains(badge.id)
                                  ? DateTime.now()
                                  : null,
                            );
                          }).toList();

                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: badgesWithStatus.length,
                              itemBuilder: (context, index) {
                                final badge = badgesWithStatus[index];
                                return BadgeWidget(
                                  badge: badge,
                                  isEarned: badge.earnedAt != null,
                                  showDescription: true,
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: BadgeGridView(badges: badges, showDescription: true),
                        ),
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Hata: $error')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🏆',
            style: TextStyle(fontSize: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz rozet kazanılmadı',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todolarını tamamla ve rozetler kazan!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
