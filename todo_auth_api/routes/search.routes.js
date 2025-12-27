import express from 'express';
import {
  searchUsers,
  searchTodos,
  searchHashtags,
  getTrendingHashtags,
  getTodosByHashtag,
} from '../controllers/search.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply auth middleware to all routes
router.use(authMiddleware);

// Search users
router.get('/users', searchUsers);

// Search todos
router.get('/todos', searchTodos);

// Search hashtags
router.get('/hashtags', searchHashtags);

// Get trending hashtags
router.get('/trending', getTrendingHashtags);

// Get todos by hashtag
router.get('/hashtag/:tag', getTodosByHashtag);

export default router;
