import express from 'express';
import User from '../models/User.js';
import Todo from '../models/Todo.js';
import Routine from '../models/Routine.js';
import TodoLike from '../models/TodoLike.js';
import Follow from '../models/Follow.js';

const router = express.Router();

/**
 * @name   getAdminStats
 * @desc   Get all database statistics for admin panel
 * @route  GET /api/admin/stats
 * @access Public (in production, this should be protected!)
 */
router.get('/stats', async (req, res) => {
  try {
    const [users, todos, routines, likes, follows] = await Promise.all([
      User.findAll({
        attributes: ['id', 'username', 'email', 'bio', 'profilePicture', 'createdAt'],
        order: [['createdAt', 'DESC']],
      }),
      Todo.findAll({
        attributes: ['id', 'userId', 'title', 'description', 'isCompleted', 'isPublic', 'likeCount', 'createdAt'],
        order: [['createdAt', 'DESC']],
      }),
      Routine.findAll({
        attributes: ['id', 'userId', 'title', 'description', 'isPublic', 'recurrenceType', 'createdAt'],
        order: [['createdAt', 'DESC']],
      }),
      TodoLike.findAll({
        attributes: ['id', 'userId', 'todoId', 'createdAt'],
        order: [['createdAt', 'DESC']],
      }),
      Follow.findAll({
        attributes: ['id', 'followerId', 'followingId', 'createdAt'],
        order: [['createdAt', 'DESC']],
      }),
    ]);

    res.status(200).json({
      success: true,
      message: 'Admin stats retrieved successfully',
      data: {
        users: users.map(u => u.toJSON()),
        todos: todos.map(t => t.toJSON()),
        routines: routines.map(r => r.toJSON()),
        likes: likes.map(l => l.toJSON()),
        follows: follows.map(f => f.toJSON()),
      },
    });
  } catch (error) {
    console.error('Get Admin Stats Error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
    });
  }
});

export default router;
