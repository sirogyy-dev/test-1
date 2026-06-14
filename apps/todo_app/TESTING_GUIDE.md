# Testing Guide for ProTodo

## Setup

1. Navigate to the todo app directory:
   ```bash
   cd apps/todo_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```

## Running Tests

### Unit tests

```bash
flutter test test/unit
```

### Widget tests

```bash
flutter test test/widget
```

### Integration tests

```bash
flutter test integration_test/app_test.dart
```

## Coverage

Generate coverage for the app:

```bash
flutter test --coverage
```

Coverage reports will be written to `coverage/lcov.info`.

## Notes

- Widget tests use Riverpod overrides to replace providers with test values.
- Integration tests launch the full app and verify the main entrypoint works.
- If Firebase initialization is required in tests, use mocks or a local emulator.
