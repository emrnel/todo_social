import { Op } from 'sequelize';
import User from '../models/User.js';
import Todo from '../models/Todo.js';
import Hashtag from '../models/Hashtag.js';
import Category from '../models/Category.js';

/**
 * Search users
 */
export const searchUsers = async (req, res) => {
  try {
    const { q, limit = 20, offset = 0 } = req.query;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Arama sorgusu en az 2 karakter olmalıdır',
        error: { code: 'INVALID_QUERY' },
      });
    }

    const users = await User.findAll({
      where: {
        [Op.or]: [
          { username: { [Op.like]: `%${q}%` } },
          { bio: { [Op.like]: `%${q}%` } },
        ],
      },
      attributes: ['id', 'username', 'bio', 'profilePicture', 'followersCount', 'level', 'xp'],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['followersCount', 'DESC']],
    });

    res.json({
      success: true,
      data: users,
    });
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({
      success: false,
      message: 'Kullanıcı araması yapılırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Search todos
 */
export const searchTodos = async (req, res) => {
  try {
    const { q, categoryId, limit = 20, offset = 0 } = req.query;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Arama sorgusu en az 2 karakter olmalıdır',
        error: { code: 'INVALID_QUERY' },
      });
    }

    const where = {
      isPublic: true,
      [Op.or]: [
        { title: { [Op.like]: `%${q}%` } },
        { description: { [Op.like]: `%${q}%` } },
      ],
    };

    if (categoryId) {
      where.categoryId = categoryId;
    }

    const todos = await Todo.findAll({
      where,
      include: [
        {
          model: User,
          as: 'author',
          attributes: ['id', 'username', 'profilePicture'],
        },
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'icon', 'color'],
        },
      ],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['likeCount', 'DESC'], ['createdAt', 'DESC']],
    });

    res.json({
      success: true,
      data: todos,
    });
  } catch (error) {
    console.error('Error searching todos:', error);
    res.status(500).json({
      success: false,
      message: 'Todo araması yapılırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Search hashtags
 */
export const searchHashtags = async (req, res) => {
  try {
    const { q, limit = 20 } = req.query;

    if (!q || q.trim().length < 1) {
      return res.status(400).json({
        success: false,
        message: 'Arama sorgusu en az 1 karakter olmalıdır',
        error: { code: 'INVALID_QUERY' },
      });
    }

    const hashtags = await Hashtag.findAll({
      where: {
        tag: { [Op.like]: `%${q}%` },
      },
      limit: parseInt(limit),
      order: [['usageCount', 'DESC']],
    });

    res.json({
      success: true,
      data: hashtags,
    });
  } catch (error) {
    console.error('Error searching hashtags:', error);
    res.status(500).json({
      success: false,
      message: 'Hashtag araması yapılırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Get trending hashtags
 */
export const getTrendingHashtags = async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const hashtags = await Hashtag.findAll({
      limit: parseInt(limit),
      order: [['usageCount', 'DESC']],
    });

    res.json({
      success: true,
      data: hashtags,
    });
  } catch (error) {
    console.error('Error fetching trending hashtags:', error);
    res.status(500).json({
      success: false,
      message: 'Trend hashtag\'ler alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Get todos by hashtag
 */
export const getTodosByHashtag = async (req, res) => {
  try {
    const { tag } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    const hashtag = await Hashtag.findOne({
      where: { tag: tag.toLowerCase() },
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
            {
              model: Category,
              as: 'category',
              attributes: ['id', 'name', 'icon', 'color'],
            },
          ],
          limit: parseInt(limit),
          offset: parseInt(offset),
          order: [['createdAt', 'DESC']],
        },
      ],
    });

    if (!hashtag) {
      return res.status(404).json({
        success: false,
        message: 'Hashtag bulunamadı',
        error: { code: 'HASHTAG_NOT_FOUND' },
      });
    }

    res.json({
      success: true,
      data: hashtag,
    });
  } catch (error) {
    console.error('Error fetching todos by hashtag:', error);
    res.status(500).json({
      success: false,
      message: 'Hashtag\'e ait todolar alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};
