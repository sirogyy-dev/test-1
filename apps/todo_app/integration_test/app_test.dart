import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and shows welcome content', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('ProTodo'), findsOneWidget);
  });
}
