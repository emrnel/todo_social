/**
 * Migration to add isRoutineCompletion and routineId columns to todos table
 * This allows distinguishing routine completions from regular todos
 */

export async function up(queryInterface, Sequelize) {
  await queryInterface.addColumn('todos', 'isRoutineCompletion', {
    type: Sequelize.BOOLEAN,
    defaultValue: false,
    comment: 'True if this todo represents a routine completion',
  });

  await queryInterface.addColumn('todos', 'routineId', {
    type: Sequelize.INTEGER,
    allowNull: true,
    references: {
      model: 'routines',
      key: 'id',
    },
    onUpdate: 'CASCADE',
    onDelete: 'SET NULL',
    comment: 'Reference to the routine if this is a routine completion',
  });
}

export async function down(queryInterface, Sequelize) {
  await queryInterface.removeColumn('todos', 'routineId');
  await queryInterface.removeColumn('todos', 'isRoutineCompletion');
}
