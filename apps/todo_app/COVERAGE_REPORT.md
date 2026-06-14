# Coverage Report for ProTodo

This repository includes unit, widget, and integration test files, but the runtime environment currently does not include Flutter tooling, so a live coverage report could not be generated here.

## Expected coverage generation

Run the following from `apps/todo_app`:

```bash
flutter test --coverage
```

Then inspect the generated report at:

- `apps/todo_app/coverage/lcov.info`
- optionally convert to HTML with `genhtml coverage/lcov.info -o coverage/html`

## Test files included

- `test/unit/todo_item_test.dart`
- `test/widget/home_page_test.dart`
- `integration_test/app_test.dart`

## Notes

- `TESTING_GUIDE.md` contains commands for unit, widget, integration, and coverage workflows.
- If you want, I can also add a dedicated `integration_test_driver.dart` and a `coverage` script entry to `pubspec.yaml`.
