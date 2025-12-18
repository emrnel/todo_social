import Todo from '../models/Todo.js';
import Routine from '../models/Routine.js';
import { validationResult } from 'express-validator';

/**
 * Helper function to check if a routine should appear today
 * @param {Routine} routine - The routine object
 * @returns {boolean} - Whether routine should appear today
 */
const shouldShowRoutineToday = (routine) => {
  const today = new Date();
  const dayOfWeek = today.toLocaleDateString('en-US', { weekday: 'short' }).toLowerCase(); // 'mon', 'tue', etc.

  if (routine.recurrenceType === 'daily') {
    return true;
  }

  if (routine.recurrenceType === 'weekly' && routine.recurrenceValue) {
    try {
      const days = JSON.parse(routine.recurrenceValue);
      return Array.isArray(days) && days.includes(dayOfWeek);
    } catch (e) {
      console.error('Error parsing recurrenceValue:', e);
      return false;
    }
  }

  return false;
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

    // Find all todos and routines for this user in parallel
    const [todos, routines] = await Promise.all([
      Todo.findAll({
        where: { userId: userId },
        order: [['createdAt', 'DESC']],
      }),
      Routine.findAll({
        where: { userId: userId },
        order: [['createdAt', 'DESC']],
      }),
    ]);

    // Return separate arrays for todos and routines
    // Frontend will handle filtering routines based on today
    return res.status(200).json({
      success: true,
      message: 'Kullanıcının yapılacaklar listesi başarıyla getirildi',
      data: {
        todos: todos.map(t => t.toJSON()),
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
