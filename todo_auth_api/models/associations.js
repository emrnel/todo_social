import User from './User.js';
import Todo from './Todo.js';
import Routine from './Routine.js';
import Follow from './Follow.js';

const setupAssociations = () => {
  // User-Todo associations
  User.hasMany(Todo, { foreignKey: 'userId', as: 'todos' });
  Todo.belongsTo(User, { foreignKey: 'userId', as: 'author' });

  // User-Routine associations
  User.hasMany(Routine, { foreignKey: 'userId', as: 'routines' });
  Routine.belongsTo(User, { foreignKey: 'userId', as: 'author' });

  // User-Follow associations (self-referencing many-to-many)
  User.belongsToMany(User, {
    through: Follow,
    as: 'followers',
    foreignKey: 'followingId',
    otherKey: 'followerId',
  });

  User.belongsToMany(User, {
    through: Follow,
    as: 'following',
    foreignKey: 'followerId',
    otherKey: 'followingId',
  });
};

export default setupAssociations;
