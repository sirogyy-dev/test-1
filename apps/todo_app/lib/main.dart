import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/firebase/firebase_initializer.dart';
import 'src/features/notifications/notification_service.dart';
import 'src/features/todo/data/datasources/todo_local_datasource.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await TodoLocalDataSource.initialize();
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: TodoApp()));
}
