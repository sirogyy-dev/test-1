import '../entities/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodos(String userId);
  Future<void> createTodo(String userId, TodoItem todo);
  Future<void> updateTodo(String userId, TodoItem todo);
  Future<void> removeTodo(String userId, String todoId);
}
