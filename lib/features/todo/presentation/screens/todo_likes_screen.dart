import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/data/models/user_model.dart';
import 'package:todo_social/features/todo/data/repositories/todo_repository.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';

final todoLikesProvider = FutureProvider.family<List<UserModel>, int>((ref, todoId) async {
  final repository = ref.watch(todoRepositoryProvider);
  return await repository.getTodoLikes(todoId);
});

class TodoLikesScreen extends ConsumerWidget {
  final int todoId;

  const TodoLikesScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesAsync = ref.watch(todoLikesProvider(todoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beğenenler'),
      ),
      body: likesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Beğenileri yüklerken hata oluştu',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(todoLikesProvider(todoId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz beğeni yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profilePicture != null &&
                          user.profilePicture!.isNotEmpty
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null ||
                          user.profilePicture!.isEmpty
                      ? Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                title: Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: user.bio != null && user.bio!.isNotEmpty
                    ? Text(
                        user.bio!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Lv ${user.level}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  context.push('/profile/${user.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
