"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // Make idempotent: add column only if missing
    let tableDescription;
    try {
      tableDescription = await queryInterface.describeTable('users');
    } catch (err) {
      // Table missing: create minimal users table including username
      await queryInterface.createTable('users', {
        id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
        email: { type: Sequelize.STRING, allowNull: false, unique: true },
        password_hash: { type: Sequelize.STRING, allowNull: false },
        username: { type: Sequelize.STRING(50), allowNull: true, unique: true },
        createdAt: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
        updatedAt: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
      });
      return;
    }

    if (!tableDescription.username) {
      await queryInterface.addColumn('users', 'username', {
        type: Sequelize.STRING(50),
        allowNull: true,
        unique: true,
      });
    }
  },

  async down(queryInterface, Sequelize) {
    const tableDescription = await queryInterface.describeTable('users');
    if (tableDescription.username) {
      await queryInterface.removeColumn('users', 'username');
    }
  }
};
