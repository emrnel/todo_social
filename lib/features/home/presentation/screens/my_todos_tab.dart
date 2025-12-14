import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/todo/data/models/todo_model.dart';

class MyTodosTab extends ConsumerWidget {
  const MyTodosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual provider call, e.g., ref.watch(myTodosProvider)
    final List<TodoModel> todos = [
      TodoModel(
        id: 1,
        userId: 1,
        title: 'Buy Groceries',
        description: 'Milk, Bread, Eggs',
        isCompleted: false,
        isPublic: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 'todo',
      ),
      TodoModel(
        id: 2,
        userId: 1,
        title: 'Morning Workout',
        description: '30 mins cardio',
        isCompleted: false,
        isPublic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 'routine',
        recurrenceType: 'daily',
      ),
    ];

    if (todos.isEmpty) {
      return const Center(
        child: Text('No todos or routines yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final item = todos[index];
        final isRoutine = item.type == 'routine';

        if (isRoutine) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(Icons.repeat, color: Colors.green),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Recurrence: ${item.recurrenceType ?? 'Daily'}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: (val) {},
            ),
            title: Text(item.title),
            subtitle: item.description != null ? Text(item.description!) : null,
          ),
        );
      },
    );
  }
}