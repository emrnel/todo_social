export async function up(queryInterface, Sequelize) {
  try {
    await queryInterface.changeColumn('users', 'profilePicture', {
      type: Sequelize.TEXT,
      allowNull: true,
      comment: 'Profile picture (URL or base64 data URI)',
    });
  } catch (e) {
    console.log('profilePicture already TEXT or error:', e.message);
  }

  try {
    await queryInterface.changeColumn('users', 'bannerPicture', {
      type: Sequelize.TEXT,
      allowNull: true,
      comment: 'Banner picture (URL or base64 data URI)',
    });
  } catch (e) {
    console.log('bannerPicture already TEXT or error:', e.message);
  }
}

export async function down(queryInterface, Sequelize) {
  await queryInterface.changeColumn('users', 'profilePicture', {
    type: Sequelize.STRING(500),
    allowNull: true,
  });

  await queryInterface.changeColumn('users', 'bannerPicture', {
    type: Sequelize.STRING(500),
    allowNull: true,
  });
}
