import express from 'express';
import { body } from 'express-validator';

// Import the middleware and controller
import authMiddleware from '../middleware/auth.middleware.js';
import { getMyTodos, createTodo } from '../controllers/todo_controller.js';

const router = express.Router();

// @route   GET /api/todos/mytodos
// @desc    Get all todos for the current user
// @access  Private
router.get('/mytodos', authMiddleware, getMyTodos);

// @route   POST /api/todos
// @desc    Create a new todo
// @access  Private
router.post(
  '/',
  authMiddleware,
  [
    // Validation rule: title must not be empty and should be between 1 and 200 characters.
    body('title', 'Başlık boş olamaz').notEmpty().isLength({ min: 1, max: 200 }),
  ],
  createTodo
);

export default router;