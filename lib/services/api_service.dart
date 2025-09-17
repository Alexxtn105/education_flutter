import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/questionnare.dart';
import '../models/user.dart';

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
   //--------------------------------------------
    // try {
    //   final response = await http.get(
    //     Uri.parse('$baseUrl/api/hint?session_id=$sessionId'),
    //   );
    //
    //   if (response.statusCode == 200) {
    //     final data = json.decode(response.body);
    //     print('Hint response: $data'); // Отладочная информация
    //     return data['correct_answer'];
    //   } else {
    //     print('Hint error: ${response.statusCode} ${response.body}');
    //     throw Exception('Failed to get hint: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print('Hint exception: $e');
    //   throw Exception('Failed to get hint: $e');
    // }


    //---------------------------------------

    // final response = await http.get(
    //   Uri.parse('$baseUrl/hint?session_id=$sessionId'),
    // );
    //
    // if (response.statusCode == 200) {
    //   var data = json.decode(response.body);
    //   return data['correct_answer'];
    // } else {
    //   throw Exception('Failed to get hint');
    // }
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

  // Новый метод для загрузки полной информации о вопроснике
  Future<Questionnaire> getQuestionnaireDetails(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/questionnaire/$name'),
    );

    if (response.statusCode == 200) {
      return Questionnaire.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load questionnaire details');
    }
  }
}