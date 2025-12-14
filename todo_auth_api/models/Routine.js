import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Routine = sequelize.define('Routine', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
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
  isPublic: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  recurrenceType: {
    type: DataTypes.STRING, // 'daily', 'weekly', 'custom'
    allowNull: false,
    defaultValue: 'daily',
  },
  recurrenceValue: {
    type: DataTypes.STRING, // e.g. "['mon', 'wed']"
    allowNull: true,
  },
}, {
  timestamps: true,
  tableName: 'routines',
});

export default Routine;