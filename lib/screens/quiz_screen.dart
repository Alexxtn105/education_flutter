import 'package:education/screens/results_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/question.dart';

class QuizScreen extends StatefulWidget {
  final String sessionId;
  final int totalQuestions;

  QuizScreen({required this.sessionId, required this.totalQuestions});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _apiService = ApiService();
  Question? _currentQuestion;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  bool _isLoading = true;
  bool _showHintDialog = false;

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();
  }

  Future<void> _loadNextQuestion() async {
    try {
      var response = await _apiService.getNextQuestion(widget.sessionId);
      setState(() {
        _currentQuestion = Question.fromJson(response['question']);
        _currentQuestionIndex = response['current'];
        _correctAnswers = response['correct_answers'];
        _wrongAnswers = response['wrong_answers'];
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки вопроса: $e')),
      );
    }
  }

  Future<void> _submitAnswer(int answerIndex) async {
    try {
      var response = await _apiService.submitAnswer(widget.sessionId, answerIndex);

      if (response['completed']) {
        // Тест завершен
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              correctAnswers: _correctAnswers + (response['correct'] ? 1 : 0),
              totalQuestions: widget.totalQuestions,
            ),
          ),
        );
      } else {
        setState(() {
          _correctAnswers = response['correct'] ? _correctAnswers + 1 : _correctAnswers;
          _wrongAnswers = response['correct'] ? _wrongAnswers : _wrongAnswers + 1;
        });
        _loadNextQuestion();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки ответа: $e')),
      );
    }
  }

  Future<void> _showHint() async {

    // try {
    //   int correctAnswer = await _apiService.getHint(widget.sessionId);
    //
    //   String correctAnswerText = '';
    //   if (_currentQuestion != null && correctAnswer >= 0 && correctAnswer < _currentQuestion!.options.length) {
    //     correctAnswerText = _currentQuestion!.options[correctAnswer].text;
    //   }
    //
    //   _showHintDialog(correctAnswer, correctAnswerText);
    //
    // } catch (e) {
    //   print('Hint error, using fallback: $e');
    //
    //   // Fallback: используем локальные данные если бэкенд недоступен
    //   if (_currentQuestion != null) {
    //     for (int i = 0; i < _currentQuestion!.options.length; i++) {
    //       // В реальном приложении здесь должна быть логика определения правильного ответа
    //       // Для теста используем первый вариант
    //       _showHintDialog(0, _currentQuestion!.options[0].text);
    //       break;
    //     }
    //   }
    // }

    //---------------------------------------------
    try {
      int correctAnswer = await _apiService.getHint(widget.sessionId);

      // Получаем текст правильного ответа
      String correctAnswerText = '';
      if (_currentQuestion != null && correctAnswer >= 0 && correctAnswer < _currentQuestion!.options.length) {
        correctAnswerText = _currentQuestion!.options[correctAnswer].text;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Подсказка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Правильный ответ: ${correctAnswer + 1}'),
              SizedBox(height: 10),
              Text('$correctAnswerText', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка получения подсказки: $e')),
      );
    }


    //-----------------------------------------------

    // try {
    //   int correctAnswer = await _apiService.getHint(widget.sessionId);
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text('Подсказка'),
    //       content: Text('Правильный ответ: ${correctAnswer + 1}'),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: Text('OK'),
    //         ),
    //       ],
    //     ),
    //   );
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Ошибка получения подсказки: $e')),
    //   );
    // }

  }

  // void _showHintDialog(int correctAnswer, String correctAnswerText) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Подсказка'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Правильный ответ: ${correctAnswer + 1}'),
  //           SizedBox(height: 10),
  //           Text('$correctAnswerText', style: TextStyle(fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Тестирование')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Тестирование'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: _showHint,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Прогресс
            LinearProgressIndicator(
              value: _currentQuestionIndex / widget.totalQuestions,
            ),
            SizedBox(height: 10),
            Text(
              'Вопрос $_currentQuestionIndex из ${widget.totalQuestions}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Статистика
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Правильно', _correctAnswers, Colors.green),
                _buildStatCard('Неправильно', _wrongAnswers, Colors.red),
              ],
            ),
            SizedBox(height: 30),

            // Вопрос
            Text(
              _currentQuestion!.question,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Варианты ответов
            Expanded(
              child: ListView.builder(
                itemCount: _currentQuestion!.options.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(_currentQuestion!.options[index].text),
                      onTap: () => _submitAnswer(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 14)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}