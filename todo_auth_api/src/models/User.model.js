import { DataTypes } from 'sequelize';
// Import the sequelize connection from db.js
import sequelize from '../../db.js';

// Define the User model
const User = sequelize.define('User', {
  // Model attributes (table columns) are defined here
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false, // This column cannot be empty
    unique: true, // Each email must be unique
    validate: {
      isEmail: true, // Sequelize will automatically validate the email format
    },
  },
  // API_CONTRACT'a göre eklendi
  username: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
  },
  // API_CONTRACT'a göre password -> password_hash olarak güncellendi
  password_hash: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
}, {
  // Other model options
  tableName: 'users', // Explicitly tell Sequelize the table name
  timestamps: true, // Automatically manage createdAt and updatedAt columns
});

// Export the model
export default User;