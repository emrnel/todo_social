import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Badge = sequelize.define('Badge', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  icon: {
    type: DataTypes.STRING(50),
    allowNull: true,
    comment: 'Emoji or icon name for the badge',
  },
  condition: {
    type: DataTypes.STRING(50),
    allowNull: false,
    comment: 'Type of achievement: todos_completed, streak_days, followers_count, likes_received',
  },
  threshold: {
    type: DataTypes.INTEGER,
    allowNull: false,
    comment: 'Required value to unlock this badge',
  },
  tier: {
    type: DataTypes.STRING(20),
    allowNull: true,
    comment: 'Bronze, Silver, Gold, Platinum',
  },
}, {
  tableName: 'badges',
  timestamps: true,
});

export default Badge;
