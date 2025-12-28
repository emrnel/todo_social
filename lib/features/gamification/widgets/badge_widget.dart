import 'package:flutter/material.dart';
import 'package:todo_social/data/models/badge_model.dart';

class BadgeWidget extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final bool showDescription;
  final bool compact;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.isEarned = true,
    this.showDescription = false,
    this.compact = false,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust sizes based on compact mode and available space
          final double iconSize = compact ? 28 : 22;
          final double nameSize = compact ? 11 : 9;
          final double descSize = compact ? 9 : 8;
          final double tierSize = compact ? 8 : 7;
          final double spacing = compact ? 4 : 2;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    badge.icon ?? '🏆',
                    style: TextStyle(
                      fontSize: iconSize,
                      color: isEarned ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Flexible(
                flex: 2,
                child: Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.bold,
                    color: isEarned ? Colors.black87 : Colors.grey[600],
                    height: 1.1,
                  ),
                ),
              ),
              if (showDescription) ...[
                SizedBox(height: spacing / 2),
                Flexible(
                  child: Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: descSize,
                      color: Colors.grey[600],
                      height: 1.1,
                    ),
                  ),
                ),
              ],
              if (badge.tier != null) ...[
                SizedBox(height: spacing),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 4,
                    vertical: compact ? 2 : 1,
                  ),
                  decoration: BoxDecoration(
                    color: _getTierColor(),
                    borderRadius: BorderRadius.circular(compact ? 8 : 6),
                  ),
                  child: Text(
                    badge.tier!,
                    style: TextStyle(
                      fontSize: tierSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: showDescription ? 0.7 : 0.85,
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
