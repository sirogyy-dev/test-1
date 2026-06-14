import '../../domain/entities/todo_item.dart';

class TodoState {
  final bool isLoading;
  final List<TodoItem> todos;
  final String? errorMessage;

  const TodoState({
    this.isLoading = false,
    this.todos = const [],
    this.errorMessage,
  });

  TodoState copyWith({
    bool? isLoading,
    List<TodoItem>? todos,
    String? errorMessage,
  }) {
    return TodoState(
      isLoading: isLoading ?? this.isLoading,
      todos: todos ?? this.todos,
      errorMessage: errorMessage,
    );
  }
}
