import '../repositories/todo_repository.dart';

class DeleteTodoUseCase {
  final TodoRepository repository;

  DeleteTodoUseCase(this.repository);

  Future<void> call(String userId, String todoId) {
    return repository.removeTodo(userId, todoId);
  }
}
