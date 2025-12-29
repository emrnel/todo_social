export async function up(queryInterface, Sequelize) {
  try {
    await queryInterface.addColumn('todos', 'isRoutineCompletion', {
      type: Sequelize.BOOLEAN,
      defaultValue: false,
      comment: 'True if this todo was created from routine completion',
    });
  } catch (e) {
    console.log('isRoutineCompletion already exists');
  }

  try {
    await queryInterface.addColumn('todos', 'routineId', {
      type: Sequelize.INTEGER,
      allowNull: true,
      references: {
        model: 'routines',
        key: 'id',
      },
      comment: 'Reference to source routine',
    });
  } catch (e) {
    console.log('routineId already exists');
  }
}

export async function down(queryInterface, Sequelize) {
  await queryInterface.removeColumn('todos', 'isRoutineCompletion');
  await queryInterface.removeColumn('todos', 'routineId');
}
