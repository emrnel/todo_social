import Todo from '../models/Todo.js';
import Routine from '../models/Routine.js';
import RoutineCompletion from '../models/RoutineCompletion.js';
import TodoLike from '../models/TodoLike.js';
import User from '../models/User.js';
import Category from '../models/Category.js';
import Hashtag from '../models/Hashtag.js';
import { validationResult } from 'express-validator';
import { processHashtags, calculateXP, addXP, updateStreak } from '../utils/helpers.js';
import { createNotification } from './notification.controller.js';
import { checkAndAwardBadges } from './badge.controller.js';
import { Op } from 'sequelize';

/**
 * Helper function to check if routine is completed for current period
 */
const checkRoutineCompletedToday = async (routineId, userId, recurrenceType) => {
  const now = new Date();
  let startDate;

  if (recurrenceType === 'daily') {
    // Check if completed today
    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  } else if (recurrenceType === 'weekly') {
    // Check if completed this week (week starts on Monday)
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Adjust for Monday start
    startDate = new Date(now);
    startDate.setDate(now.getDate() - diff);
    startDate.setHours(0, 0, 0, 0);
  } else {
    // For custom recurrence, check today
    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  }

  const completion = await RoutineCompletion.findOne({
    where: {
      routineId,
      userId,
      completedAt: {
        [Op.gte]: startDate,
      },
    },
  });

  return !!completion;
};

/**
 * @name   getMyTodos
 * @desc   Get all todos and routines for the logged-in user
 * @route  GET /api/todos/mytodos
 * @access Private (requires JWT)
 */
export const getMyTodos = async (req, res) => {
  try {
    const userId = req.user.id;

    const [todos, allRoutines] = await Promise.all([
      Todo.findAll({
        where: { userId: userId },
        order: [['createdAt', 'DESC']],
        include: [
          {
            model: User,
            as: 'originalAuthor',
            attributes: ['id', 'username'],
          },
          {
            model: Category,
            as: 'category',
            attributes: ['id', 'name', 'icon', 'color'],
          },
          {
            model: Hashtag,
            as: 'hashtags',
            attributes: ['id', 'tag'],
            through: { attributes: [] },
          },
        ],
      }),
      Routine.findAll({
        where: { userId: userId },
        order: [['createdAt', 'DESC']],
      }),
    ]);

    // Filter out completed routines (only show incomplete ones)
    const incompleteRoutines = [];
    for (const routine of allRoutines) {
      const isCompletedToday = await checkRoutineCompletedToday(
        routine.id,
        userId,
        routine.recurrenceType
      );
      if (!isCompletedToday) {
        incompleteRoutines.push(routine.toJSON());
      }
    }

    // Check if user liked each todo
    const todosWithLikes = await Promise.all(
      todos.map(async (todo) => {
        const isLiked = await TodoLike.findOne({
          where: { userId: userId, todoId: todo.id },
        });

        const todoJson = todo.toJSON();
        return {
          ...todoJson,
          isLiked: !!isLiked,
          originalAuthor: todoJson.originalAuthor || null,
        };
      })
    );

    return res.status(200).json({
      success: true,
      message: 'Kullanıcının yapılacaklar listesi başarıyla getirildi',
      data: {
        todos: todosWithLikes,
        routines: incompleteRoutines,
      },
    });
  } catch (error) {
    console.error('Get My Todos Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   createTodo
 * @desc   Create a new todo for the logged-in user.
 * @route  POST /api/todos
 * @access Private (requires JWT)
 */
export const createTodo = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validasyon hatası',
      error: {
        code: 'VALIDATION_ERROR',
        details: errors.array().map((err) => ({ field: err.path, message: err.msg })),
      },
    });
  }

  try {
    const { title, description, isPublic, categoryId } = req.body;
    const userId = req.user.id;

    const newTodo = await Todo.create({
      userId,
      title,
      description: description || null,
      isPublic: isPublic || false,
      categoryId: categoryId || null,
    });

    // Process hashtags from title and description
    const textForHashtags = `${title} ${description || ''}`;
    await processHashtags(newTodo.id, textForHashtags);

    // Award XP for creating public todo
    if (isPublic) {
      const user = await User.findByPk(userId);
      const xpGained = calculateXP('todo_created_public');
      await addXP(user, xpGained);
      await checkAndAwardBadges(userId);
    }

    // Fetch todo with all relations
    const todoWithRelations = await Todo.findByPk(newTodo.id, {
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'icon', 'color'],
        },
        {
          model: Hashtag,
          as: 'hashtags',
          attributes: ['id', 'tag'],
          through: { attributes: [] },
        },
      ],
    });

    return res.status(201).json({
      success: true,
      message: 'Görev oluşturuldu',
      data: { todo: todoWithRelations },
    });
  } catch (error) {
    console.error('Create Todo Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   updateTodo
 * @desc   Update an existing todo for the logged-in user.
 * @route  PATCH /api/todos/:id
 * @access Private (requires JWT)
 */
export const updateTodo = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { title, description, isCompleted, isPublic, categoryId } = req.body;

    const todo = await Todo.findByPk(id);

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Görev bulunamadı',
        error: { code: 'TODO_NOT_FOUND' },
      });
    }

    if (todo.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Bu görevi güncelleme yetkiniz yok',
        error: { code: 'FORBIDDEN' },
      });
    }

    const wasCompleted = todo.isCompleted;
    const nowCompleted = isCompleted !== undefined ? isCompleted : todo.isCompleted;

    const updatedTodo = await todo.update({
      title: title !== undefined ? title : todo.title,
      description: description !== undefined ? description : todo.description,
      isCompleted: nowCompleted,
      isPublic: isPublic !== undefined ? isPublic : todo.isPublic,
      categoryId: categoryId !== undefined ? categoryId : todo.categoryId,
      completedAt: nowCompleted && !wasCompleted ? new Date() : todo.completedAt,
    });

    // If todo was just completed, update streak and XP
    if (!wasCompleted && nowCompleted) {
      const user = await User.findByPk(userId);

      // Update streak
      await updateStreak(user);

      // Award XP
      const xpGained = calculateXP('todo_completed');
      await addXP(user, xpGained);

      // Increment todos completed count
      await user.increment('todosCompletedCount');

      // Check for new badges
      await checkAndAwardBadges(userId);
    }

    // Re-process hashtags if title or description changed
    if (title !== undefined || description !== undefined) {
      const textForHashtags = `${updatedTodo.title} ${updatedTodo.description || ''}`;
      await processHashtags(updatedTodo.id, textForHashtags);
    }

    // Fetch with relations
    const todoWithRelations = await Todo.findByPk(updatedTodo.id, {
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'icon', 'color'],
        },
        {
          model: Hashtag,
          as: 'hashtags',
          attributes: ['id', 'tag'],
          through: { attributes: [] },
        },
      ],
    });

    return res.status(200).json({
      success: true,
      message: 'Görev güncellendi',
      data: { todo: todoWithRelations },
    });
  } catch (error) {
    console.error('Update Todo Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   deleteTodo
 * @desc   Delete a todo for the logged-in user.
 * @route  DELETE /api/todos/:id
 * @access Private (requires JWT)
 */
export const deleteTodo = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const todo = await Todo.findByPk(id);

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Görev bulunamadı',
        error: { code: 'TODO_NOT_FOUND' },
      });
    }

    if (todo.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Bu görevi silme yetkiniz yok',
        error: { code: 'FORBIDDEN' },
      });
    }

    await todo.destroy();

    return res.status(200).json({ success: true, message: 'Görev silindi' });
  } catch (error) {
    console.error('Delete Todo Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   likeTodo
 * @desc   Like a todo
 * @route  POST /api/todos/:id/like
 * @access Private
 */
export const likeTodo = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const todo = await Todo.findByPk(id);

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Görev bulunamadı',
        error: { code: 'TODO_NOT_FOUND' },
      });
    }

    // Check if already liked
    const existingLike = await TodoLike.findOne({
      where: { userId, todoId: id },
    });

    if (existingLike) {
      return res.status(400).json({
        success: false,
        message: 'Bu görevi zaten beğendiniz',
        error: { code: 'ALREADY_LIKED' },
      });
    }

    // Create like
    await TodoLike.create({ userId, todoId: id });

    // Increment like count
    const newLikeCount = todo.likeCount + 1;
    await todo.update({ likeCount: newLikeCount });

    // Create notification for todo author (if not liking own todo)
    if (todo.userId !== userId) {
      await createNotification({
        userId: todo.userId,
        actorId: userId,
        type: 'like',
        todoId: id,
        message: 'görevinizi beğendi',
      });

      // Award XP to todo author
      const author = await User.findByPk(todo.userId);
      const xpGained = calculateXP('received_like');
      await addXP(author, xpGained);
    }

    return res.status(200).json({
      success: true,
      message: 'Görev beğenildi',
      data: { likeCount: newLikeCount },
    });
  } catch (error) {
    console.error('Like Todo Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   unlikeTodo
 * @desc   Unlike a todo
 * @route  DELETE /api/todos/:id/like
 * @access Private
 */
export const unlikeTodo = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const todo = await Todo.findByPk(id);

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Görev bulunamadı',
        error: { code: 'TODO_NOT_FOUND' },
      });
    }

    const existingLike = await TodoLike.findOne({
      where: { userId, todoId: id },
    });

    if (!existingLike) {
      return res.status(400).json({
        success: false,
        message: 'Bu görevi beğenmediniz',
        error: { code: 'NOT_LIKED' },
      });
    }

    await existingLike.destroy();

    // Decrement like count
    const newLikeCount = Math.max(0, todo.likeCount - 1);
    await todo.update({ likeCount: newLikeCount });

    return res.status(200).json({
      success: true,
      message: 'Beğeni kaldırıldı',
      data: { likeCount: newLikeCount },
    });
  } catch (error) {
    console.error('Unlike Todo Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   copyTodo
 * @desc   Copy a public todo to current user's list
 * @route  POST /api/todos/:id/copy
 * @access Private
 */
export const copyTodo = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const originalTodo = await Todo.findByPk(id, {
      include: [
        {
          model: User,
          as: 'author',
          attributes: ['id', 'username'],
        },
      ],
    });

    if (!originalTodo) {
      return res.status(404).json({
        success: false,
        message: 'Görev bulunamadı',
        error: { code: 'TODO_NOT_FOUND' },
      });
    }

    if (!originalTodo.isPublic) {
      return res.status(403).json({
        success: false,
        message: 'Bu görev herkese açık değil',
        error: { code: 'NOT_PUBLIC' },
      });
    }

    if (originalTodo.userId === userId) {
      return res.status(400).json({
        success: false,
        message: 'Kendi görevinizi kopyalayamazsınız',
        error: { code: 'CANNOT_COPY_OWN' },
      });
    }

    // Determine the original author (if this is already a copy, use its original author)
    const originalAuthorId = originalTodo.originalAuthorId || originalTodo.userId;

    // Check if user has already copied this todo
    const existingCopy = await Todo.findOne({
      where: {
        userId,
        originalAuthorId,
        title: originalTodo.title,
      },
    });

    if (existingCopy) {
      return res.status(409).json({
        success: false,
        message: 'Bu görevi zaten kopyaladınız',
        error: { code: 'ALREADY_COPIED' },
      });
    }

    // Create copy
    const copiedTodo = await Todo.create({
      userId,
      title: originalTodo.title,
      description: originalTodo.description,
      isPublic: false, // Copied todos are private by default
      isCompleted: false,
      originalAuthorId,
      categoryId: originalTodo.categoryId,
    });

    // Copy hashtags
    const textForHashtags = `${originalTodo.title} ${originalTodo.description || ''}`;
    await processHashtags(copiedTodo.id, textForHashtags);

    // Increment copy count on original todo
    await originalTodo.increment('copyCount');

    // Create notification for original author
    await createNotification({
      userId: originalAuthorId,
      actorId: userId,
      type: 'todo_copied',
      todoId: id,
      message: 'görevinizi kopyaladı',
    });

    // Award XP to original author
    const originalAuthor = await User.findByPk(originalAuthorId);
    const xpGained = calculateXP('todo_copied_by_others');
    await addXP(originalAuthor, xpGained);

    // Fetch with author info
    const copiedTodoWithAuthor = await Todo.findByPk(copiedTodo.id, {
      include: [
        {
          model: User,
          as: 'originalAuthor',
          attributes: ['id', 'username'],
        },
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'icon', 'color'],
        },
        {
          model: Hashtag,
          as: 'hashtags',
          attributes: ['id', 'tag'],
          through: { attributes: [] },
        },
      ],
    });

    return res.status(201).json({
      success: true,
      message: 'Görev kopyalandı',
      data: { todo: copiedTodoWithAuthor },
    });
  } catch (error) {
    console.error('Copy Todo Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   getTodoLikes  
 * @desc   Get list of users who liked a todo
 * @route  GET /api/todos/:id/likes
 * @access Private
 */
export const getTodoLikes = async (req, res) => {
  try {
    const { id } = req.params;

    const todo = await Todo.findByPk(id);
    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Görev bulunamadı',
        error: { code: 'TODO_NOT_FOUND' },
      });
    }

    const likes = await TodoLike.findAll({
      where: { todoId: id },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'profilePicture'],
        },
      ],
      order: [['createdAt', 'DESC']],
    });

    const users = likes.map((like) => like.user);

    return res.status(200).json({
      success: true,
      data: { users, count: users.length },
    });
  } catch (error) {
    console.error('Get Todo Likes Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};
