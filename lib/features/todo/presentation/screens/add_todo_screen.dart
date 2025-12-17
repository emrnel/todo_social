// lib/features/todo/presentation/screens/add_todo_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
                title: const Text('Public'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Capture messenger/router before awaits to avoid context-after-await lint
                    final messenger = ScaffoldMessenger.of(context);
                    final router = GoRouter.of(context);
                    await ref.read(todoProvider.notifier).createTodo(
                          _titleController.text.trim(),
                          description:
                              _descriptionController.text.trim().isEmpty
                                  ? null
                                  : _descriptionController.text.trim(),
                          isPublic: _isPublic,
                        );
                    if (!mounted) return;
                    final state = ref.read(todoProvider);
                    if (state.errorMessage != null) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error: ${state.errorMessage}')),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Todo created')),
                      );
                      router.pop();
                    }
                  }
                },
                child: const Text('Save Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
