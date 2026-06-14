import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl(this.remoteDataSource, this.localDataSource);

  Future<void> _syncPendingChanges(String userId) async {
    final pendingEntries = await localDataSource.getPendingEntries();

    for (final entry in pendingEntries) {
      final action = entry['pendingAction'] as String?;
      final data = Map<String, dynamic>.from(entry['data'] as Map);
      final todo = TodoItem.fromJson(data);

      try {
        if (action == 'create') {
          await remoteDataSource.addTodo(userId, todo);
          await localDataSource.setPendingAction(todo.id, null);
        } else if (action == 'update') {
          await remoteDataSource.updateTodo(userId, todo);
          await localDataSource.setPendingAction(todo.id, null);
        } else if (action == 'delete') {
          await remoteDataSource.deleteTodo(userId, todo.id);
          await localDataSource.clearEntry(todo.id);
        }
      } catch (_) {
        // Keep pending action until network sync succeeds.
      }
    }
  }

  @override
  Future<List<TodoItem>> getTodos(String userId) async {
    try {
      await _syncPendingChanges(userId);
      final remoteTodos = await remoteDataSource.fetchTodos(userId);
      await localDataSource.mergeRemoteTodos(remoteTodos);
    } catch (_) {
      // Firestore may be offline; keep local copy.
    }

    return localDataSource.loadTodos();
  }

  @override
  Future<void> createTodo(String userId, TodoItem todo) async {
    await localDataSource.saveTodo(todo, pendingAction: 'create');

    try {
      await remoteDataSource.addTodo(userId, todo);
      await localDataSource.setPendingAction(todo.id, null);
    } catch (_) {
      // Offline create will remain pending.
    }
  }

  @override
  Future<void> removeTodo(String userId, String todoId) async {
    await localDataSource.markTodoDeleted(todoId);

    try {
      await remoteDataSource.deleteTodo(userId, todoId);
      await localDataSource.clearEntry(todoId);
    } catch (_) {
      // Offline delete remains pending.
    }
  }

  @override
  Future<void> updateTodo(String userId, TodoItem todo) async {
    await localDataSource.saveTodo(todo, pendingAction: 'update');

    try {
      await remoteDataSource.updateTodo(userId, todo);
      await localDataSource.setPendingAction(todo.id, null);
    } catch (_) {
      // Offline update remains pending.
    }
  }
}
