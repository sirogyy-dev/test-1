import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/todo_item.dart';
import '../../categories/presentation/controllers/category_controller.dart';
import '../../categories/domain/entities/category.dart';
import '../controllers/todo_controller.dart';

class TodoFormDialog extends ConsumerStatefulWidget {
  const TodoFormDialog({
    super.key,
    this.todo,
  });

  final TodoItem? todo;

  @override
  ConsumerState<TodoFormDialog> createState() => _TodoFormDialogState();
}

class _TodoFormDialogState extends ConsumerState<TodoFormDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? dueDate;
  String priority = 'Normal';
  bool completed = false;
  String? categoryId;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      titleController.text = widget.todo!.title;
      descriptionController.text = widget.todo!.description;
      dueDate = widget.todo!.dueDate;
      priority = widget.todo!.priority;
      categoryId = widget.todo!.categoryId;
      completed = widget.todo!.completed;
    } else {
      dueDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        dueDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(todoStateProvider);
    final notifier = ref.read(todoStateProvider.notifier);
    final isEditing = widget.todo != null;

    return AlertDialog(
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      title: Text(isEditing ? 'Edit task' : 'New task'),
      content: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Due date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dueDate == null ? 'Select a date' : DateFormat.yMMMd().format(dueDate!)),
                      const Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final categoryState = ref.watch(categoryStateProvider);
                  final categories = categoryState.categories;
                  return DropdownButtonFormField<String?>(
                    value: categoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('None')),
                      ...categories.map(
                        (category) => DropdownMenuItem<String?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        categoryId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      priority = value;
                    });
                  }
                },
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                CheckboxListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Completed'),
                  value: completed,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        completed = value;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final title = titleController.text.trim();
            final description = descriptionController.text.trim();
            if (title.isEmpty || dueDate == null) {
              return;
            }
            if (isEditing) {
              await notifier.updateTodo(
                todoId: widget.todo!.id,
                title: title,
                description: description,
                dueDate: dueDate!,
                priority: priority,
                categoryId: categoryId,
                completed: completed,
              );
            } else {
              await notifier.addTodo(
                title: title,
                description: description,
                dueDate: dueDate!,
                priority: priority,
                categoryId: categoryId,
              );
            }
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
