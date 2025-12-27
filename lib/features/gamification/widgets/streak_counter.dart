import 'package:flutter/material.dart';

class StreakCounter extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool compact;

  const StreakCounter({
    super.key,
    required this.currentStreak,
    this.longestStreak = 0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView();
    }
    return _buildFullView();
  }

  Widget _buildCompactView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStreakColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStreakColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            '$currentStreak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getStreakColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStreakColor().withOpacity(0.1),
            _getStreakColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStreakColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔥',
                style: TextStyle(
                  fontSize: currentStreak > 0 ? 40 : 30,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: _getStreakColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            currentStreak == 0
                ? 'Henüz streak yok'
                : currentStreak == 1
                    ? '1 gündür devam ediyor!'
                    : '$currentStreak gündür devam ediyor!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (longestStreak > 0) ...[
            const SizedBox(height: 8),
            Text(
              'En uzun: $longestStreak gün',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStreakColor() {
    if (currentStreak == 0) return Colors.grey;
    if (currentStreak >= 30) return Colors.purple;
    if (currentStreak >= 14) return Colors.deepOrange;
    if (currentStreak >= 7) return Colors.orange;
    return Colors.blue;
  }
}
