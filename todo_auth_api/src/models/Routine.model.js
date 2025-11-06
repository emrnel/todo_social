import { DataTypes } from 'sequelize';
import sequelize from '../../db.js';

const Routine = sequelize.define(
  'Routine',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    title: {
      type: DataTypes.STRING(200),
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
      type: DataTypes.ENUM('daily', 'weekly', 'custom'),
      allowNull: false,
    },
    recurrenceValue: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
  },
  {
    tableName: 'routines',
    timestamps: true,
  }
);

export default Routine;