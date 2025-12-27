import Notification from '../models/Notification.js';
import User from '../models/User.js';
import Todo from '../models/Todo.js';
import Badge from '../models/Badge.js';

/**
 * Create a notification
 */
export const createNotification = async (notificationData) => {
  try {
    const notification = await Notification.create(notificationData);
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    return null;
  }
};

/**
 * Get user's notifications
 */
export const getMyNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 20, offset = 0 } = req.query;

    const notifications = await Notification.findAll({
      where: { userId },
      include: [
        {
          model: User,
          as: 'actor',
          attributes: ['id', 'username', 'profilePicture'],
        },
        {
          model: Todo,
          as: 'todo',
          attributes: ['id', 'title'],
        },
        {
          model: Badge,
          as: 'badge',
          attributes: ['id', 'name', 'icon'],
        },
      ],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    const unreadCount = await Notification.count({
      where: { userId, isRead: false },
    });

    res.json({
      success: true,
      data: {
        notifications,
        unreadCount,
      },
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Bildirimler alınırken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Mark notification as read
 */
export const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const notification = await Notification.findOne({
      where: { id, userId },
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Bildirim bulunamadı',
        error: { code: 'NOTIFICATION_NOT_FOUND' },
      });
    }

    notification.isRead = true;
    await notification.save();

    res.json({
      success: true,
      message: 'Bildirim okundu olarak işaretlendi',
    });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      message: 'Bildirim güncellenirken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Mark all notifications as read
 */
export const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;

    await Notification.update(
      { isRead: true },
      { where: { userId, isRead: false } }
    );

    res.json({
      success: true,
      message: 'Tüm bildirimler okundu olarak işaretlendi',
    });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({
      success: false,
      message: 'Bildirimler güncellenirken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};

/**
 * Delete a notification
 */
export const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const notification = await Notification.findOne({
      where: { id, userId },
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Bildirim bulunamadı',
        error: { code: 'NOTIFICATION_NOT_FOUND' },
      });
    }

    await notification.destroy();

    res.json({
      success: true,
      message: 'Bildirim silindi',
    });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      message: 'Bildirim silinirken hata oluştu',
      error: { code: 'INTERNAL_ERROR' },
    });
  }
};
