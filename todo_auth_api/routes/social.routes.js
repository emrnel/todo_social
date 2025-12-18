import express from 'express';
import { followUser, unfollowUser, getFeed, getFollowing } from '../controllers/social.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply auth middleware to all social routes
router.use(authMiddleware);

// Follow a user
router.post('/follow/:userId', followUser);

// Unfollow a user
router.delete('/unfollow/:userId', unfollowUser);

// Get the user's feed
router.get('/feed', getFeed);

// Get following users
router.get('/following', getFollowing);

export default router;
