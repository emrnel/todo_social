import Badge from '../models/Badge.js';
import UserBadge from '../models/UserBadge.js';
import User from '../models/User.js';
import Notification from '../models/Notification.js';

/**
 * Check and award badges to a user based on their achievements
 */
export const checkAndAwardBadges = async (userId) => {
  try {
    const user = await User.findByPk(userId);
    if (!user) return;

    const allBadges = await Badge.findAll();
    const userBadges = await UserBadge.findAll({
      where: { userId },
      attributes: ['badgeId'],
    });

    const earnedBadgeIds = userBadges.map(ub => ub.badgeId);

    for (const badge of allBadges) {
      // Skip if user already has this badge
      if (earnedBadgeIds.includes(badge.id)) continue;

      let qualifies = false;

      // Check badge condition
      switch (badge.condition) {
        case 'todos_completed':
          qualifies = user.todosCompletedCount >= badge.threshold;
          break;
        case 'streak_days':
          qualifies = user.longestStreak >= badge.threshold;
          break;
        case 'followers_count':
          qualifies = user.followersCount >= badge.threshold;
          break;
        case 'xp':
          qualifies = user.xp >= badge.threshold;
          break;
        default:
          break;
      }

      // Award badge if qualified
      if (qualifies) {
        await UserBadge.create({
          userId,
          badgeId: badge.id,
        });

        // Create notification for badge earned
        await Notification.create({
          userId,
          type: 'badge_earned',
          badgeId: badge.id,
          message: `Tebrikler! "${badge.name}" rozetini kazandınız!`,
        });
      }
    }
  } catch (error) {
    console.error('Error checking and awarding badges:', error);
  }
};

/**
 * Get all badges
 */
export const getAllBadges = async (req, res) => {
  try {
    const badges = await Badge.findAll({
      order: [['threshold', 'ASC']],
    });

    res.json({
      success: true,
      data: badges,
    });
  } catch (error) {
    console.error('Error fetching badges:', error);
    res.status(500).json({
      success: false,
      message: 'Rozetler alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Get user's badges
 */
export const getUserBadges = async (req, res) => {
  try {
    const { userId } = req.params;

    const userBadges = await UserBadge.findAll({
      where: { userId },
      include: [
        {
          model: Badge,
          as: 'badge',
        },
      ],
      order: [['earnedAt', 'DESC']],
    });

    res.json({
      success: true,
      data: userBadges,
    });
  } catch (error) {
    console.error('Error fetching user badges:', error);
    res.status(500).json({
      success: false,
      message: 'Kullanıcı rozetleri alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Get my badges
 */
export const getMyBadges = async (req, res) => {
  try {
    const userId = req.user.id;

    const userBadges = await UserBadge.findAll({
      where: { userId },
      include: [
        {
          model: Badge,
          as: 'badge',
        },
      ],
      order: [['earnedAt', 'DESC']],
    });

    res.json({
      success: true,
      data: userBadges,
    });
  } catch (error) {
    console.error('Error fetching my badges:', error);
    res.status(500).json({
      success: false,
      message: 'Rozetleriniz alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};
