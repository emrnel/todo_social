import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Category = sequelize.define('Category', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  icon: {
    type: DataTypes.STRING(50),
    allowNull: true,
    comment: 'Emoji or icon name for the category',
  },
  color: {
    type: DataTypes.STRING(20),
    allowNull: true,
    comment: 'Hex color code for the category',
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'categories',
  timestamps: true,
});

export default Category;
