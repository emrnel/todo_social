/**
 * Migration to update profilePicture and bannerPicture columns from VARCHAR(500) to TEXT
 * This allows storing base64 encoded images of any size
 */

export async function up(queryInterface, Sequelize) {
  await queryInterface.changeColumn('users', 'profilePicture', {
    type: Sequelize.TEXT,
    allowNull: true,
    comment: 'Profile picture (can be URL or base64 data URI)',
  });

  await queryInterface.changeColumn('users', 'bannerPicture', {
    type: Sequelize.TEXT,
    allowNull: true,
    comment: 'Profile banner/cover photo (can be URL or base64 data URI)',
  });
}

export async function down(queryInterface, Sequelize) {
  // Revert back to VARCHAR(500)
  await queryInterface.changeColumn('users', 'profilePicture', {
    type: Sequelize.STRING(500),
    allowNull: true,
  });

  await queryInterface.changeColumn('users', 'bannerPicture', {
    type: Sequelize.STRING(500),
    allowNull: true,
  });
}
