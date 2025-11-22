import User from '../models/User.js';
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
    // The authMiddleware has already run and attached the user's ID to req.user.
    const userId = req.user.id;

    // Find the user by their primary key (ID), excluding the password hash.
    const user = await User.findByPk(userId, {
      attributes: { exclude: ['password_hash', 'updatedAt'] },
    });

    // This case is unlikely if the token is valid, but it's a good safeguard.
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Kullanıcı bulunamadı',
        error: { code: 'USER_NOT_FOUND' },
      });
    }

    // Return the user data as per the API contract.
    return res.status(200).json({
      success: true,
      message: 'Profil bilgileri başarıyla getirildi', // Added for consistency
      data: {
        user: user,
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
      attributes: ['id', 'username'],
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
 * @desc   Get a specific user's profile along with follower/following counts.
 * @route  GET /api/users/:userId
 * @access Private
 */
export const getUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findByPk(userId, {
      attributes: ['id', 'username', 'createdAt'],
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Kullanıcı bulunamadı',
      });
    }

    // Get follower and following counts
    // Use Sequelize's magic methods for consistency and robustness
    const followerCount = await user.countFollowers();
    const followingCount = await user.countFollowing();


    return res.status(200).json({
      success: true,
      data: {
        user: {
          ...user.toJSON(),
          followerCount,
          followingCount,
        },
      },
    });
  } catch (error) {
    console.error('Get User Profile Error:', error);
    return res.status(500).json({ success: false, message: 'Sunucu hatası: ' + error.message });
  }
};