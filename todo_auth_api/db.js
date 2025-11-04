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
// .env dosyasındaki ortam değişkenlerini yükle
dotenv.config();

// Initialize Sequelize
const sequelize = new Sequelize(
  process.env.DB_NAME,    // Database name (from .env)
  process.env.DB_USER,    // Database user (from .env)
  process.env.DB_PASSWORD,  // Database password (from .env)
  process.env.DB_NAME,      // Veritabanı adı (.env dosyasından)
  process.env.DB_USER,      // Veritabanı kullanıcısı (.env dosyasından)
  process.env.DB_PASSWORD,    // Veritabanı şifresi (.env dosyasından)
  {
    host: process.env.DB_HOST, // Database host (from .env)
    
    // THE FIX: Must be 'postgres' to match your 'pg' package.
    dialect: 'mysql', 
    
    // logging: false, // Uncomment this to stop seeing SQL queries in console
    host: process.env.DB_HOST,   // Veritabanı sunucusu (.env dosyasından)
    dialect: 'mysql',            // Kullandığımız veritabanı türü

    // SQL sorgularını konsolda görmemek için bu satırı açabilirsiniz
    // logging: false,
  }
);

// Export the sequelize instance
export default sequelize;