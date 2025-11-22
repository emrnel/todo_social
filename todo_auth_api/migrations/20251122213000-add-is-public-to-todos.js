'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Bu fonksiyon, veritabanında 'isPublic' sütununun olup olmadığını kontrol eder.
    // Eğer sütun yoksa ekler, varsa hiçbir şey yapmaz.
    const tableDescription = await queryInterface.describeTable('todos');
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
