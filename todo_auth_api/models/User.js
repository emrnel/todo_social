import { DataTypes } from 'sequelize';
import sequelize from '../db.js'; 

const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true,
    },
  },
  username: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  password_hash: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  profilePicture: {
    type: DataTypes.STRING(500),
    allowNull: true,
  },
  bannerPicture: {
    type: DataTypes.STRING(500),
    allowNull: true,
    comment: 'Profile banner/cover photo',
  },
  theme: {
    type: DataTypes.STRING(20),
    defaultValue: 'light',
    comment: 'User theme preference: light, dark',
  },
  themeColor: {
    type: DataTypes.STRING(20),
    defaultValue: 'blue',
    comment: 'Theme color: blue, purple, green, pink',
  },
  xp: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Experience points',
  },
  level: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    comment: 'User level based on XP',
  },
  currentStreak: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Current consecutive days with completed todos',
  },
  longestStreak: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Longest streak ever achieved',
  },
  lastActivityDate: {
    type: DataTypes.DATEONLY,
    allowNull: true,
    comment: 'Last date user completed a todo (for streak tracking)',
  },
  todosCompletedCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Total number of todos completed',
  },
  followersCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  followingCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
}, {
  tableName: 'users',
  timestamps: true,
});

export default User;
