import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoUseCase {
  final TodoRepository repository;

  UpdateTodoUseCase(this.repository);

  Future<void> call(String userId, TodoItem todo) {
    return repository.updateTodo(userId, todo);
  }
}
