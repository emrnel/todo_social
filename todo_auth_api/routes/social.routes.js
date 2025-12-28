import express from 'express';
import {
  followUser,
  unfollowUser,
  getFeed,
  getFollowing,
  getFollowers,
  getUserFollowers,
  getUserFollowing
} from '../controllers/social.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply auth middleware to all social routes
router.use(authMiddleware);

// Get the user's feed (more specific routes first)
router.get('/feed', getFeed);

// Get current user's following users list
router.get('/following', getFollowing);

// Get current user's followers list
router.get('/followers', getFollowers);

// Get specific user's followers list by userId (before generic :userId routes)
router.get('/users/:userId/followers', getUserFollowers);

// Get specific user's following list by userId
router.get('/users/:userId/following', getUserFollowing);

// Follow a user
router.post('/follow/:userId', followUser);

// Unfollow a user
router.delete('/unfollow/:userId', unfollowUser);

export default router;
