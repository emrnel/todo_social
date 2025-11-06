import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

// .env dosyasındaki ortam değişkenlerini yükle
dotenv.config();

// Initialize Sequelize
const sequelize = new Sequelize(
  process.env.DB_NAME, // Database name (from .env)
  process.env.DB_USER, // Database user (from .env)
  process.env.DB_PASSWORD, // Database password (from .env)
  {
    host: process.env.DB_HOST, // Database host (from .env)
    dialect: 'mysql', // Kullandığımız veritabanı türü

    // logging: false, // Uncomment this to stop seeing SQL queries in console
    // SQL sorgularını konsolda görmemek için bu satırı açabilirsiniz
    // logging: false,
  }
);

// Export the sequelize instance
export default sequelize;