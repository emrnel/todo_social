import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';
import 'package:todo_social/data/models/routine_model.dart';

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
      // Fetch todos (backend returns both todos and routines)
      Future.microtask(() async {
        await ref.read(todoProvider.notifier).fetchMyTodos();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final List<TodoModel> todos = todoState.todos;
    final List<RoutineModel> routines = todoState.routines;

    if (todoState.isLoading && todos.isEmpty && routines.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todoState.errorMessage != null && todos.isEmpty && routines.isEmpty) {
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

    if (todos.isEmpty && routines.isEmpty) {
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

    final items = [
      ...todos.map((t) => {'kind': 'todo', 'todo': t}),
      ...routines.map((r) => {'kind': 'routine', 'routine': r}),
    ];

    return RefreshIndicator(
      onRefresh: () => ref.read(todoProvider.notifier).fetchMyTodos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final data = items[index];
          if (data['kind'] == 'routine') {
            final r = data['routine'] as RoutineModel;
            return Card(
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
                    Text('Tekrar: ${r.recurrenceType}'),
                    if (r.description != null && r.description!.isNotEmpty)
                      Text(
                        r.description!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                  ],
                ),
                trailing: r.isPublic
                    ? const Icon(Icons.public, color: Colors.grey, size: 20)
                    : const Icon(Icons.lock, color: Colors.grey, size: 20),
              ),
            );
          } else {
            final t = data['todo'] as TodoModel;
            return Dismissible(
              key: ValueKey('todo_${t.id}'),
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                await ref.read(todoProvider.notifier).removeTodo(t.id);
                return false; // managed via provider
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Checkbox(
                    value: t.isCompleted,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(todoProvider.notifier).toggleTodo(t.id, val);
                      }
                    },
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration:
                          t.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (t.description != null && t.description!.isNotEmpty)
                        Text(t.description!),
                    ],
                  ),
                  trailing: t.isPublic
                      ? const Icon(Icons.public, color: Colors.grey, size: 20)
                      : const Icon(Icons.lock, color: Colors.grey, size: 20),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
