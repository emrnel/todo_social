import 'package:flutter/material.dart';
import 'package:todo_social/data/models/badge_model.dart';

class BadgeWidget extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final bool showDescription;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.isEarned = true,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isEarned ? _getTierColor().withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned ? _getTierColor().withOpacity(0.3) : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.icon ?? '🏆',
            style: TextStyle(
              fontSize: 28,
              color: isEarned ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isEarned ? Colors.black87 : Colors.grey[600],
            ),
          ),
          if (showDescription) ...[
            const SizedBox(height: 4),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (badge.tier != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getTierColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge.tier!,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTierColor() {
    switch (badge.tier?.toLowerCase()) {
      case 'platinum':
        return Colors.purple;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey[600]!;
      case 'bronze':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }
}

class BadgeGridView extends StatelessWidget {
  final List<BadgeModel> badges;
  final bool showDescription;

  const BadgeGridView({
    super.key,
    required this.badges,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🏆',
                style: TextStyle(fontSize: 48, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz rozet kazanılmadı',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return BadgeWidget(
          badge: badges[index],
          isEarned: badges[index].earnedAt != null,
          showDescription: showDescription,
        );
      },
    );
  }
}
