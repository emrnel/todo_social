import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/common/widgets/custom_button.dart';
import 'package:todo_social/core/common/widgets/custom_text_field.dart';
import 'package:todo_social/features/routine/presentation/providers/routine_provider.dart';
import 'package:todo_social/features/todo/presentation/providers/todo_provider.dart';

class AddRoutineScreen extends ConsumerStatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  ConsumerState<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends ConsumerState<AddRoutineScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _recurrenceType = 'daily';
  bool _isPublic = false;
  bool _isLoading = false;
  Set<String> _selectedDays = {};  // ÖNEMLİ: final OLMAMALI

  final List<String> _recurrenceOptions = ['daily', 'weekly', 'custom'];
  final Map<String, String> _dayLabels = {
    'mon': 'Pazartesi',
    'tue': 'Salı',
    'wed': 'Çarşamba',
    'thu': 'Perşembe',
    'fri': 'Cuma',
    'sat': 'Cumartesi',
    'sun': 'Pazar',
  };

  Future<void> _saveRoutine() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık gereklidir')),
      );
      return;
    }

    if (_recurrenceType == 'custom' && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir gün seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? recurrenceValue;
    if (_recurrenceType == 'custom') {
      recurrenceValue = _selectedDays.toList().join(',');
    }

    try {
      await ref.read(routineProvider.notifier).createRoutine(
            _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            isPublic: _isPublic,
            recurrenceType: _recurrenceType,
            recurrenceValue: recurrenceValue,
          );

      await ref.read(todoProvider.notifier).fetchMyTodos();

      if (!mounted) return;
      final state = ref.read(routineProvider);
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${state.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rutin başarıyla oluşturuldu!')),
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
      appBar: AppBar(title: const Text('Rutin Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Başlık',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Açıklama',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _recurrenceType,
              decoration: const InputDecoration(
                labelText: 'Tekrar',
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
                  setState(() {
                    _recurrenceType = newValue;
                    if (newValue != 'custom') {
                      _selectedDays.clear();
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            if (_recurrenceType == 'custom') ...[
              const Text(
                'Günleri Seçin:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dayLabels.entries.map((entry) {
                  final isSelected = _selectedDays.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(entry.key);
                        } else {
                          _selectedDays.remove(entry.key);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            SwitchListTile(
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
              title: const Text('Herkese Açık'),
              subtitle:
                  const Text('Takipçilerinizin görmesini istiyorsanız açın'),
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: _saveRoutine,
              text: 'Rutini Kaydet',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
