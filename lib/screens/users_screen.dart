import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import 'todos_screen.dart';

class UsersScreen extends StatefulWidget {
  final ApiService apiService;

  UsersScreen({
    super.key,
    ApiService? apiService,
  }) : apiService = apiService ?? ApiService();

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = widget.apiService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load users.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TodosScreen(
                        userId: user.id,
                        userName: user.name,
                        apiService: widget.apiService, // key part for testing
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}