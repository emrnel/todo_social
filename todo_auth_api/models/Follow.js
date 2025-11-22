import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

// Define the Follow model for the join table
const Follow = sequelize.define('Follow', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  // The ID of the user who is doing the following
  followerId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  // The ID of the user who is being followed
  followingId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
}, {
  tableName: 'followers',
  timestamps: true,    // Automatically manage createdAt
  updatedAt: false,    // but do NOT manage updatedAt
});

export default Follow;