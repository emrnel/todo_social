// lib/core/navigation/routes.dart

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String myProfile = '/profile';
  static const String addTodo = '/add-todo';
  static const String addRoutine = '/add-routine';

  // FE-CORE-32: Add search route
  static const String search = '/search';

  // FE-CORE-35: Add userProfile dynamic route
  static const String userProfile = '/user/:username';

  // Helper method to build userProfile path
  static String userProfilePath(String username) => '/user/$username';
}
