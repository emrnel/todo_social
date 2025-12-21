import Todo from '../models/Todo.js';
import Routine from '../models/Routine.js';
import TodoLike from '../models/TodoLike.js';
import User from '../models/User.js';
import { validationResult } from 'express-validator';

/**
 * @name   getMyTodos
 * @desc   Get all todos and routines for the logged-in user
 * @route  GET /api/todos/mytodos
 * @access Private (requires JWT)
 */
export const getMyTodos = async (req, res) => {
  try {
    const userId = req.user.id;

    const [todos, routines] = await Promise.all([
      Todo.findAll({
        where: { userId: userId },
        order: [['createdAt', 'DESC']],
        include: [
          {
            model: User,
            as: 'originalAuthor',
            attributes: ['id', 'username'],
          },
        ],
      }),
      Routine.findAll({
        where: { userId: userId },
        order: [['createdAt', 'DESC']],
      }),
    ]);

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
        routines: routines.map(r => r.toJSON()),
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
    const { title, description, isPublic } = req.body;
    const userId = req.user.id;

    const newTodo = await Todo.create({
      userId,
      title,
      description: description || null,
      isPublic: isPublic || false,
    });

    return res.status(201).json({
      success: true,
      message: 'Görev oluşturuldu',
      data: { todo: newTodo },
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
    const { title, description, isCompleted, isPublic } = req.body;

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

    const updatedTodo = await todo.update({
      title: title !== undefined ? title : todo.title,
      description: description !== undefined ? description : todo.description,
      isCompleted: isCompleted !== undefined ? isCompleted : todo.isCompleted,
      isPublic: isPublic !== undefined ? isPublic : todo.isPublic,
    });

    return res.status(200).json({
      success: true,
      message: 'Görev güncellendi',
      data: { todo: updatedTodo },
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
    await todo.update({ likeCount: todo.likeCount + 1 });

    return res.status(200).json({
      success: true,
      message: 'Görev beğenildi',
      data: { likeCount: todo.likeCount + 1 },
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

    // Create copy
    const copiedTodo = await Todo.create({
      userId,
      title: originalTodo.title,
      description: originalTodo.description,
      isPublic: false, // Copied todos are private by default
      isCompleted: false,
      originalAuthorId,
    });

    // Fetch with author info
    const copiedTodoWithAuthor = await Todo.findByPk(copiedTodo.id, {
      include: [
        {
          model: User,
          as: 'originalAuthor',
          attributes: ['id', 'username'],
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
