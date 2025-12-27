import Category from '../models/Category.js';
import Todo from '../models/Todo.js';
import User from '../models/User.js';

/**
 * Get all categories
 */
export const getAllCategories = async (req, res) => {
  try {
    const categories = await Category.findAll({
      order: [['name', 'ASC']],
    });

    res.json({
      success: true,
      data: categories,
    });
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({
      success: false,
      message: 'Kategoriler alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Get todos by category
 */
export const getTodosByCategory = async (req, res) => {
  try {
    const { categoryId } = req.params;

    const category = await Category.findByPk(categoryId, {
      include: [
        {
          model: Todo,
          as: 'todos',
          where: { isPublic: true },
          required: false,
          include: [
            {
              model: User,
              as: 'author',
              attributes: ['id', 'username', 'profilePicture'],
            },
          ],
          order: [['createdAt', 'DESC']],
        },
      ],
    });

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Kategori bulunamadı',
        error: { code: 'CATEGORY_NOT_FOUND' },
      });
    }

    res.json({
      success: true,
      data: category,
    });
  } catch (error) {
    console.error('Error fetching todos by category:', error);
    res.status(500).json({
      success: false,
      message: 'Kategoriye ait todolar alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};
