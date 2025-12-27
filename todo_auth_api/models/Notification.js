import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Notification = sequelize.define('Notification', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id',
    },
    comment: 'User who receives the notification',
  },
  actorId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'users',
      key: 'id',
    },
    comment: 'User who triggered the notification',
  },
  type: {
    type: DataTypes.STRING(50),
    allowNull: false,
    comment: 'like, comment, follow, badge_earned, mention, todo_copied',
  },
  todoId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'todos',
      key: 'id',
    },
  },
  commentId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'comments',
      key: 'id',
    },
  },
  badgeId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'badges',
      key: 'id',
    },
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  isRead: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  tableName: 'notifications',
  timestamps: true,
});

export default Notification;
