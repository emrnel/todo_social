import express from 'express';
import { body } from 'express-validator';
import {
  createTodo,
  getMyTodos,
  updateTodo,
  deleteTodo,
  likeTodo,
  unlikeTodo,
  copyTodo,
} from '../controllers/todo_controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

router.use(authMiddleware);

router.get('/mytodos', getMyTodos);

router.post(
  '/',
  [body('title', 'Başlık boş olamaz').notEmpty().isString().trim()],
  createTodo
);

router.patch('/:id', updateTodo);

router.delete('/:id', deleteTodo);

// Like/Unlike routes
router.post('/:id/like', likeTodo);
router.delete('/:id/like', unlikeTodo);

// Copy route
router.post('/:id/copy', copyTodo);

export default router;
