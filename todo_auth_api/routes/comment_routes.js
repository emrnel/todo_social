import express from 'express';
import {
  createComment,
  getCommentsByTodoId,
  updateComment,
  deleteComment,
} from '../controllers/comment_controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// All comment routes require authentication
router.post('/', authMiddleware, createComment);
router.get('/todo/:todoId', authMiddleware, getCommentsByTodoId);
router.patch('/:id', authMiddleware, updateComment);
router.delete('/:id', authMiddleware, deleteComment);

export default router;
