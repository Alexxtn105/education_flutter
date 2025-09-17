import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/questionnare.dart';
import '../models/user.dart';
import '../models/test_result.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8084/api';

  Future<List<String>> getQuestionnaires() async {
    final response = await http.get(Uri.parse('$baseUrl/questionnaires'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item.toString()).toList();
    } else {
      throw Exception('Failed to load questionnaires');
    }
  }

  Future<Map<String, dynamic>> startTest(User user, String questionnaire) async {
    final response = await http.post(
      Uri.parse('$baseUrl/start-test'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': user.name,
        'department': user.department,
        'questionnaire': questionnaire,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to start test');
    }
  }

  Future<Map<String, dynamic>> getNextQuestion(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/next-question?session_id=$sessionId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get next question');
    }
  }

  Future<Map<String, dynamic>> submitAnswer(String sessionId, int answer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/answer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'session_id': sessionId,
        'answer': answer,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit answer');
    }
  }

  Future<int> getHint(String sessionId) async {
    try {
      print('Getting hint for session: $sessionId');

      final response = await http.get(
        Uri.parse('$baseUrl/hint?session_id=$sessionId'),
      );

      print('Hint response status: ${response.statusCode}');
      print('Hint response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['correct_answer'];
      } else {
        throw Exception('Failed to get hint: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Hint exception: $e');
      throw Exception('Failed to get hint: $e');
    }
  }

  Future<Map<String, dynamic>> getStats(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stats?session_id=$sessionId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get stats');
    }
  }

  // Новый метод для получения результатов с фильтрацией
  Future<List<TestResult>> getResults({
    String? userName,
    String? department,
    String? questionnaire,
    String? dateFrom,
    String? dateTo,
  }) async {
    final Map<String, dynamic> filter = {};
    if (userName != null) filter['user_name'] = userName;
    if (department != null) filter['department'] = department;
    if (questionnaire != null) filter['questionnaire'] = questionnaire;
    if (dateFrom != null) filter['date_from'] = dateFrom;
    if (dateTo != null) filter['date_to'] = dateTo;

    final response = await http.post(
      Uri.parse('$baseUrl/results'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(filter),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => TestResult.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load results');
    }
  }

  // Новый метод для получения статистики
  Future<Map<String, dynamic>> getStatistics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/statistics'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get statistics');
    }
  }
}