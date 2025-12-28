import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

// Railway PostgreSQL database
const sequelize = new Sequelize(
  'postgresql://postgres:GHCawGmKxgdNTXmiGnTMtDuqtnxdkvgE@crossover.proxy.rlwy.net:11605/railway',
  {
    dialect: 'postgres',
    logging: false,
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    },
  }
);

export default sequelize;
