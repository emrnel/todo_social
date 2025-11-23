/**
 * Migration to add username column to users table (ES module version)
 */
export async function up(queryInterface, Sequelize) {
  // Make migration idempotent: check if column already exists
  let tableDescription;
  try {
    tableDescription = await queryInterface.describeTable('users');
  } catch (err) {
    // If table doesn't exist, create minimal users table with username
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
}

export async function down(queryInterface, Sequelize) {
  // Guard removal if column exists
  const tableDescription = await queryInterface.describeTable('users');
  if (tableDescription.username) {
    await queryInterface.removeColumn('users', 'username');
  }
}