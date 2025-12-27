import express from 'express';
import { getAllBadges, getUserBadges, getMyBadges } from '../controllers/badge.controller.js';
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

export default router;
