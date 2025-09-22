// incorrect_answers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/answers.dart';
import '../theme_provider.dart';

class IncorrectAnswersScreen extends StatelessWidget {
  final List<IncorrectAnswer> incorrectAnswers;

  const IncorrectAnswersScreen({super.key, required this.incorrectAnswers});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Неправильные ответы (${incorrectAnswers.length})'),
        actions: [
          // Кнопка смены темы
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode ? 'Светлая тема' : 'Темная тема',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: incorrectAnswers.length,
        itemBuilder: (context, index) {
          final answer = incorrectAnswers[index];
          return Card(
            color: Colors.red[50],
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Вопрос ${answer.questionIndex + 1}:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    answer.question,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.close, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ваш ответ: ${answer.userAnswer}',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Правильный ответ: ${answer.correctAnswer}',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}