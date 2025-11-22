import express from 'express';
import { body } from 'express-validator';
import {
  createTodo,
  getMyTodos,
  updateTodo,
  deleteTodo,
} from '../controllers/todo_controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply the authentication middleware to all routes in this file.
router.use(authMiddleware);

// GET /api/todos/mytodos - Get all todos for the logged-in user
router.get('/mytodos', getMyTodos);

// POST /api/todos - Create a new todo
router.post(
  '/',
  [body('title', 'Başlık boş olamaz').notEmpty().isString().trim()],
  createTodo
);

// PATCH /api/todos/:id - Update a specific todo
router.patch('/:id', updateTodo);

// DELETE /api/todos/:id - Delete a specific todo
router.delete('/:id', deleteTodo);

export default router;