import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class AddTodoUseCase {
  final TodoRepository repository;

  AddTodoUseCase(this.repository);

  Future<void> call(String userId, TodoItem todo) {
    return repository.createTodo(userId, todo);
  }
}
