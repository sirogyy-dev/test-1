import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../controllers/category_controller.dart';

class CategoryManagementPage extends ConsumerStatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  ConsumerState<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends ConsumerState<CategoryManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryStateProvider.notifier).loadCategories();
    });
  }

  void _showCategoryDialog([Category? category]) {
    showDialog<void>(
      context: context,
      builder: (_) => CategoryDialog(category: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryState.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tag_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('No categories yet', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      const Text('Add a category to organize tasks into labels.'),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: categoryState.categories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = categoryState.categories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(category.name, style: Theme.of(context).textTheme.titleMedium),
                        leading: CircleAvatar(
                          backgroundColor: Color(int.parse(category.color)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showCategoryDialog(category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref.read(categoryStateProvider.notifier).deleteCategory(category.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CategoryDialog extends ConsumerStatefulWidget {
  const CategoryDialog({super.key, this.category});

  final Category? category;

  @override
  ConsumerState<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<CategoryDialog> {
  final nameController = TextEditingController();
  String color = '0xFF6200EE';

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      nameController.text = widget.category!.name;
      color = widget.category!.color;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final controller = ref.read(categoryStateProvider.notifier);

    return AlertDialog(
      title: Text(isEditing ? 'Edit category' : 'New category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(controller: TextEditingController(text: color), readOnly: true, decoration: const InputDecoration(labelText: 'Color')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _CategoryColorChip(
                colorValue: '0xFF6200EE',
                selected: color == '0xFF6200EE',
                onSelected: () => setState(() => color = '0xFF6200EE'),
              ),
              _CategoryColorChip(
                colorValue: '0xFF018786',
                selected: color == '0xFF018786',
                onSelected: () => setState(() => color = '0xFF018786'),
              ),
              _CategoryColorChip(
                colorValue: '0xFFB00020',
                selected: color == '0xFFB00020',
                onSelected: () => setState(() => color = '0xFFB00020'),
              ),
              _CategoryColorChip(
                colorValue: '0xFFFFA000',
                selected: color == '0xFFFFA000',
                onSelected: () => setState(() => color = '0xFFFFA000'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            if (isEditing) {
              await controller.updateCategory(widget.category!.id, name, color);
            } else {
              await controller.createCategory(name, color);
            }
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}

class _CategoryColorChip extends StatelessWidget {
  const _CategoryColorChip({
    required this.colorValue,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String colorValue;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: const SizedBox.shrink(),
      selected: selected,
      avatar: CircleAvatar(backgroundColor: Color(int.parse(colorValue))),
      onSelected: (_) => onSelected(),
    );
  }
}
