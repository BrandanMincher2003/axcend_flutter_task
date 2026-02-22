import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/todo.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static const Map<String, String> _defaultHeaders = {
    'Accept': 'application/json',
    'User-Agent': 'axcend_flutter_task/1.0',
  };

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<User>> fetchUsers() async {
    final uri = Uri.parse('$baseUrl/users');

    final response = await _client
        .get(uri, headers: _defaultHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body) as List<dynamic>;
      return jsonData
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load users (status: ${response.statusCode})');
  }

  Future<List<Todo>> fetchTodos(int userId) async {
    final uri = Uri.parse('$baseUrl/todos?userId=$userId');

    final response = await _client
        .get(uri, headers: _defaultHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body) as List<dynamic>;
      return jsonData
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load todos (status: ${response.statusCode})');
  }
}