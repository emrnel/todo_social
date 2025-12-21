import User from '../models/User.js';
import Todo from '../models/Todo.js';
import TodoLike from '../models/TodoLike.js';
import { Op } from 'sequelize';
import Follow from '../models/Follow.js';

/**
 * @name   getMe
 * @desc   Get the profile information of the currently logged-in user.
 * @route  GET /api/users/me
 * @access Private (requires JWT)
 */
export const getMe = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await User.findByPk(userId, {
      attributes: { exclude: ['password_hash', 'updatedAt'] },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Kullanıcı bulunamadı',
        error: { code: 'USER_NOT_FOUND' },
      });
    }

    const followerCount = parseInt(await user.countFollowers(), 10) || 0;
    const followingCount = parseInt(await user.countFollowing(), 10) || 0;

    return res.status(200).json({
      success: true,
      message: 'Profil bilgileri başarıyla getirildi',
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          bio: user.bio,
          profilePicture: user.profilePicture,
          createdAt: user.createdAt,
        },
        followerCount,
        followingCount,
      },
    });
  } catch (error) {
    console.error('Get My Profile Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   updateProfile
 * @desc   Update user profile (bio, profilePicture)
 * @route  PATCH /api/users/me
 * @access Private
 */
export const updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { bio, profilePicture } = req.body;

    const user = await User.findByPk(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Kullanıcı bulunamadı',
        error: { code: 'USER_NOT_FOUND' },
      });
    }

    await user.update({
      bio: bio !== undefined ? bio : user.bio,
      profilePicture: profilePicture !== undefined ? profilePicture : user.profilePicture,
    });

    return res.status(200).json({
      success: true,
      message: 'Profil güncellendi',
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          bio: user.bio,
          profilePicture: user.profilePicture,
          createdAt: user.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Update Profile Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   searchUsers
 * @desc   Search for users by username.
 * @route  GET /api/users/search?q=<query>
 * @access Private
 */
export const searchUsers = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Arama yapmak için en az 2 karakter girmelisiniz.',
      });
    }

    const users = await User.findAll({
      where: {
        username: {
          [Op.like]: `%${q}%`,
        },
      },
      attributes: ['id', 'username', 'bio', 'profilePicture'],
      limit: 10,
    });

    return res.status(200).json({
      success: true,
      data: { users },
    });
  } catch (error) {
    console.error('Search Users Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
    });
  }
};

/**
 * @name   getUserProfile
 * @desc   Get a specific user's profile by username with public todos and follow status
 * @route  GET /api/users/profile/:username
 * @access Private
 */
export const getUserProfile = async (req, res) => {
  try {
    const { username } = req.params;
    const currentUserId = req.user.id;

    const user = await User.findOne({
      where: { username: username },
      attributes: ['id', 'username', 'email', 'bio', 'profilePicture', 'createdAt'],
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Kullanıcı bulunamadı',
        error: { code: 'USER_NOT_FOUND' },
      });
    }

    const followerCount = parseInt(await user.countFollowers(), 10) || 0;
    const followingCount = parseInt(await user.countFollowing(), 10) || 0;

    const publicTodos = await Todo.findAll({
      where: {
        userId: user.id,
        isPublic: true,
      },
      attributes: ['id', 'title', 'description', 'isCompleted', 'likeCount', 'createdAt', 'updatedAt'],
      order: [['createdAt', 'DESC']],
      limit: 50,
      include: [
        {
          model: User,
          as: 'originalAuthor',
          attributes: ['id', 'username'],
        },
      ],
    });

    // Check if current user liked each todo
    const todosWithLikes = await Promise.all(
      publicTodos.map(async (todo) => {
        const isLiked = await TodoLike.findOne({
          where: { userId: currentUserId, todoId: todo.id },
        });
        
        const todoJson = todo.toJSON();
        return {
          ...todoJson,
          isLiked: !!isLiked,
          originalAuthor: todoJson.originalAuthor || null,
        };
      })
    );

    const currentUser = await User.findByPk(currentUserId);
    const isFollowing = await currentUser.hasFollowing(user);

    return res.status(200).json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          bio: user.bio,
          profilePicture: user.profilePicture,
          createdAt: user.createdAt,
        },
        followerCount,
        followingCount,
        publicTodos: todosWithLikes,
        isFollowing,
      },
    });
  } catch (error) {
    console.error('Get User Profile Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};
