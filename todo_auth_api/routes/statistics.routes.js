import express from 'express';
import { getMyStatistics, getLeaderboard } from '../controllers/statistics.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get my statistics
router.get('/my', getMyStatistics);

// Get leaderboard
router.get('/leaderboard', getLeaderboard);

export default router;
