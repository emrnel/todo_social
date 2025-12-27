import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

// Junction table for Many-to-Many relationship between Users and Badges
const UserBadge = sequelize.define('UserBadge', {
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
  badgeId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'badges',
      key: 'id',
    },
  },
  earnedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'user_badges',
  timestamps: false,
  indexes: [
    {
      unique: true,
      fields: ['userId', 'badgeId'],
    },
  ],
});

export default UserBadge;
