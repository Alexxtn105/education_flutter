import 'package:flutter/material.dart';
import '../models/user.dart';
import 'results_history_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final User user;
  final String questionnaire;
  final DateTime startedAt;

  ResultsScreen({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.user,
    required this.questionnaire,
    required this.startedAt,
  });

  double get score => (correctAnswers / totalQuestions) * 100;
  Duration get duration => DateTime.now().difference(startedAt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Результаты тестирования')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о пользователе
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Пользователь: ${user.name}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Подразделение: ${user.department}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Тест: $questionnaire', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Длительность: ${duration.inMinutes} мин ${duration.inSeconds % 60} сек',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Результаты
            Center(
              child: Column(
                children: [
                  Text(
                    'Результат тестирования',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  CircularProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.red,
                    color: Colors.green,
                    strokeWidth: 10,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${score.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Правильных ответов: $correctAnswers из $totalQuestions',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _getResultText(score),
                    style: TextStyle(
                      fontSize: 20,
                      color: _getResultColor(score),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Spacer(),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Возврат к выбору тестов
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text('Завершить'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Просмотр истории результатов
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsHistoryScreen(),
                        ),
                      );
                    },
                    child: Text('История результатов'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getResultText(double score) {
    if (score >= 90) return 'Отлично!';
    if (score >= 70) return 'Хорошо';
    if (score >= 50) return 'Удовлетворительно';
    return 'Неудовлетворительно';
  }

  Color _getResultColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}