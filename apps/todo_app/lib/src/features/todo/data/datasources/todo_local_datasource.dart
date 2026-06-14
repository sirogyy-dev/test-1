import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/todo_item.dart';

const _todosBoxName = 'todos';

class TodoLocalDataSource {
  final Box _box;

  TodoLocalDataSource._(this._box);

  factory TodoLocalDataSource() => TodoLocalDataSource._(Hive.box(_todosBoxName));

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_todosBoxName);
  }

  Future<List<TodoItem>> loadTodos() async {
    final values = _box.values
        .whereType<Map>()
        .where((entry) => entry['pendingAction'] != 'delete')
        .map((entry) {
          final data = Map<String, dynamic>.from(entry['data'] as Map);
          return TodoItem.fromJson(data);
        })
        .toList();

    values.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  Future<void> saveTodo(TodoItem todo, {String? pendingAction}) async {
    final existing = _box.get(todo.id);
    final String? currentAction = existing is Map ? existing['pendingAction'] as String? : null;
    final String? actionToSave = currentAction == 'create' ? 'create' : pendingAction;

    await _box.put(todo.id, {
      'data': todo.toLocalJson(),
      'pendingAction': actionToSave,
    });
  }

  Future<void> markTodoDeleted(String todoId) async {
    final existing = _box.get(todoId);

    if (existing is Map) {
      final currentAction = existing['pendingAction'] as String?;
      if (currentAction == 'create') {
        await _box.delete(todoId);
        return;
      }

      final data = existing['data'] as Map<String, dynamic>?;
      await _box.put(todoId, {
        'data': data ?? {'id': todoId},
        'pendingAction': 'delete',
      });
      return;
    }

    await _box.put(todoId, {
      'data': {'id': todoId},
      'pendingAction': 'delete',
    });
  }

  Future<List<Map<String, dynamic>>> getPendingEntries() async {
    return _box.values
        .whereType<Map>()
        .where((entry) => entry['pendingAction'] != null)
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
  }

  Future<void> setPendingAction(String todoId, String? action) async {
    final existing = _box.get(todoId);
    if (existing is! Map) return;

    final data = Map<String, dynamic>.from(existing['data'] as Map);
    if (action == null) {
      await _box.put(todoId, {
        'data': data,
        'pendingAction': null,
      });
    } else {
      await _box.put(todoId, {
        'data': data,
        'pendingAction': action,
      });
    }
  }

  Future<void> clearEntry(String todoId) async {
    await _box.delete(todoId);
  }

  Future<void> mergeRemoteTodos(List<TodoItem> remoteTodos) async {
    final remoteIds = remoteTodos.map((task) => task.id).toSet();
    final localKeys = _box.keys.cast<String>().toList();

    for (final remoteTodo in remoteTodos) {
      final existing = _box.get(remoteTodo.id);
      if (existing is Map) {
        final pendingAction = existing['pendingAction'] as String?;
        if (pendingAction != null) {
          continue;
        }
      }
      await _box.put(remoteTodo.id, {
        'data': remoteTodo.toLocalJson(),
        'pendingAction': null,
      });
    }

    for (final key in localKeys) {
      final entry = _box.get(key);
      if (entry is Map) {
        final pendingAction = entry['pendingAction'] as String?;
        if (pendingAction == null && !remoteIds.contains(key)) {
          await _box.delete(key);
        }
      }
    }
  }
}
