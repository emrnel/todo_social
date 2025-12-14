import User from './User.js';
import Todo from './Todo.js';
import Follow from './Follow.js';
import Routine from './Routine.js';

const setupAssociations = () => {
  // User-Todo Relationship (One-to-Many)
  // A user can have many todos.
  User.hasMany(Todo, { as: 'Todos', foreignKey: 'userId', onDelete: 'CASCADE' });
  // A todo belongs to one user.
  Todo.belongsTo(User, { as: 'author', foreignKey: 'userId' });

  // User-User Relationship (Many-to-Many for Followers)
  // A user can follow many other users.
  User.belongsToMany(User, {
    as: 'Following', // user.getFollowing()
    through: Follow,
    foreignKey: 'followerId', // The key in the Follow table that points to the source user (the one doing the following)
    otherKey: 'followingId', // The key in the Follow table that points to the target user (the one being followed)
  });

  // A user can be followed by many other users.
  User.belongsToMany(User, {
    as: 'Followers', // user.getFollowers()
    through: Follow,
    foreignKey: 'followingId', // The key in the Follow table that points to the source user (the one being followed)
    otherKey: 'followerId', // The key in the Follow table that points to the target user (the one doing the following)
  });

  // User-Routine Relationship (One-to-Many)
  // A user can have many routines.
  User.hasMany(Routine, { as: 'Routines', foreignKey: 'userId', onDelete: 'CASCADE' });
  Routine.belongsTo(User, { as: 'owner', foreignKey: 'userId' });
};

export default setupAssociations;