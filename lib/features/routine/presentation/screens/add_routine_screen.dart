import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/common/widgets/custom_button.dart';
import 'package:todo_social/core/common/widgets/custom_text_field.dart';
import 'package:todo_social/features/routine/presentation/providers/routine_provider.dart';

class AddRoutineScreen extends ConsumerStatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  ConsumerState<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends ConsumerState<AddRoutineScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _recurrenceType = 'daily';
  bool _isLoading = false;

  final List<String> _recurrenceOptions = [
    'daily',
    'weekly',
    'monthly',
    'custom'
  ];

  Future<void> _saveRoutine() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(routineProvider.notifier).createRoutine(
            _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            isPublic: false,
            recurrenceType: _recurrenceType,
          );
      if (!mounted) return;
      final state = ref.read(routineProvider);
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine created successfully!')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Routine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Title',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _recurrenceType,
              decoration: const InputDecoration(
                labelText: 'Recurrence',
                border: OutlineInputBorder(),
              ),
              items: _recurrenceOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _recurrenceType = newValue);
                }
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: _saveRoutine,
              text: 'Save Routine',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
