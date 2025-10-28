import { DataTypes } from 'sequelize';
// Import the sequelize connection from db.js
// '../' means 'go up one directory' (from models/ to the root)
import sequelize from '../db.js'; 

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
  // NOTE: Your original server.js did not have a 'username'.
  // If your 'users' table in the database *does* have a username column,
  // you MUST add it here.
  // username: {
  //   type: DataTypes.STRING,
  //   allowNull: false,
  //   unique: true
  // },
  password: {
    type: DataTypes.STRING,
    allowNull: false, // This column cannot be empty
  },
}, {
  // Other model options
  tableName: 'users', // Explicitly tell Sequelize the table name
  timestamps: true, // Automatically manage createdAt and updatedAt columns
});

// Export the model
export default User;