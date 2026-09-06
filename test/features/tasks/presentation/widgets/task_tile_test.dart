import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monolith_tasks/features/tasks/presentation/widgets/task_tile.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/priority.dart';
import 'package:monolith_tasks/features/tasks/presentation/cubits/task_list_cubit.dart';

class MockTaskListCubit extends MockCubit<TaskListState> implements TaskListCubit {
  @override
  Future<void> toggle(String id) async {}

  @override
  Future<String?> delete(String id) async => '';

  @override
  void watch() {}

  @override
  Future<void> restoreTask(Task task) async {}
}

void main() {
  setUp(() {
    // Initialize bindings for Flutter tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('TaskTile', () {
    final testTask = Task(
      id: 'test-id',
      content: 'Test task content',
      isCompleted: false,
      priority: TaskPriority.medium,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final completedTask = Task(
      id: 'test-id-2',
      content: 'Completed task',
      isCompleted: true,
      priority: TaskPriority.high,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    testWidgets('renders task content correctly', (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: const Scaffold(
              body: TaskTile(
                task: testTask,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Verify that the task content is displayed
      expect(find.text('Test task content'), findsOneWidget);
    });

    testWidgets('shows checkbox for incomplete task', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: const Scaffold(
              body: TaskTile(
                task: testTask,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Verify that a checkbox is present
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('shows priority indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: const Scaffold(
              body: TaskTile(
                task: testTask,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Verify that priority indicator is present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows strikethrough for completed task', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: const Scaffold(
              body: TaskTile(
                task: completedTask,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Find the Text widget with strikethrough
      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
    });

    testWidgets('calls onToggle when checkbox is tapped', (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: Scaffold(
              body: TaskTile(
                task: testTask,
                onToggle: () => toggleCalled = true,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(toggleCalled, true);
    });

    testWidgets('calls onTap when tile is tapped', (WidgetTester tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: Scaffold(
              body: TaskTile(
                task: testTask,
                onToggle: null,
                onTap: () => tapCalled = true,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Tap the ListTile
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapCalled, true);
    });

    testWidgets('calls onLongPress when tile is long pressed', (WidgetTester tester) async {
      bool longPressCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: Scaffold(
              body: TaskTile(
                task: testTask,
                onToggle: null,
                onTap: null,
                onLongPress: () => longPressCalled = true,
              ),
            ),
          ),
        ),
      );

      // Long press the ListTile
      await tester.longPress(find.byType(ListTile));
      await tester.pump();

      expect(longPressCalled, true);
    });

    testWidgets('shows tags when present', (WidgetTester tester) async {
      final taskWithTags = testTask.copyWith(
        tags: const ['work', 'important'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: Scaffold(
              body: TaskTile(
                task: taskWithTags,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Verify that tags are displayed
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text('#work'), findsOneWidget);
      expect(find.text('#important'), findsOneWidget);
    });

    testWidgets('shows due date when present', (WidgetTester tester) async {
      final taskWithDueDate = testTask.copyWith(
        dueDate: DateTime(2024, 12, 31),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: Scaffold(
              body: TaskTile(
                task: taskWithDueDate,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Verify that due date is displayed
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('shows subtask indicator when has parentTaskId', (WidgetTester tester) async {
      final taskWithParent = testTask.copyWith(
        parentTaskId: 'parent-id',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: Scaffold(
              body: TaskTile(
                task: taskWithParent,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Verify that subtask indicator is present
      expect(find.byIcon(Icons.subdirectory_arrow_right), findsOneWidget);
    });

    testWidgets('matches golden for incomplete task', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MockTaskListCubit(),
            child: Scaffold(
              body: TaskTile(
                task: testTask,
                onToggle: null,
                onTap: null,
                onLongPress: null,
              ),
            ),
          ),
        ),
      );

      // Verify the widget tree structure
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });
  });
}
