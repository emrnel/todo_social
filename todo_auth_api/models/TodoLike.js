import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const TodoLike = sequelize.define('TodoLike', {
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
  todoId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'todos',
      key: 'id',
    },
  },
}, {
  tableName: 'todo_likes',
  timestamps: true,
  updatedAt: false,
  indexes: [
    {
      unique: true,
      fields: ['userId', 'todoId'],
    },
  ],
});

export default TodoLike;
