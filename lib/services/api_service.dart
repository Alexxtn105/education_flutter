import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/answers.dart';
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

  Future<Map<String, dynamic>> startTest(
    User user,
    String questionnaireFullName,
    int maxQuestions,
  ) async {
    try {
      print(
        'Starting test for: ${user.name}, questionnaire: $questionnaireFullName, max questions: $maxQuestions',
      );
      final response = await http
          .post(
            Uri.parse('$baseUrl/start-test'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_name': user.name,
              'department': user.department,
              'questionnaire': questionnaireFullName,
              'max_questions': maxQuestions,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('Start test response status: ${response.statusCode}');
      print('Start test response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        print('Test started successfully: $responseData');
        return responseData;
      } else if (response.statusCode == 404) {
        throw Exception('Questionnaire not found: $questionnaireFullName');
      } else {
        throw Exception(
          'Failed to start test: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Request timeout');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('Error in startTest: $e');
      throw Exception('Failed to start test: $e');
    }
  }

  // Future<Map<String, dynamic>> startTest(
  //   User user,
  //   String questionnaireFullName,
  // ) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/start-test'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'user_name': user.name,
  //       'department': user.department,
  //       'questionnaire': questionnaireFullName,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to start test');
  //   }
  // }

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

  Future<AnswerResponse> submitAnswer(String sessionId, int answer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/answer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'session_id': sessionId, 'answer': answer}),
    );

    if (response.statusCode == 200) {
      return AnswerResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit answer');
    }
  }

  // Future<Map<String, dynamic>> submitAnswer(String sessionId, int answer) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/answer'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'session_id': sessionId,
  //       'answer': answer,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to submit answer');
  //   }
  // }

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
        throw Exception(
          'Failed to get hint: ${response.statusCode} ${response.body}',
        );
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
    final response = await http.get(Uri.parse('$baseUrl/statistics'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get statistics');
    }
  }

  // Новый метод для принудительной перезагрузки вопросников
  Future<void> reloadQuestionnaires() async {
    final response = await http.post(
      Uri.parse('$baseUrl/reload-questionnaires'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to reload questionnaires: ${response.statusCode}',
      );
    }
  }

  // Новый метод для получения информации о вопросниках
  Future<List<Map<String, dynamic>>> getQuestionnairesInfo() async {
    final response = await http.get(Uri.parse('$baseUrl/questionnaires-info'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load questionnaires info');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>>
  getGroupedQuestionnaires() async {
    print('Requesting: $baseUrl/grouped-questionnaires');
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/grouped-questionnaires'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final Map<String, List<Map<String, dynamic>>> result = {};

        data.forEach((group, questionnaires) {
          if (questionnaires is List) {
            result[group] = List<Map<String, dynamic>>.from(questionnaires);
          }
        });

        return result;
      } else {
        print('Server returned status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Failed to load grouped questionnaires: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Request timeout');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      print('Error in getGroupedQuestionnaires: $e');
      throw Exception('Failed to load grouped questionnaires: $e');
    }
  }
}
