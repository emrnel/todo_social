import User from './User.js';
import Todo from './Todo.js';
import Routine from './Routine.js';
import RoutineCompletion from './RoutineCompletion.js';
import Follow from './Follow.js';
import TodoLike from './TodoLike.js';
import Comment from './Comment.js';
import Category from './Category.js';
import Hashtag from './Hashtag.js';
import TodoHashtag from './TodoHashtag.js';
import Badge from './Badge.js';
import UserBadge from './UserBadge.js';
import Notification from './Notification.js';

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

  // Comment associations
  User.hasMany(Comment, { foreignKey: 'userId', as: 'comments' });
  Comment.belongsTo(User, { foreignKey: 'userId', as: 'user' });

  Todo.hasMany(Comment, { foreignKey: 'todoId', as: 'comments' });
  Comment.belongsTo(Todo, { foreignKey: 'todoId', as: 'todo' });

  // Category-Todo associations
  Category.hasMany(Todo, { foreignKey: 'categoryId', as: 'todos' });
  Todo.belongsTo(Category, { foreignKey: 'categoryId', as: 'category' });

  // Todo-Hashtag associations (many-to-many)
  Todo.belongsToMany(Hashtag, {
    through: TodoHashtag,
    as: 'hashtags',
    foreignKey: 'todoId',
    otherKey: 'hashtagId',
  });

  Hashtag.belongsToMany(Todo, {
    through: TodoHashtag,
    as: 'todos',
    foreignKey: 'hashtagId',
    otherKey: 'todoId',
  });

  // User-Badge associations (many-to-many)
  User.belongsToMany(Badge, {
    through: UserBadge,
    as: 'badges',
    foreignKey: 'userId',
    otherKey: 'badgeId',
  });

  Badge.belongsToMany(User, {
    through: UserBadge,
    as: 'users',
    foreignKey: 'badgeId',
    otherKey: 'userId',
  });

  // UserBadge direct associations
  UserBadge.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  UserBadge.belongsTo(Badge, { foreignKey: 'badgeId', as: 'badge' });

  // Notification associations
  Notification.belongsTo(User, { foreignKey: 'userId', as: 'recipient' });
  Notification.belongsTo(User, { foreignKey: 'actorId', as: 'actor' });
  Notification.belongsTo(Todo, { foreignKey: 'todoId', as: 'todo' });
  Notification.belongsTo(Comment, { foreignKey: 'commentId', as: 'comment' });
  Notification.belongsTo(Badge, { foreignKey: 'badgeId', as: 'badge' });

  User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });

  // Routine-RoutineCompletion associations
  Routine.hasMany(RoutineCompletion, { foreignKey: 'routineId', as: 'completions' });
  RoutineCompletion.belongsTo(Routine, { foreignKey: 'routineId', as: 'routine' });

  User.hasMany(RoutineCompletion, { foreignKey: 'userId', as: 'routineCompletions' });
  RoutineCompletion.belongsTo(User, { foreignKey: 'userId', as: 'user' });
};

export default setupAssociations;
