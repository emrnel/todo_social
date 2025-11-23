import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/services/auth_service.dart';

// Export the provider for global access
final authProvider = Provider<AuthService>((ref) {
  return ref.watch(authServiceProvider);
});
