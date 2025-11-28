import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

// .env dosyasındaki ortam değişkenlerini yükle
dotenv.config();

// Initialize Sequelize with SQLite
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './database.sqlite', // SQLite veritabanı dosyası
  logging: false, // SQL loglarını kapat (debug için true yapabilirsiniz)
});

// Export the sequelize instance
export default sequelize;
