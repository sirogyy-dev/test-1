import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class ToggleTodoUseCase {
  final TodoRepository repository;

  ToggleTodoUseCase(this.repository);

  Future<void> call(String userId, TodoItem todo) {
    final completed = !todo.completed;
    final updatedTodo = todo.copyWith(
      completed: completed,
      status: completed ? 'completed' : (todo.dueDate.isBefore(DateTime.now()) ? 'overdue' : 'pending'),
    );
    return repository.updateTodo(userId, updatedTodo);
  }
}
