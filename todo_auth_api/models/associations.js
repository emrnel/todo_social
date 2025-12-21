import User from './User.js';
import Todo from './Todo.js';
import Routine from './Routine.js';
import Follow from './Follow.js';
import TodoLike from './TodoLike.js';

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

  // Todo-User Like associations (many-to-many through TodoLike)
  Todo.belongsToMany(User, {
    through: TodoLike,
    as: 'likedByUsers',
    foreignKey: 'todoId',
    otherKey: 'userId',
  });

  User.belongsToMany(Todo, {
    through: TodoLike,
    as: 'likedTodos',
    foreignKey: 'userId',
    otherKey: 'todoId',
  });

  // TodoLike associations
  TodoLike.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  TodoLike.belongsTo(Todo, { foreignKey: 'todoId', as: 'todo' });
  
  // Original author association for copied todos
  Todo.belongsTo(User, { 
    foreignKey: 'originalAuthorId', 
    as: 'originalAuthor' 
  });
};

export default setupAssociations;
