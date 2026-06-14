import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:todo_app/src/features/categories/presentation/controllers/category_controller.dart';
import 'package:todo_app/src/features/todo/presentation/controllers/todo_controller.dart';
import 'package:todo_app/src/features/todo/presentation/views/home_page.dart';

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'test-user';

  @override
  String? get displayName => 'Tester';

  @override
  String? get email => 'tester@example.com';
}

void main() {
  testWidgets('HomePage shows not signed in when no user', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWithValue(const AsyncValue.data(null)),
          todoStateProvider.overrideWithValue(const TodoState()),
          categoryStateProvider.overrideWithValue(const CategoryState()),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Not signed in.'), findsOneWidget);
  });
}
