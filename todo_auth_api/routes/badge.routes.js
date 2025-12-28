import express from 'express';
import { getAllBadges, getUserBadges, getMyBadges, checkAndAwardBadges } from '../controllers/badge.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all badges
router.get('/', getAllBadges);

// Get my badges
router.get('/my', getMyBadges);

// Get user's badges
router.get('/user/:userId', getUserBadges);

// Manually trigger badge check for current user
router.post('/check', async (req, res) => {
  try {
    await checkAndAwardBadges(req.user.id);
    res.json({
      success: true,
      message: 'Rozet kontrolü tamamlandı',
    });
  } catch (error) {
    console.error('Badge check error:', error);
    res.status(500).json({
      success: false,
      message: 'Rozet kontrolü sırasında hata oluştu',
    });
  }
});

export default router;
