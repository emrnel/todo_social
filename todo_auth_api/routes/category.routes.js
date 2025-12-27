import express from 'express';
import { getAllCategories, getTodosByCategory } from '../controllers/category.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all categories
router.get('/', getAllCategories);

// Get todos by category
router.get('/:categoryId/todos', getTodosByCategory);

export default router;
