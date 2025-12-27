import { Op } from 'sequelize';
import sequelize from '../db.js';
import User from '../models/User.js';
import Todo from '../models/Todo.js';
import Follow from '../models/Follow.js';

/**
 * Get user statistics dashboard
 */
export const getMyStatistics = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user data with aggregated stats
    const user = await User.findByPk(userId, {
      attributes: [
        'id',
        'username',
        'xp',
        'level',
        'currentStreak',
        'longestStreak',
        'todosCompletedCount',
        'followersCount',
        'followingCount',
      ],
    });

    // Get actual follower/following counts
    const actualFollowersCount = await user.countFollowers();
    const actualFollowingCount = await user.countFollowing();

    // Get total todos created
    const totalTodos = await Todo.count({
      where: { userId },
    });

    // Get public todos count
    const publicTodosCount = await Todo.count({
      where: { userId, isPublic: true },
    });

    // Get total likes received on user's todos
    const likesReceived = await Todo.sum('likeCount', {
      where: { userId },
    });

    // Get total comments on user's todos
    const commentsReceived = await Todo.sum('commentCount', {
      where: { userId },
    });

    // Get completion rate
    const completedTodos = await Todo.count({
      where: { userId, isCompleted: true },
    });
    const completionRate = totalTodos > 0 ? ((completedTodos / totalTodos) * 100).toFixed(1) : 0;

    // Get weekly activity (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const weeklyCompletedTodos = await Todo.count({
      where: {
        userId,
        isCompleted: true,
        completedAt: {
          [Op.gte]: sevenDaysAgo,
        },
      },
    });

    // Get monthly activity (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const monthlyCompletedTodos = await Todo.count({
      where: {
        userId,
        isCompleted: true,
        completedAt: {
          [Op.gte]: thirtyDaysAgo,
        },
      },
    });

    // Get category breakdown
    const categoryBreakdown = await Todo.findAll({
      where: { userId },
      attributes: [
        'categoryId',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count'],
      ],
      group: ['categoryId'],
      raw: true,
    });

    // Get most productive day of week (SQLite compatible)
    const completedTodosByDay = await Todo.findAll({
      where: {
        userId,
        isCompleted: true,
        completedAt: { [Op.not]: null },
      },
      attributes: [
        [sequelize.fn('strftime', '%w', sequelize.col('completedAt')), 'dayOfWeek'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'count'],
      ],
      group: [sequelize.fn('strftime', '%w', sequelize.col('completedAt'))],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']],
      limit: 1,
      raw: true,
    });

    const mostProductiveDay = completedTodosByDay.length > 0
      ? getDayName(parseInt(completedTodosByDay[0].dayOfWeek) + 1) // strftime %w returns 0-6, getDayName expects 1-7
      : null;

    res.json({
      success: true,
      data: {
        user: {
          xp: user.xp,
          level: user.level,
          currentStreak: user.currentStreak,
          longestStreak: user.longestStreak,
          todosCompletedCount: user.todosCompletedCount,
          followersCount: actualFollowersCount,
          followingCount: actualFollowingCount,
        },
        stats: {
          totalTodos,
          publicTodosCount,
          completedTodos,
          completionRate: parseFloat(completionRate),
          likesReceived: likesReceived || 0,
          commentsReceived: commentsReceived || 0,
          weeklyCompletedTodos,
          monthlyCompletedTodos,
          mostProductiveDay,
        },
        categoryBreakdown,
      },
    });
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({
      success: false,
      message: 'İstatistikler alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Get leaderboard
 */
export const getLeaderboard = async (req, res) => {
  try {
    const { type = 'xp', limit = 10 } = req.query;

    let orderBy = 'xp';
    switch (type) {
      case 'xp':
        orderBy = 'xp';
        break;
      case 'streak':
        orderBy = 'currentStreak';
        break;
      case 'completed':
        orderBy = 'todosCompletedCount';
        break;
      case 'followers':
        orderBy = 'followersCount';
        break;
      default:
        orderBy = 'xp';
    }

    const users = await User.findAll({
      attributes: [
        'id',
        'username',
        'profilePicture',
        'xp',
        'level',
        'currentStreak',
        'longestStreak',
        'todosCompletedCount',
        'followersCount',
      ],
      order: [[orderBy, 'DESC']],
      limit: parseInt(limit),
    });

    // Manually count followers for each user to ensure accuracy
    const usersWithActualFollowerCount = await Promise.all(
      users.map(async (user) => {
        const actualFollowerCount = await user.countFollowers();
        return {
          ...user.toJSON(),
          followersCount: actualFollowerCount,
        };
      })
    );

    res.json({
      success: true,
      data: usersWithActualFollowerCount,
    });
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({
      success: false,
      message: 'Liderlik tablosu alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Helper function to convert day number to day name
 */
function getDayName(dayNumber) {
  const days = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];
  return days[dayNumber - 1] || null;
}
