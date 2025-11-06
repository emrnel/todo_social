// --- IMPORTS ---

// Import the 'Sequelize' class from the sequelize library
import { Sequelize } from 'sequelize';
// Import 'dotenv' to load environment variables from the .env file
import dotenv from 'dotenv';

// --- CONFIGURATION ---

// Load environment variables from the .env file into process.env
// This makes process.env.DB_NAME, process.env.DB_USER, etc., available.
dotenv.config();

// --- DATABASE CONNECTION ---

// Retrieve database configuration from environment variables
const dbName = process.env.DB_NAME || 'todo_db';
const dbUser = process.env.DB_USER || 'root';
const dbPass = process.env.DB_PASS || '1234'; // Default to empty string if not set
const dbHost = process.env.DB_HOST || 'localhost';

/**
 * Create a new Sequelize instance.
 * This object represents the connection to the database.
 * Other files (like models) will import this instance.
 */
const sequelize = new Sequelize(
  dbName, // 1. Database name
  dbUser, // 2. Database user
  dbPass, // 3. Database password
  {
    host: dbHost, // 4. Database host (e.g., 'localhost')
    dialect: 'mysql', // 5. Specify that we are using MySQL

    // Optional: Logging configuration
    // Set to 'false' to stop Sequelize from printing every SQL query to the console.
    // This makes the console much cleaner.
    logging: false,
    // logging: console.log, // Uncomment this line to see all SQL queries
  }
);

// --- EXPORT ---

/**
 * Export the configured sequelize instance as the default export.
 * This allows other files to import it using:
 * import sequelize from './config/sequelize.js';
 */
export default sequelize;

