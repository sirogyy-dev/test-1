import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class GetTodosUseCase {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  Future<List<TodoItem>> call(String userId) {
    return repository.getTodos(userId);
  }
}
