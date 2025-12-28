import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/gamification/providers/statistics_provider.dart';
import 'package:todo_social/features/gamification/widgets/xp_progress_bar.dart';
import 'package:todo_social/features/gamification/widgets/streak_counter.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(myStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistiklerim'),
      ),
      body: statisticsAsync.when(
        data: (statistics) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myStatisticsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // XP and Level
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.star, color: Colors.purple),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Seviye & XP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${statistics.user.xp} toplam XP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        XpProgressBar(userStats: statistics.user),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Streak
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StreakCounter(
                      currentStreak: statistics.user.currentStreak,
                      longestStreak: statistics.user.longestStreak,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Grid
                _buildStatsGrid(statistics),
                const SizedBox(height: 16),

                // Activity
                _buildActivitySection(statistics),
              ],
            ),
          ),
        ),
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
                onPressed: () => ref.invalidate(myStatisticsProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(statistics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Toplam Todo',
          statistics.stats.totalTodos.toString(),
          Icons.list_alt,
          Colors.blue,
        ),
        _buildStatCard(
          'Tamamlanan',
          statistics.stats.completedTodos.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Tamamlanma',
          '${statistics.stats.completionRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildStatCard(
          'Takipçi',
          statistics.user.followersCount.toString(),
          Icons.people,
          Colors.purple,
        ),
        _buildStatCard(
          'Alınan Beğeni',
          statistics.stats.likesReceived.toString(),
          Icons.favorite,
          Colors.red,
        ),
        _buildStatCard(
          'Alınan Yorum',
          statistics.stats.commentsReceived.toString(),
          Icons.comment,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(statistics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivite',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityRow(
              'Bu hafta tamamlanan',
              statistics.stats.weeklyCompletedTodos.toString(),
              Colors.blue,
            ),
            const Divider(),
            _buildActivityRow(
              'Bu ay tamamlanan',
              statistics.stats.monthlyCompletedTodos.toString(),
              Colors.green,
            ),
            if (statistics.stats.mostProductiveDay != null) ...[
              const Divider(),
              _buildActivityRow(
                'En produktif gün',
                statistics.stats.mostProductiveDay!,
                Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
