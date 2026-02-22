import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/api_service.dart';

class TodosScreen extends StatefulWidget {
  final int userId;
  final String userName;

  final ApiService apiService;

  TodosScreen({
    super.key,
    required this.userId,
    required this.userName,
    ApiService? apiService,
  }) : apiService = apiService ?? ApiService();

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  late final Future<List<Todo>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _todosFuture = widget.apiService.fetchTodos(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName} Todos'),
      ),
      body: FutureBuilder<List<Todo>>(
        future: _todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load todos.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final todos = snapshot.data ?? [];

          if (todos.isEmpty) {
            return const Center(child: Text('No todos found.'));
          }

          return Column(
            children: [
              // Header Row
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Completed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Todo List
              Expanded(
                child: ListView.separated(
                  itemCount: todos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final todo = todos[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              todo.title,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Icon(
                              todo.completed ? Icons.check_circle : Icons.cancel,
                              color:
                              todo.completed ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}