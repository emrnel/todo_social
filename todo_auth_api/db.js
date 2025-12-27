import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

// DEBUG: URL'i görelim
console.log('🔍 DATABASE_URL:', process.env.DATABASE_URL);
console.log('🔍 .env yolu:', process.cwd());

// Railway PostgreSQL ile bağlan
const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  },
  logging: console.log  // SQL sorgularını göster
});

export default sequelize;
