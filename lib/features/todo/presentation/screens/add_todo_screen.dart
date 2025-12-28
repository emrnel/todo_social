// lib/features/todo/presentation/screens/add_todo_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';
import 'package:todo_social/features/gamification/providers/category_provider.dart';
import 'package:todo_social/data/models/category_model.dart';

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
  bool _isSubmitting = false;
  CategoryModel? _selectedCategory;

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
              const SizedBox(height: 16),
              // Category Selector
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync = ref.watch(categoriesProvider);
                  return categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) return const SizedBox.shrink();
                      return DropdownButtonFormField<CategoryModel>(
                        decoration: const InputDecoration(
                          labelText: 'Kategori (Opsiyonel)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        initialValue: _selectedCategory,
                        hint: const Text('Kategori seçin'),
                        items: categories.map((category) {
                          return DropdownMenuItem<CategoryModel>(
                            value: category,
                            child: Row(
                              children: [
                                if (category.icon != null) ...[
                                  Text(category.icon!, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                ],
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (CategoryModel? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
                title: const Text('Public'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSubmitting = true);
                          // Capture messenger/router before awaits to avoid context-after-await lint
                          final messenger = ScaffoldMessenger.of(context);
                          final router = GoRouter.of(context);
                          try {
                            await ref.read(todoProvider.notifier).createTodo(
                                  _titleController.text.trim(),
                                  description:
                                      _descriptionController.text.trim().isEmpty
                                          ? null
                                          : _descriptionController.text.trim(),
                                  isPublic: _isPublic,
                                  categoryId: _selectedCategory?.id,
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
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        }
                      },
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
