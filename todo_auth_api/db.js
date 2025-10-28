import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

// Initialize Sequelize
const sequelize = new Sequelize(
  process.env.DB_NAME,    // Database name (from .env)
  process.env.DB_USER,    // Database user (from .env)
  process.env.DB_PASSWORD,  // Database password (from .env)
  {
    host: process.env.DB_HOST, // Database host (from .env)
    
    // THE FIX: Must be 'postgres' to match your 'pg' package.
    dialect: 'mysql', 
    
    // logging: false, // Uncomment this to stop seeing SQL queries in console
  }
);

// Export the sequelize instance
export default sequelize;