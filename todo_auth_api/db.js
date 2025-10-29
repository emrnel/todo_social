import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

// Create a connection pool
const pool = mysql.createPool({
  host: 'localhost',           // Usually 'localhost'
  user: 'root',     // Your MySQL username
  password: '1234', // Your MySQL passwordd
  database: 'todo_db', // Your MySQL database name
  waitForConnections: true,
  connectionLimit: 10,         // Adjust as needed
  queueLimit: 0
});

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