import express from 'express';
import { getMe, updateProfile, searchUsers, getUserProfile } from '../controllers/user_controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

router.use(authMiddleware);

router.get('/me', getMe);
router.patch('/me', updateProfile);

router.get('/search', searchUsers);

router.get('/profile/:username', getUserProfile);

export default router;
