import User from '../models/User.js';

/**
 * @name   getMyProfile
 * @desc   Get the profile information of the currently logged-in user.
 * @route  GET /api/users/me
 * @access Private (requires JWT)
 */
export const getMyProfile = async (req, res) => {
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