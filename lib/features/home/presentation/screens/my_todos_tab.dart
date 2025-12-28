import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';
import 'package:todo_social/data/models/routine_model.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/routine/presentation/providers/routine_provider.dart';
import 'package:todo_social/core/theme/app_colors.dart';
import 'package:todo_social/features/social/presentation/widgets/comment_section.dart';

class MyTodosTab extends ConsumerStatefulWidget {
  const MyTodosTab({super.key});

  @override
  ConsumerState<MyTodosTab> createState() => _MyTodosTabState();
}

class _MyTodosTabState extends ConsumerState<MyTodosTab> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() async {
        await ref.read(todoProvider.notifier).fetchMyTodos();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final List<TodoModel> allTodos = todoState.todos;
    final List<RoutineModel> routines = todoState.routines;

    // Only show active todos (completed todos are now in profile)
    final activeTodos = allTodos.where((t) => !t.isCompleted).toList();

    if (todoState.isLoading && allTodos.isEmpty && routines.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todoState.errorMessage != null &&
        allTodos.isEmpty &&
        routines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Hata: ${todoState.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(todoProvider.notifier).fetchMyTodos(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (allTodos.isEmpty && routines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz görev veya rutin yok',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '+ butonuna basarak ekleyin',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Combine active todos and routines
    final activeItems = [
      ...activeTodos.map((t) => {'kind': 'todo', 'todo': t}),
      ...routines.map((r) => {'kind': 'routine', 'routine': r}),
    ];

    return RefreshIndicator(
      onRefresh: () => ref.read(todoProvider.notifier).fetchMyTodos(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card about completed todos in profile
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tamamlanan görevlerinizi profil sayfanızda görebilirsiniz',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Active todos and routines
          ...activeItems.map((data) {
            if (data['kind'] == 'routine') {
              final r = data['routine'] as RoutineModel;
              return _buildRoutineCard(r);
            } else {
              final t = data['todo'] as TodoModel;
              return _buildTodoCard(t, context);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(RoutineModel r) {
    return Dismissible(
      key: ValueKey('routine_${r.id}'),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Complete routine (swipe right)
          try {
            await ref.read(routineProvider.notifier).completeRoutine(r.id);
            await ref.read(todoProvider.notifier).fetchMyTodos();
            if (context.mounted) {
              final recurrenceText = _getRecurrenceText(r.recurrenceType).toLowerCase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rutin tamamlandı! $recurrenceText tekrar görünecek.'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            return true; // Remove from list
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hata: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return false;
          }
        } else {
          // Delete routine (swipe left)
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Rutini Sil'),
              content: Text(
                '"${r.title}" rutinini silmek istediğinize emin misiniz?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Sil', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (shouldDelete == true) {
            try {
              await ref.read(routineProvider.notifier).removeRoutine(r.id);
              await ref.read(todoProvider.notifier).fetchMyTodos();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rutin silindi'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
          return false; // We handle deletion manually
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.green.shade50,
        child: ListTile(
          leading: const Icon(Icons.repeat, color: Colors.green),
          title: Text(
            r.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Tekrar: ${_getRecurrenceText(r.recurrenceType)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              if (r.description != null && r.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  r.description!,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '♻️ Bu rutin ${_getRecurrenceText(r.recurrenceType).toLowerCase()} tekrarlanır',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          trailing: r.isPublic
              ? const Icon(Icons.public, color: Colors.grey, size: 20)
              : const Icon(Icons.lock, color: Colors.grey, size: 20),
        ),
      ),
    );
  }

  String _getRecurrenceText(String recurrenceType) {
    switch (recurrenceType.toLowerCase()) {
      case 'daily':
        return 'Her Gün';
      case 'weekly':
        return 'Her Hafta';
      case 'custom':
        return 'Özel';
      default:
        return recurrenceType;
    }
  }

  Widget _buildTodoCard(TodoModel t, BuildContext context) {
    return Dismissible(
      key: ValueKey('todo_${t.id}'),
      background: Container(
        color: t.isCompleted ? Colors.redAccent : Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          t.isCompleted ? Icons.undo : Icons.check,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Toggle complete (sola kaydır)
          await ref
              .read(todoProvider.notifier)
              .toggleTodo(t.id, !t.isCompleted);
          return false;
        } else {
          // Delete (sağa kaydır)
          await ref.read(todoProvider.notifier).removeTodo(t.id);
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: t.isCompleted,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(todoProvider.notifier).toggleTodo(t.id, val);
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        if (t.category != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: t.category!.color != null
                                    ? Color(int.parse(t.category!.color!.replaceFirst('#', '0xFF')))
                                        .withOpacity(0.15)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (t.category!.icon != null)
                                    Text(t.category!.icon!, style: const TextStyle(fontSize: 12)),
                                  if (t.category!.icon != null) const SizedBox(width: 3),
                                  Text(
                                    t.category!.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: t.category!.color != null
                                          ? Color(int.parse(t.category!.color!.replaceFirst('#', '0xFF')))
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Text(
                          t.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: t.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (t.description != null && t.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              t.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        // Hashtags
                        if (t.hashtags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 3,
                              children: t.hashtags.map((h) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#${h.tag}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        // Show "from username" if copied
                        if (t.originalAuthor != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: InkWell(
                              onTap: () {
                                final username = t.originalAuthor!['username'];
                                if (username != null) {
                                  context
                                      .push(Routes.userProfilePath(username));
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy_all,
                                    size: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'from @${t.originalAuthor!['username']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  t.isPublic
                      ? const Icon(Icons.public, color: Colors.grey, size: 20)
                      : const Icon(Icons.lock, color: Colors.grey, size: 20),
                ],
              ),
              // Action buttons (like and comment)
              const Divider(height: 24),
              Row(
                children: [
                  // Like button
                  IconButton(
                    icon: Icon(
                      t.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: t.isLiked ? AppColors.like : Colors.grey,
                    ),
                    onPressed: () async {
                      try {
                        await ref.read(todoProvider.notifier).toggleLike(t.id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  if (t.likeCount > 0)
                    InkWell(
                      onTap: () {
                        context.push(Routes.todoLikesPath(t.id));
                      },
                      child: Text(
                        '${t.likeCount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  // Comment button
                  IconButton(
                    icon: Icon(Icons.comment_outlined, color: Colors.grey.shade600),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CommentSection(todoId: t.id),
                      );
                    },
                  ),
                  if (t.commentCount > 0)
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CommentSection(todoId: t.id),
                        );
                      },
                      child: Text(
                        '${t.commentCount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
