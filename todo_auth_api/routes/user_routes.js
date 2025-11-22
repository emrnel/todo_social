import express from 'express';
import { getMe, searchUsers, getUserProfile } from '../controllers/user_controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Bu dosyada tanımlanan TÜM rotaların kimlik doğrulaması gerektirdiğini belirtiyoruz.
// /api/users/ altındaki herhangi bir istek önce authMiddleware'den geçecek.
router.use(authMiddleware);

/**
 * @route   GET /api/users/me
 * @desc    Oturum açmış kullanıcının profil bilgilerini getirir.
 * @access  Private (authMiddleware tarafından korunuyor)
 */
router.get('/me', getMe);

// Search for users
router.get('/search', searchUsers);

// Get a specific user's profile
router.get('/:userId', getUserProfile);

export default router;