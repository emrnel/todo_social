import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Todo = sequelize.define('Todo', {
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
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  isCompleted: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  isPublic: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  likeCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  originalAuthorId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'users',
      key: 'id',
    },
  },
  categoryId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'categories',
      key: 'id',
    },
  },
  completedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: 'Timestamp when the todo was completed',
  },
  commentCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  copyCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Number of times this todo has been copied',
  },
}, {
  tableName: 'todos',
  timestamps: true,
});

export default Todo;
