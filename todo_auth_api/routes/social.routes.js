import express from 'express';
import { followUser, unfollowUser, getFeed, getFollowing, getFollowers, getUserFollowers, getUserFollowing } from '../controllers/social.controller.js';
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

// Get following users list
router.get('/following', getFollowing);

// Get followers list
router.get('/followers', getFollowers);

// Get specific user's followers list by userId
router.get('/users/:userId/followers', getUserFollowers);

// Get specific user's following list by userId
router.get('/users/:userId/following', getUserFollowing);

export default router;
