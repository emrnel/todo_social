import sequelize from '../db.js';
import { QueryInterface } from 'sequelize';

/**
 * Migration script to add new columns to existing tables
 * Run this with: node scripts/migrate.js
 */

async function migrate() {
  try {
    await sequelize.authenticate();
    console.log('✓ Database connected successfully.');

    const queryInterface = sequelize.getQueryInterface();

    console.log('\n📦 Starting migration...\n');

    // Check if columns exist before adding them
    const tableDescription = await queryInterface.describeTable('users');

    // Migrate Users table
    console.log('1️⃣ Migrating Users table...');

    if (!tableDescription.bannerPicture) {
      await queryInterface.addColumn('users', 'bannerPicture', {
        type: sequelize.Sequelize.STRING(500),
        allowNull: true,
      });
      console.log('  ✓ Added bannerPicture column');
    }

    if (!tableDescription.theme) {
      await queryInterface.addColumn('users', 'theme', {
        type: sequelize.Sequelize.STRING(20),
        defaultValue: 'light',
      });
      console.log('  ✓ Added theme column');
    }

    if (!tableDescription.themeColor) {
      await queryInterface.addColumn('users', 'themeColor', {
        type: sequelize.Sequelize.STRING(20),
        defaultValue: 'blue',
      });
      console.log('  ✓ Added themeColor column');
    }

    if (!tableDescription.xp) {
      await queryInterface.addColumn('users', 'xp', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added xp column');
    }

    if (!tableDescription.level) {
      await queryInterface.addColumn('users', 'level', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 1,
      });
      console.log('  ✓ Added level column');
    }

    if (!tableDescription.currentStreak) {
      await queryInterface.addColumn('users', 'currentStreak', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added currentStreak column');
    }

    if (!tableDescription.longestStreak) {
      await queryInterface.addColumn('users', 'longestStreak', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added longestStreak column');
    }

    if (!tableDescription.lastActivityDate) {
      await queryInterface.addColumn('users', 'lastActivityDate', {
        type: sequelize.Sequelize.DATEONLY,
        allowNull: true,
      });
      console.log('  ✓ Added lastActivityDate column');
    }

    if (!tableDescription.todosCompletedCount) {
      await queryInterface.addColumn('users', 'todosCompletedCount', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added todosCompletedCount column');
    }

    if (!tableDescription.followersCount) {
      await queryInterface.addColumn('users', 'followersCount', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added followersCount column');
    }

    if (!tableDescription.followingCount) {
      await queryInterface.addColumn('users', 'followingCount', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added followingCount column');
    }

    // Migrate Todos table
    console.log('\n2️⃣ Migrating Todos table...');
    const todoDescription = await queryInterface.describeTable('todos');

    if (!todoDescription.categoryId) {
      await queryInterface.addColumn('todos', 'categoryId', {
        type: sequelize.Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'categories',
          key: 'id',
        },
      });
      console.log('  ✓ Added categoryId column');
    }

    if (!todoDescription.completedAt) {
      await queryInterface.addColumn('todos', 'completedAt', {
        type: sequelize.Sequelize.DATE,
        allowNull: true,
      });
      console.log('  ✓ Added completedAt column');
    }

    if (!todoDescription.commentCount) {
      await queryInterface.addColumn('todos', 'commentCount', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added commentCount column');
    }

    if (!todoDescription.copyCount) {
      await queryInterface.addColumn('todos', 'copyCount', {
        type: sequelize.Sequelize.INTEGER,
        defaultValue: 0,
      });
      console.log('  ✓ Added copyCount column');
    }

    console.log('\n✅ Migration completed successfully!\n');
    console.log('You can now start the server with: npm start');

    process.exit(0);
  } catch (error) {
    console.error('\n❌ Migration failed:', error);
    process.exit(1);
  }
}

migrate();
