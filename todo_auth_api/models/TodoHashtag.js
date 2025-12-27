import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

// Junction table for Many-to-Many relationship between Todos and Hashtags
const TodoHashtag = sequelize.define('TodoHashtag', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  todoId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'todos',
      key: 'id',
    },
  },
  hashtagId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'hashtags',
      key: 'id',
    },
  },
}, {
  tableName: 'todo_hashtags',
  timestamps: true,
  indexes: [
    {
      unique: true,
      fields: ['todoId', 'hashtagId'],
    },
  ],
});

export default TodoHashtag;
