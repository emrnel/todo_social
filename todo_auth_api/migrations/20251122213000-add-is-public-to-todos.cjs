'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Ensure the 'todos' table exists. If not, create it with the expected schema.
    let tableDescription;
    try {
      tableDescription = await queryInterface.describeTable('todos');
    } catch (err) {
      // Table does not exist -> create it
      await queryInterface.createTable('todos', {
        id: {
          type: Sequelize.INTEGER,
          autoIncrement: true,
          primaryKey: true,
        },
        userId: {
          type: Sequelize.INTEGER,
          allowNull: false,
          references: { model: 'users', key: 'id' },
          onDelete: 'CASCADE',
        },
        title: {
          type: Sequelize.STRING,
          allowNull: false,
        },
        description: {
          type: Sequelize.TEXT,
          allowNull: true,
        },
        isCompleted: {
          type: Sequelize.BOOLEAN,
          allowNull: false,
          defaultValue: false,
        },
        isPublic: {
          type: Sequelize.BOOLEAN,
          allowNull: false,
          defaultValue: false,
        },
        createdAt: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        },
        updatedAt: {
          type: Sequelize.DATE,
          allowNull: false,
          defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
        }
      });
      return;
    }

    // If the table exists, add the column only if missing
    if (!tableDescription.isPublic) {
      await queryInterface.addColumn('todos', 'isPublic', {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
        after: 'isCompleted'
      });
    }
  },

  async down (queryInterface, Sequelize) {
    // Bu fonksiyon, 'isPublic' sütununu kaldırır.
    await queryInterface.removeColumn('todos', 'isPublic');
  }
};
