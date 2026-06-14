import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/src/features/todo/domain/entities/todo_item.dart';

void main() {
  group('TodoItem', () {
    test('toJson and fromJson preserve values', () {
      final item = TodoItem(
        id: '1',
        title: 'Test',
        description: 'Unit testing',
        dueDate: DateTime.utc(2026, 1, 1),
        priority: 'High',
        categoryId: 'cat-1',
        status: 'pending',
        completed: false,
        createdAt: DateTime.utc(2025, 12, 1),
      );

      final json = item.toJson();
      final restored = TodoItem.fromJson(json);

      expect(restored.id, equals(item.id));
      expect(restored.title, equals(item.title));
      expect(restored.description, equals(item.description));
      expect(restored.dueDate, equals(item.dueDate));
      expect(restored.priority, equals(item.priority));
      expect(restored.categoryId, equals(item.categoryId));
      expect(restored.status, equals(item.status));
      expect(restored.completed, equals(item.completed));
      expect(restored.createdAt, equals(item.createdAt));
    });

    test('copyWith updates fields correctly', () {
      final item = TodoItem(
        id: '1',
        title: 'Test',
        description: 'Desc',
        dueDate: DateTime.utc(2026, 1, 1),
        priority: 'Normal',
        categoryId: null,
        status: 'pending',
        completed: false,
        createdAt: DateTime.utc(2025, 12, 1),
      );

      final updated = item.copyWith(title: 'Updated', completed: true);

      expect(updated.title, equals('Updated'));
      expect(updated.completed, isTrue);
      expect(updated.description, equals(item.description));
      expect(updated.id, equals(item.id));
    });
  });
}
