import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:axcend_flutter_task/models/todo.dart';
import 'package:axcend_flutter_task/models/user.dart';
import 'package:axcend_flutter_task/screens/users_screen.dart';
import 'package:axcend_flutter_task/services/api_service.dart';

// Fake API service that provides predefined in-memory responses
// for testing instead of making real network calls.
class FakeApiService extends ApiService {
  final bool shouldFailUsers;
  final bool shouldFailTodos;

  FakeApiService({
    this.shouldFailUsers = false,
    this.shouldFailTodos = false,
  });

  @override
  Future<List<User>> fetchUsers() async {
    if (shouldFailUsers) {
      throw Exception('Network error');
    }

    return [
      User(id: 1, name: 'Brandan', email: 'Brandan@example.com'),
    ];
  }

  @override
  Future<List<Todo>> fetchTodos(int userId) async {
    if (shouldFailTodos) {
      throw Exception('Todo error');
    }

    return [
      Todo(userId: userId, id: 1, title: 'Task1', completed: false),
      Todo(userId: userId, id: 2, title: 'Task2', completed: true),
    ];
  }
}

void main() {
  group('API tests (ApiService)', () {

    // Test 1: Verify fetchUsers returns correctly parsed User objects
    // when the API responds with HTTP 200.
    test('fetchUsers returns users when status code is 200', () async {
      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://jsonplaceholder.typicode.com/users',
        );

        final body = jsonEncode([
          {'id': 1, 'name': 'Brandan', 'email': 'Brandan@example.com'},
        ]);

        return http.Response(body, 200);
      });

      final api = ApiService(client: mockClient);
      final users = await api.fetchUsers();

      expect(users, isA<List<User>>());
      expect(users.length, 1);
      expect(users.first.id, 1);
      expect(users.first.name, 'Brandan');
      expect(users.first.email, 'Brandan@example.com');
    });

    // Test 2: Ensure fetchUsers throws an Exception
    // when the API responds with a non-200 status code.
    test('fetchUsers throws an exception when status code is not 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final api = ApiService(client: mockClient);

      expect(
            () => api.fetchUsers(),
        throwsA(isA<Exception>()),
      );
    });

    // Test 3: Verify fetchTodos correctly parses and returns Todo objects
    // when the API responds successfully.
    test('fetchTodos returns todos when status code is 200', () async {
      final mockClient = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://jsonplaceholder.typicode.com/todos?userId=1',
        );

        final body = jsonEncode([
          {'userId': 1, 'id': 1, 'title': 'Task1', 'completed': false},
        ]);

        return http.Response(body, 200);
      });

      final api = ApiService(client: mockClient);
      final todos = await api.fetchTodos(1);

      expect(todos, isA<List<Todo>>());
      expect(todos.length, 1);
      expect(todos.first.userId, 1);
      expect(todos.first.id, 1);
      expect(todos.first.title, 'Task1');
      expect(todos.first.completed, false);
    });
  });

  group('Widget tests (UsersScreen + TodosScreen)', () {

    // Test 4: Confirm UsersScreen initially shows a loading indicator
    // and then renders the retrieved user data.
    testWidgets('UsersScreen shows loading then displays users',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: UsersScreen(apiService: FakeApiService()),
            ),
          );

          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          await tester.pumpAndSettle();

          expect(find.text('Brandan'), findsOneWidget);
          expect(find.text('Brandan@example.com'), findsOneWidget);
        });

    // Test 5: Validate that tapping a user navigates to TodosScreen
    // and displays the associated todo list correctly.
    testWidgets('Tapping a user navigates to TodosScreen and shows todos',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: UsersScreen(apiService: FakeApiService()),
            ),
          );

          await tester.pumpAndSettle();

          await tester.tap(find.text('Brandan'));
          await tester.pumpAndSettle();

          expect(find.text('Brandan Todos'), findsOneWidget);
          expect(find.text('Task1'), findsOneWidget);
          expect(find.text('Task2'), findsOneWidget);
          expect(find.byIcon(Icons.check_circle), findsOneWidget);
          expect(find.byIcon(Icons.cancel), findsOneWidget);
        });

    // Test 6: Ensure UsersScreen presents an appropriate error message
    // when user retrieval fails.
    testWidgets('UsersScreen shows error message when API fails',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: UsersScreen(
                apiService: FakeApiService(shouldFailUsers: true),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.textContaining('Failed to load users'), findsOneWidget);
          expect(find.textContaining('Network error'), findsOneWidget);
        });

    // Test 7: Confirm TodosScreen displays an error message when
    // todo retrieval fails after navigation.
    testWidgets('TodosScreen shows error message when todos fail',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: UsersScreen(
                apiService: FakeApiService(shouldFailTodos: true),
              ),
            ),
          );

          await tester.pumpAndSettle();

          await tester.tap(find.text('Brandan'));
          await tester.pumpAndSettle();

          expect(find.textContaining('Failed to load todos'), findsOneWidget);
          expect(find.textContaining('Todo error'), findsOneWidget);
        });
  });
}