import Todo from '../src/models/Todo.model.js';
import { validationResult } from 'express-validator';

/**
 * @name   getMyTodos
 * @desc   Get all todos for the currently logged-in user.
 * @route  GET /api/todos/mytodos
 * @access Private (requires JWT)
 */
export const getMyTodos = async (req, res) => {
  try {
    // The user ID is attached to the request by the authMiddleware.
    const userId = req.user.id;

    // Find all todos in the database that belong to this user.
    const todos = await Todo.findAll({
      where: { userId: userId },
      order: [['createdAt', 'DESC']], // Show newest todos first.
    });

    return res.status(200).json({
      success: true,
      message: 'Kullanıcının yapılacaklar listesi başarıyla getirildi',
      data: { todos },
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
  // Check for validation errors from the route.
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

    // Create the new todo in the database.
    const newTodo = await Todo.create({
      userId,
      title,
      description: description || null, // Ensure description is null if not provided.
      isPublic: isPublic || false, // Default to false if not provided.
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