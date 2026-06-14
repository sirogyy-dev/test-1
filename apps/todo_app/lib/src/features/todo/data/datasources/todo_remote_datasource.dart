import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/todo_item.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoItem>> fetchTodos(String userId);
  Future<void> addTodo(String userId, TodoItem todo);
  Future<void> updateTodo(String userId, TodoItem todo);
  Future<void> deleteTodo(String userId, String todoId);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final FirebaseFirestore firestore;

  TodoRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _todos(String userId) {
    return firestore.collection('users').doc(userId).collection('todos');
  }

  String _statusFromData(Map<String, dynamic> data, bool completed, DateTime dueDate) {
    final rawStatus = data['status'] as String?;
    if (rawStatus != null && rawStatus.isNotEmpty) {
      return rawStatus;
    }
    if (completed) {
      return 'completed';
    }
    return dueDate.isBefore(DateTime.now()) ? 'overdue' : 'pending';
  }

  @override
  Future<void> addTodo(String userId, TodoItem todo) async {
    await _todos(userId).doc(todo.id).set(todo.toRemoteJson());
  }

  @override
  Future<void> deleteTodo(String userId, String todoId) async {
    await _todos(userId).doc(todoId).delete();
  }

  @override
  Future<List<TodoItem>> fetchTodos(String userId) async {
    final snapshot = await _todos(userId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TodoItem.fromRemoteJson(data, doc.id);
    }).toList();
  }

  @override
  Future<void> updateTodo(String userId, TodoItem todo) async {
    await _todos(userId).doc(todo.id).update(todo.toRemoteJson());
  }
}
