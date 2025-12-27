import Comment from '../models/Comment.js';
import User from '../models/User.js';
import Todo from '../models/Todo.js';
import { createNotification } from './notification.controller.js';
import { calculateXP, addXP } from '../utils/helpers.js';

// Create a new comment
export const createComment = async (req, res) => {
  try {
    const { todoId, text } = req.body;
    const userId = req.user.id;

    if (!todoId || !text || text.trim() === '') {
      return res.status(400).json({ error: 'TodoId and text are required' });
    }

    // Check if todo exists
    const todo = await Todo.findByPk(todoId);
    if (!todo) {
      return res.status(404).json({ error: 'Todo not found' });
    }

    const comment = await Comment.create({
      userId,
      todoId,
      text: text.trim(),
    });

    // Increment comment count on todo
    await todo.increment('commentCount');

    // Create notification for todo author (if not commenting on own todo)
    if (todo.userId !== userId) {
      await createNotification({
        userId: todo.userId,
        actorId: userId,
        type: 'comment',
        todoId,
        commentId: comment.id,
        message: 'görevinize yorum yaptı',
      });

      // Award XP to todo author
      const author = await User.findByPk(todo.userId);
      const xpGained = calculateXP('received_comment');
      await addXP(author, xpGained);
    }

    // Fetch the created comment with user info
    const commentWithUser = await Comment.findByPk(comment.id, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'profilePicture'],
        },
      ],
    });

    res.status(201).json(commentWithUser);
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({ error: 'Failed to create comment' });
  }
};

// Get all comments for a todo
export const getCommentsByTodoId = async (req, res) => {
  try {
    const { todoId } = req.params;

    const comments = await Comment.findAll({
      where: { todoId },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'profilePicture'],
        },
      ],
      order: [['createdAt', 'ASC']],
    });

    res.json(comments);
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
};

// Update a comment
export const updateComment = async (req, res) => {
  try {
    const { id } = req.params;
    const { text } = req.body;
    const userId = req.user.id;

    if (!text || text.trim() === '') {
      return res.status(400).json({ error: 'Text is required' });
    }

    const comment = await Comment.findByPk(id);
    if (!comment) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    // Check if user owns the comment
    if (comment.userId !== userId) {
      return res.status(403).json({ error: 'You can only edit your own comments' });
    }

    comment.text = text.trim();
    await comment.save();

    // Fetch updated comment with user info
    const updatedComment = await Comment.findByPk(id, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'profilePicture'],
        },
      ],
    });

    res.json(updatedComment);
  } catch (error) {
    console.error('Error updating comment:', error);
    res.status(500).json({ error: 'Failed to update comment' });
  }
};

// Delete a comment
export const deleteComment = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const comment = await Comment.findByPk(id);
    if (!comment) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    // Check if user owns the comment
    if (comment.userId !== userId) {
      return res.status(403).json({ error: 'You can only delete your own comments' });
    }

    // Decrement comment count on todo
    const todo = await Todo.findByPk(comment.todoId);
    if (todo && todo.commentCount > 0) {
      await todo.decrement('commentCount');
    }

    await comment.destroy();
    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ error: 'Failed to delete comment' });
  }
};
