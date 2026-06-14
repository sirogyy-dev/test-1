import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../categories/domain/entities/category.dart';
import '../../categories/presentation/controllers/category_controller.dart';
import '../../categories/presentation/views/category_management_page.dart';
import '../../theme/theme_controller.dart';
import '../controllers/todo_controller.dart';
import '../presentation/views/todo_form_dialog.dart';
import '../widgets/todo_item_card.dart';
import 'dashboard_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoStateProvider.notifier).loadTodos();
      ref.read(categoryStateProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (next.asData?.value != null) {
        ref.read(todoStateProvider.notifier).loadTodos();
      }
    });

    final authState = ref.watch(authStateProvider);
    final todoState = ref.watch(todoStateProvider);
    final categoryState = ref.watch(categoryStateProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final searchQuery = ref.watch(todoSearchQueryProvider);
    final priorityFilter = ref.watch(todoPriorityFilterProvider);
    final statusFilter = ref.watch(todoStatusFilterProvider);
    final dateFilter = ref.watch(todoDateFilterProvider);
    final sortOrder = ref.watch(todoSortOrderProvider);
    final filteredTodos = ref.watch(filteredTodoListProvider);
    final selectedCategory = categoryState.categories.firstWhere(
      (category) => category.id == selectedCategoryId,
      orElse: () => Category(id: '', name: 'All', color: '0xFF000000'),
    );

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not signed in.')));
        }

        final displayName = user.displayName ?? user.email ?? 'there';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6_outlined),
                onPressed: () {
                  final current = ref.read(themeModeProvider);
                  ref.read(themeModeProvider.notifier).state = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              IconButton(
                icon: const Icon(Icons.label_outline),
                onPressed: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
                  );
                  ref.read(categoryStateProvider.notifier).loadCategories();
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: todoState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : todoState.errorMessage != null
                    ? Center(
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              todoState.errorMessage!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $displayName',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Your task dashboard is ready.', style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              DashboardCard(
                                label: 'Total tasks',
                                value: totalTasks,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 12),
                              DashboardCard(
                                label: 'Completed',
                                value: completedTasks,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              DashboardCard(
                                label: 'Pending',
                                value: pendingTasks,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Tasks',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Search tasks',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () => ref.read(todoSearchQueryProvider.notifier).state = '',
                                    )
                                  : null,
                            ),
                            onChanged: (value) => ref.read(todoSearchQueryProvider.notifier).state = value,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              DropdownButton<String?>(
                                value: priorityFilter,
                                hint: const Text('Priority'),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('All priorities')),
                                  DropdownMenuItem(value: 'High', child: Text('High')),
                                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                                ],
                                onChanged: (value) => ref.read(todoPriorityFilterProvider.notifier).state = value,
                              ),
                              DropdownButton<String?>(
                                value: statusFilter,
                                hint: const Text('Status'),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('All status')),
                                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                  DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                                ],
                                onChanged: (value) => ref.read(todoStatusFilterProvider.notifier).state = value,
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.date_range),
                                label: Text(dateFilter == null
                                    ? 'Filter by date'
                                    : '${DateFormat.yMd().format(dateFilter.start)} - ${DateFormat.yMd().format(dateFilter.end)}'),
                                onPressed: () async {
                                  final selected = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    initialDateRange: dateFilter,
                                  );
                                  if (selected != null) {
                                    ref.read(todoDateFilterProvider.notifier).state = selected;
                                  }
                                },
                              ),
                              if (dateFilter != null)
                                TextButton(
                                  onPressed: () => ref.read(todoDateFilterProvider.notifier).state = null,
                                  child: const Text('Clear date'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              DropdownButton<SortOption>(
                                value: sortOrder,
                                items: const [
                                  DropdownMenuItem(value: SortOption.newest, child: Text('Newest')),
                                  DropdownMenuItem(value: SortOption.oldest, child: Text('Oldest')),
                                  DropdownMenuItem(value: SortOption.dueSoon, child: Text('Due soon')),
                                  DropdownMenuItem(value: SortOption.dueLate, child: Text('Due late')),
                                  DropdownMenuItem(value: SortOption.priorityHighLow, child: Text('Priority: high → low')),
                                  DropdownMenuItem(value: SortOption.priorityLowHigh, child: Text('Priority: low → high')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    ref.read(todoSortOrderProvider.notifier).state = value;
                                  }
                                },
                              ),
                              if (priorityFilter != null || statusFilter != null || searchQuery.isNotEmpty || dateFilter != null)
                                TextButton(
                                  onPressed: () {
                                    ref.read(todoSearchQueryProvider.notifier).state = '';
                                    ref.read(todoPriorityFilterProvider.notifier).state = null;
                                    ref.read(todoStatusFilterProvider.notifier).state = null;
                                    ref.read(todoDateFilterProvider.notifier).state = null;
                                  },
                                  child: const Text('Clear filters'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (categoryState.categories.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: selectedCategoryId == null,
                                  onSelected: (_) => ref.read(selectedCategoryIdProvider.notifier).state = null,
                                ),
                                ...categoryState.categories.map(
                                  (category) => ChoiceChip(
                                    label: Text(category.name),
                                    selected: selectedCategoryId == category.id,
                                    onSelected: (_) => ref.read(selectedCategoryIdProvider.notifier).state = category.id,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: filteredTodos.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.inbox_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
                                        const SizedBox(height: 16),
                                        Text(
                                          selectedCategoryId == null
                                              ? 'No tasks yet'
                                              : 'No tasks found in ${selectedCategory.name}',
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          selectedCategoryId == null
                                              ? 'Tap + to add your first task and stay organized.'
                                              : 'Try a different filter or add a new task.',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: filteredTodos.length,
                                    itemBuilder: (context, index) {
                                      final todo = filteredTodos[index];
                                      final category = categoryState.categories.firstWhere(
                                        (item) => item.id == todo.categoryId,
                                        orElse: () => Category(id: '', name: '', color: '0xFF000000'),
                                      );
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        child: TodoItemCard(
                                          todo: todo,
                                          category: category.name.isEmpty ? null : category,
                                          onToggle: () async {
                                            await ref.read(todoStateProvider.notifier).toggleTodo(todo.id);
                                          },
                                          onDelete: () async {
                                            await ref.read(todoStateProvider.notifier).deleteTodo(todo.id);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const TodoFormDialog(),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}

