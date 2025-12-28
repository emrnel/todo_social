import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/data/models/routine_model.dart';
import 'package:todo_social/features/routine/presentation/providers/routine_provider.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';
import 'package:todo_social/core/navigation/routes.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoProvider);
    final routines = todoState.routines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinlerim'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: routines.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz rutin oluşturmadınız',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(Routes.addRoutine),
                    icon: const Icon(Icons.add),
                    label: const Text('Rutin Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return Dismissible(
                  key: ValueKey('routine_${routine.id}'),
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
                      // Complete routine (left swipe)
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rutin tamamlandı olarak işaretlendi! Yarın tekrar görünecek.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      // TODO: Add routine completion API call here when backend supports it
                      return false; // Don't actually remove from list
                    } else {
                      // Delete routine (right swipe)
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Rutini Sil'),
                          content: Text(
                            '"${routine.title}" rutinini silmek istediğinize emin misiniz?',
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
                          await ref
                              .read(routineProvider.notifier)
                              .removeRoutine(routine.id);
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
                  child: _buildRoutineCard(context, ref, routine),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.addRoutine),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRoutineCard(
      BuildContext context, WidgetRef ref, RoutineModel routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.repeat, color: Colors.green.shade700),
        ),
        title: Text(
          routine.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Tekrar: ${_getRecurrenceText(routine.recurrenceType)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            if (routine.description != null &&
                routine.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                routine.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context, ref, routine);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
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
      case 'monthly':
        return 'Her Ay';
      default:
        return recurrenceType;
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, RoutineModel routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rutini Sil'),
        content: Text(
          '"${routine.title}" rutinini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(routineProvider.notifier)
                    .removeRoutine(routine.id);
                // Also refresh todos to update the my_todos_tab
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
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
