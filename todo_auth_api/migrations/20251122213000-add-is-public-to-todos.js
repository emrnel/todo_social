'use strict';

/**
 * Migration to ensure 'isPublic' exists on todos table.
 */
export async function up(queryInterface, Sequelize) {
  let tableDescription;
  try {
    tableDescription = await queryInterface.describeTable('todos');
  } catch (err) {
    // Table missing: create minimal todos table
    await queryInterface.createTable('todos', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      userId: { type: Sequelize.INTEGER, allowNull: false },
      title: { type: Sequelize.STRING, allowNull: false },
      description: { type: Sequelize.TEXT, allowNull: true },
      isCompleted: { type: Sequelize.BOOLEAN, allowNull: false, defaultValue: false },
      isPublic: { type: Sequelize.BOOLEAN, allowNull: false, defaultValue: false },
      createdAt: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') },
      updatedAt: { type: Sequelize.DATE, allowNull: false, defaultValue: Sequelize.literal('CURRENT_TIMESTAMP') }
    });
    return;
  }

  if (!tableDescription.isPublic) {
    await queryInterface.addColumn('todos', 'isPublic', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
      after: 'isCompleted'
    });
  }
}

export async function down(queryInterface, Sequelize) {
  await queryInterface.removeColumn('todos', 'isPublic');
}
