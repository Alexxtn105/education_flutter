import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'quiz_screen.dart';

class QuestionnaireSelection extends StatefulWidget {
  final User user;

  QuestionnaireSelection({required this.user});

  @override
  _QuestionnaireSelectionState createState() => _QuestionnaireSelectionState();
}

class _QuestionnaireSelectionState extends State<QuestionnaireSelection> {
  final ApiService _apiService = ApiService();
  List<String> _questionnaires = [];
  bool _isLoading = true;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadQuestionnaires();
  }

  Future<void> _loadQuestionnaires() async {
    try {
      var questionnaires = await _apiService.getQuestionnaires();
      setState(() {
        _questionnaires = questionnaires;
        _isLoading = false;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки вопросников: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshQuestionnaires() async {
    setState(() {
      _isLoading = true;
    });
    await _loadQuestionnaires();
  }

  // Метод для навигации с обработкой возврата
  void _navigateToQuizScreen(String questionnaire) async {
    try {
      var response = await _apiService.startTest(
        widget.user,
        questionnaire,
      );

      // Используем then для обработки возврата на этот экран
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            sessionId: response['session_id'],
            totalQuestions: response['total_questions'],
            user: widget.user,
            questionnaire: questionnaire,
            startedAt: DateTime.now(),
          ),
        ),
      ).then((value) {
        // Этот код выполнится когда пользователь вернется с экрана теста
        _handleReturnFromQuiz();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка начала теста: $e')),
      );
    }
  }

  // Обработчик возврата с экрана теста
  void _handleReturnFromQuiz() {
    // Обновляем список вопросников при возврате
    _refreshQuestionnaires();

    // Можно добавить логику, например:
    // - Показать уведомление об обновлении
    // - Обновить только если прошло определенное время
    // - Проверить конкретные изменения

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Список вопросников обновлен'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбор вопросника'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshQuestionnaires,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _questionnaires.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                _questionnaires[index],
                style: TextStyle(fontSize: 18),
              ),
              onTap: () => _navigateToQuizScreen(_questionnaires[index]),
            ),
          );
        },
      ),
    );
  }
}