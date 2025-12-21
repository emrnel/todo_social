import User from '../models/User.js';
import Todo from '../models/Todo.js';
import Routine from '../models/Routine.js';
import Follow from '../models/Follow.js';
import TodoLike from '../models/TodoLike.js';
import { Op } from 'sequelize';

/**
 * @name   followUser
 * @desc   Follow another user.
 * @route  POST /api/social/follow/:userId
 * @access Private
 */
export const followUser = async (req, res) => {
  try {
    const followerId = req.user.id;
    const followingId = parseInt(req.params.userId, 10);

    if (followerId === followingId) {
      return res.status(400).json({ success: false, message: 'Kendinizi takip edemezsiniz.' });
    }

    const currentUser = await User.findByPk(followerId);
    const userToFollow = await User.findByPk(followingId);

    if (!userToFollow) {
      return res.status(404).json({ success: false, message: 'Takip edilecek kullanıcı bulunamadı.' });
    }

    const alreadyFollowing = await currentUser.hasFollowing(userToFollow);
    if (alreadyFollowing) {
      return res.status(409).json({ success: false, message: 'Bu kullanıcı zaten takip ediliyor.' });
    }

    await currentUser.addFollowing(userToFollow);

    res.status(200).json({ success: true, message: `Kullanıcı başarıyla takip edildi: ${userToFollow.username}` });
  } catch (error) {
    console.error('Follow User Error:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası: ' + error.message });
  }
};

/**
 * @name   unfollowUser
 * @desc   Unfollow a user.
 * @route  DELETE /api/social/unfollow/:userId
 * @access Private
 */
export const unfollowUser = async (req, res) => {
  try {
    const followerId = req.user.id;
    const followingId = parseInt(req.params.userId, 10);

    const currentUser = await User.findByPk(followerId);
    const userToUnfollow = await User.findByPk(followingId);

    const isFollowing = await currentUser.hasFollowing(userToUnfollow);
    if (!isFollowing) {
      return res.status(404).json({ success: false, message: 'Takip edilmeyen bir kullanıcıyı takipten çıkamazsınız.' });
    }

    await currentUser.removeFollowing(userToUnfollow);

    res.status(200).json({ success: true, message: 'Kullanıcı takipten çıkarıldı.' });
  } catch (error) {
    console.error('Unfollow User Error:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası: ' + error.message });
  }
};

/**
 * @name   getFeed
 * @desc   Get public todos and routines from all users (discover mode) or followed users.
 * @route  GET /api/social/feed
 * @access Private
 */
export const getFeed = async (req, res) => {
  try {
    const userId = req.user.id;

    const currentUser = await User.findByPk(userId);

    const followingUsers = await currentUser.getFollowing({ attributes: ['id'] });
    const followingIds = followingUsers.map(u => u.id);

    // Get all public todos with author info
    const [feedTodos, feedRoutines] = await Promise.all([
      Todo.findAll({
        where: {
          isPublic: true,
        },
        include: {
          model: User,
          as: 'author',
          attributes: ['id', 'username'],
        },
        order: [['createdAt', 'DESC']],
        limit: 50,
      }),
      Routine.findAll({
        where: {
          isPublic: true,
        },
        include: {
          model: User,
          as: 'author',
          attributes: ['id', 'username'],
        },
        order: [['createdAt', 'DESC']],
        limit: 50,
      }),
    ]);

    // Check likes for todos
    const todosWithLikes = await Promise.all(
      feedTodos.map(async (todo) => {
        const isLiked = await TodoLike.findOne({
          where: { userId: userId, todoId: todo.id },
        });

        return {
          id: todo.id,
          userId: todo.userId,
          username: todo.author.username,
          title: todo.title,
          description: todo.description,
          isCompleted: todo.isCompleted,
          isPublic: todo.isPublic,
          likeCount: todo.likeCount || 0,
          isLiked: !!isLiked,
          createdAt: todo.createdAt,
          type: 'todo',
        };
      })
    );

    // Combine todos and routines into a unified feed
    const feed = [
      ...todosWithLikes,
      ...feedRoutines.map(routine => ({
        id: routine.id,
        userId: routine.userId,
        username: routine.author.username,
        title: routine.title,
        description: routine.description,
        isCompleted: null,
        isPublic: routine.isPublic,
        likeCount: null,
        isLiked: null,
        createdAt: routine.createdAt,
        type: 'routine',
        recurrenceType: routine.recurrenceType,
        recurrenceValue: routine.recurrenceValue,
      })),
    ];

    // Sort by createdAt descending
    feed.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    res.status(200).json({
      success: true,
      message: 'Akış başarıyla getirildi.',
      data: { feed },
    });
  } catch (error) {
    console.error('Get Feed Error:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası: ' + error.message });
  }
};

/**
 * @name   getFollowing
 * @desc   Get list of users that current user is following
 * @route  GET /api/social/following
 * @access Private
 */
export const getFollowing = async (req, res) => {
  try {
    const userId = req.user.id;
    const currentUser = await User.findByPk(userId);
    
    if (!currentUser) {
      return res.status(404).json({
        success: false,
        message: 'Kullanıcı bulunamadı',
      });
    }
    
    const followingUsers = await currentUser.getFollowing({
      attributes: ['id', 'username', 'email'],
    });

    res.status(200).json({
      success: true,
      message: 'Takip edilen kullanıcılar getirildi.',
      data: { following: followingUsers.map(u => u.toJSON()) },
    });
  } catch (error) {
    console.error('Get Following Error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Sunucu hatası: ' + error.message 
    });
  }
};
