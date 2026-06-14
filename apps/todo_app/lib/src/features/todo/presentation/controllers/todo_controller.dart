import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../categories/presentation/controllers/category_controller.dart';
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/add_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/toggle_todo_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';
import '../../notifications/notification_service.dart';
import '../states/todo_state.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(
    TodoRemoteDataSourceImpl(FirebaseFirestore.instance),
    TodoLocalDataSource(),
  );
});

final todoStateProvider = StateNotifierProvider<TodoController, TodoState>((ref) {
  final repository = ref.watch(todoRepositoryProvider);

  return TodoController(
    getTodosUseCase: GetTodosUseCase(repository),
    addTodoUseCase: AddTodoUseCase(repository),
    updateTodoUseCase: UpdateTodoUseCase(repository),
    deleteTodoUseCase: DeleteTodoUseCase(repository),
    toggleTodoUseCase: ToggleTodoUseCase(repository),
    auth: FirebaseAuth.instance,
  );
});

final todoTotalProvider = Provider<int>((ref) {
  return ref.watch(todoStateProvider).todos.length;
});

final todoCompletedProvider = Provider<int>((ref) {
  return ref.watch(todoStateProvider).todos.where((todo) => todo.completed).length;
});

final todoPendingProvider = Provider<int>((ref) {
  return ref.watch(todoStateProvider).todos.where((todo) => !todo.completed).length;
});

final todoSearchQueryProvider = StateProvider<String>((ref) => '');
final todoPriorityFilterProvider = StateProvider<String?>((ref) => null);
final todoStatusFilterProvider = StateProvider<String?>((ref) => null);
final todoDateFilterProvider = StateProvider<DateTimeRange?>((ref) => null);
final todoSortOrderProvider = StateProvider<SortOption>((ref) => SortOption.newest);

enum SortOption {
  newest,
  oldest,
  dueSoon,
  dueLate,
  priorityHighLow,
  priorityLowHigh,
}

final filteredTodoListProvider = Provider<List<TodoItem>>((ref) {
  final todos = ref.watch(todoStateProvider).todos;
  final searchQuery = ref.watch(todoSearchQueryProvider).trim().toLowerCase();
  final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
  final priorityFilter = ref.watch(todoPriorityFilterProvider);
  final statusFilter = ref.watch(todoStatusFilterProvider);
  final dateRange = ref.watch(todoDateFilterProvider);
  final sortOrder = ref.watch(todoSortOrderProvider);

  final filtered = todos.where((todo) {
    if (selectedCategoryId != null && todo.categoryId != selectedCategoryId) {
      return false;
    }

    if (priorityFilter != null && priorityFilter != todo.priority) {
      return false;
    }

    if (statusFilter != null && statusFilter != todo.status) {
      return false;
    }

    if (dateRange != null) {
      if (todo.dueDate.isBefore(dateRange.start) || todo.dueDate.isAfter(dateRange.end)) {
        return false;
      }
    }

    if (searchQuery.isNotEmpty) {
      final title = todo.title.toLowerCase();
      final description = todo.description.toLowerCase();
      if (!title.contains(searchQuery) && !description.contains(searchQuery)) {
        return false;
      }
    }

    return true;
  }).toList();

  filtered.sort((a, b) {
    switch (sortOrder) {
      case SortOption.newest:
        return b.createdAt.compareTo(a.createdAt);
      case SortOption.oldest:
        return a.createdAt.compareTo(b.createdAt);
      case SortOption.dueSoon:
        return a.dueDate.compareTo(b.dueDate);
      case SortOption.dueLate:
        return b.dueDate.compareTo(a.dueDate);
      case SortOption.priorityHighLow:
        return _priorityValue(b.priority).compareTo(_priorityValue(a.priority));
      case SortOption.priorityLowHigh:
        return _priorityValue(a.priority).compareTo(_priorityValue(b.priority));
    }
  });

  return filtered;
});

int _priorityValue(String priority) {
  switch (priority) {
    case 'High':
      return 3;
    case 'Normal':
      return 2;
    case 'Low':
      return 1;
    default:
      return 0;
  }
}

class TodoController extends StateNotifier<TodoState> {
  final GetTodosUseCase getTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final FirebaseAuth auth;

  TodoController({
    required this.getTodosUseCase,
    required this.addTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
    required this.toggleTodoUseCase,
    required this.auth,
  }) : super(const TodoState());

  Future<void> loadTodos() async {
    final user = auth.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: 'User not signed in.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final todos = await getTodosUseCase(user.uid);
    state = state.copyWith(isLoading: false, todos: todos);
  }

  Future<void> addTodo({
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    String? categoryId,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final todo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      categoryId: categoryId,
      completed: false,
      status: dueDate.isBefore(DateTime.now()) ? 'overdue' : 'pending',
      createdAt: DateTime.now().toUtc(),
    );

    state = state.copyWith(isLoading: true);
    await addTodoUseCase(user.uid, todo);
    await NotificationService.instance.scheduleDueDateReminder(
      taskId: todo.id,
      taskTitle: todo.title,
      dueDate: todo.dueDate,
    );
    await loadTodos();
  }

  Future<void> updateTodo({
    required String todoId,
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    String? categoryId,
    required bool completed,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final existingTodo = state.todos.firstWhere((item) => item.id == todoId);
    final updatedTodo = existingTodo.copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      categoryId: categoryId,
      completed: completed,
      status: completed ? 'completed' : (dueDate.isBefore(DateTime.now()) ? 'overdue' : 'pending'),
    );

    state = state.copyWith(isLoading: true);
    await updateTodoUseCase(user.uid, updatedTodo);
    if (!updatedTodo.completed) {
      await NotificationService.instance.scheduleDueDateReminder(
        taskId: updatedTodo.id,
        taskTitle: updatedTodo.title,
        dueDate: updatedTodo.dueDate,
      );
    } else {
      await NotificationService.instance.cancelTaskReminder(updatedTodo.id);
    }
    await loadTodos();
  }

  Future<void> deleteTodo(String todoId) async {
    final user = auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    await deleteTodoUseCase(user.uid, todoId);
    await NotificationService.instance.cancelTaskReminder(todoId);
    await loadTodos();
  }

  Future<void> toggleTodo(String todoId) async {
    final user = auth.currentUser;
    if (user == null) return;
    final todo = state.todos.firstWhere((item) => item.id == todoId);
    await toggleTodoUseCase(user.uid, todo);

    if (todo.completed) {
      await NotificationService.instance.cancelTaskReminder(todoId);
    } else {
      await NotificationService.instance.scheduleDueDateReminder(
        taskId: todo.id,
        taskTitle: todo.title,
        dueDate: todo.dueDate,
      );
    }

    await loadTodos();
  }
}
