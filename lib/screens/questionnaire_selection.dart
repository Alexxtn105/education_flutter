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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Выбор вопросника')),
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
              onTap: () async {
                try {
                  var response = await _apiService.startTest(
                    widget.user,
                    _questionnaires[index],
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        sessionId: response['session_id'],
                        totalQuestions: response['total_questions'],
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка начала теста: $e')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}