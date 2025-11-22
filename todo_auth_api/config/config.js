// We use .cjs because the project type is "module", but Sequelize CLI works best with CommonJS.
require('dotenv').config();

module.exports = {
  development: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    dialect: 'mysql'
  }
  // You can add 'test' and 'production' environments here later.
};