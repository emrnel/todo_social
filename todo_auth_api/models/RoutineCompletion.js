import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const RoutineCompletion = sequelize.define('RoutineCompletion', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  routineId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'routines',
      key: 'id',
    },
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id',
    },
  },
  completedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
}, {
  timestamps: true,
  tableName: 'routine_completions',
  indexes: [
    {
      unique: false,
      fields: ['routineId', 'userId', 'completedAt'],
    },
  ],
});

export default RoutineCompletion;
