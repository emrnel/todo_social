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
      // Only fetch todos - backend returns both todos and routines
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
      return Center(child: Text('Error: ${todoState.errorMessage}'));
    }

    if (todos.isEmpty && routines.isEmpty) {
      return const Center(child: Text('No todos or routines yet.'));
    }

    final items = [
      ...todos.map((t) => {'kind': 'todo', 'todo': t}),
      ...routines.map((r) => {'kind': 'routine', 'routine': r}),
    ];

    return ListView.builder(
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
              title: Text(r.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Recurs: ${r.recurrenceType}'),
            ),
          );
        } else {
          final t = data['todo'] as TodoModel;
          return Dismissible(
            key: ValueKey('todo_${t.id}'),
            background: Container(color: Colors.redAccent),
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
                title: Text(t.title),
                subtitle: t.description != null ? Text(t.description!) : null,
              ),
            ),
          );
        }
      },
    );
  }
}
