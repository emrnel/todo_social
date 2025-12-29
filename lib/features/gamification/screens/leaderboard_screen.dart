import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/features/gamification/providers/statistics_provider.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/core/widgets/profile_avatar.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _selectedType = 'xp';

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider(_selectedType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liderlik Tablosu'),
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildCategoryChip('XP', 'xp', Icons.star)),
                const SizedBox(width: 8),
                Expanded(child: _buildCategoryChip('Streak', 'streak', Icons.local_fire_department)),
                const SizedBox(width: 8),
                Expanded(child: _buildCategoryChip('Todolar', 'completed', Icons.check_circle)),
                const SizedBox(width: 8),
                Expanded(child: _buildCategoryChip('Takipçi', 'followers', Icons.people)),
              ],
            ),
          ),

          // Leaderboard List
          Expanded(
            child: leaderboardAsync.when(
              data: (users) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(leaderboardProvider(_selectedType));
                },
                child: users.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final rank = index + 1;
                          return _buildUserCard(user, rank);
                        },
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
                      onPressed: () => ref.invalidate(leaderboardProvider(_selectedType)),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value, IconData icon) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Column(
        children: [
          Icon(icon, size: 20, color: isSelected ? Colors.white : null),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildUserCard(user, int rank) {
    final currentUser = ref.watch(authProvider).currentUser;
    final isCurrentUser = currentUser != null && user.id == currentUser.id;

    final rankColor = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.grey[400]!
            : rank == 3
                ? Colors.brown
                : Colors.grey[300]!;

    String getValue() {
      switch (_selectedType) {
        case 'xp':
          return '${user.xp} XP';
        case 'streak':
          return '${user.currentStreak} 🔥';
        case 'completed':
          return '${user.todosCompletedCount} todo';
        case 'followers':
          return '${user.followersCount} takipçi';
        default:
          return '';
      }
    }

    return Card(
      elevation: rank <= 3 ? 4 : 1,
      child: ListTile(
        onTap: () {
          if (isCurrentUser) {
            context.push(Routes.myProfile);
          } else {
            context.push(Routes.userProfilePath(user.username));
          }
        },
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: rankColor,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (rank == 1)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '👑',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            // "Sen" badge for current user
            if (isCurrentUser) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sen',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lv ${user.level}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(getValue()),
        trailing: ProfileAvatar(
          profilePicture: user.profilePicture,
          username: user.username,
          radius: 20,
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
            'Henüz lider yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
