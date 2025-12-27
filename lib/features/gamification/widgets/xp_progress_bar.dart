import 'package:flutter/material.dart';
import 'package:todo_social/data/models/statistics_model.dart';

class XpProgressBar extends StatelessWidget {
  final UserStats userStats;
  final bool showLabel;

  const XpProgressBar({
    super.key,
    required this.userStats,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final xpForCurrentLevel = userStats.getXpForCurrentLevel();
    final xpForNextLevel = userStats.getXpForNextLevel();
    final progress = userStats.getXpProgress().clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${userStats.level}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${userStats.xp - xpForCurrentLevel}/${xpForNextLevel - xpForCurrentLevel} XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getLevelColor(userStats.level),
            ),
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 20) return Colors.purple;
    if (level >= 15) return Colors.deepOrange;
    if (level >= 10) return Colors.orange;
    if (level >= 5) return Colors.blue;
    return Colors.green;
  }
}
