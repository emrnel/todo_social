// lib/core/navigation/routes.dart

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String myProfile = '/profile';
  static const String addTodo = '/add-todo';
  static const String addRoutine = '/add-routine';
  static const String routines = '/routines';

  // FE-CORE-32: Add search route
  static const String search = '/search';

  // FE-CORE-35: Add userProfile dynamic route
  static const String userProfile = '/user/:username';

  // Helper method to build userProfile path
  static String userProfilePath(String username) => '/user/$username';

  // Gamification routes
  static const String notifications = '/notifications';
  static const String statistics = '/statistics';
  static const String badges = '/badges';
  static const String leaderboard = '/leaderboard';

  // Todo routes
  static const String todoLikes = '/todo/:id/likes';

  // Helper method to build todoLikes path
  static String todoLikesPath(int todoId) => '/todo/$todoId/likes';

  // Social routes
  static const String usersList = '/users/:userId/:listType';

  // Helper method to build usersList path
  static String usersListPath(int userId, String listType) =>
      '/users/$userId/$listType';
}
