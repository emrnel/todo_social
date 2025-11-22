const path = require('path');

// This file tells the Sequelize CLI where to find things.
module.exports = {
  'config': path.resolve(__dirname, 'config', 'config.cjs'),
  'models-path': path.resolve('models'),
  'seeders-path': path.resolve('seeders'),
  'migrations-path': path.resolve('migrations')
};