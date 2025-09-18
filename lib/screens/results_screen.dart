// results_screen.dart (модифицированный)
import 'package:flutter/material.dart';
import '../models/answers.dart';
import '../models/user.dart';
import 'results_history_screen.dart';
import 'incorrect_answers_screen.dart'; // Добавляем импорт

class ResultsScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final User user;
  final String questionnaire;
  final DateTime startedAt;
  final List<IncorrectAnswer> incorrectAnswers;

  const ResultsScreen({super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.user,
    required this.questionnaire,
    required this.startedAt,
    this.incorrectAnswers = const [],
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

            // Кнопка для просмотра неправильных ответов (если они есть)
            if (incorrectAnswers.isNotEmpty) ...[
              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncorrectAnswersScreen(
                          incorrectAnswers: incorrectAnswers,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.error_outline),
                  label: Text(
                    'Показать неправильные ответы (${incorrectAnswers.length})',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[700],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ],

            Spacer(),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('Завершить'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsHistoryScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('История результатов'),
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

// import 'package:flutter/material.dart';
// import '../models/answers.dart';
// import '../models/user.dart';
// import 'results_history_screen.dart';
//
// class ResultsScreen extends StatelessWidget {
//   final int correctAnswers;
//   final int totalQuestions;
//   final User user;
//   final String questionnaire;
//   final DateTime startedAt;
//   final List<IncorrectAnswer> incorrectAnswers; // Добавляем неправильные ответы
//
//   const ResultsScreen({super.key,
//     required this.correctAnswers,
//     required this.totalQuestions,
//     required this.user,
//     required this.questionnaire,
//     required this.startedAt,
//     this.incorrectAnswers = const [], // По умолчанию пустой список
//   });
//
//   double get score => (correctAnswers / totalQuestions) * 100;
//   Duration get duration => DateTime.now().difference(startedAt);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Результаты тестирования')),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Информация о пользователе (без изменений)
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Пользователь: ${user.name}', style: TextStyle(fontSize: 18)),
//                     SizedBox(height: 8),
//                     Text('Подразделение: ${user.department}', style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 8),
//                     Text('Тест: $questionnaire', style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 8),
//                     Text('Длительность: ${duration.inMinutes} мин ${duration.inSeconds % 60} сек',
//                         style: TextStyle(fontSize: 16)),
//                   ],
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 30),
//
//             // Результаты (без изменений)
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     'Результат тестирования',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 30),
//                   CircularProgressIndicator(
//                     value: score / 100,
//                     backgroundColor: Colors.red,
//                     color: Colors.green,
//                     strokeWidth: 10,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     '${score.toStringAsFixed(1)}%',
//                     style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Правильных ответов: $correctAnswers из $totalQuestions',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     _getResultText(score),
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: _getResultColor(score),
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//
//             // Заменим Expanded на ExpansionTile для лучшего UX
//             // if (incorrectAnswers.isNotEmpty) ...[
//             //   SizedBox(height: 30),
//             //   ExpansionTile(
//             //     title: Text(
//             //       'Неправильные ответы (${incorrectAnswers.length})',
//             //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             //     ),
//             //     children: [
//             //       ListView.builder(
//             //         shrinkWrap: true,
//             //         physics: NeverScrollableScrollPhysics(),
//             //         itemCount: incorrectAnswers.length,
//             //         itemBuilder: (context, index) {
//             //           final answer = incorrectAnswers[index];
//             //           return Card(
//             //             color: Colors.red[50],
//             //             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//             //             child: Padding(
//             //               padding: EdgeInsets.all(12.0),
//             //               child: Column(
//             //                 crossAxisAlignment: CrossAxisAlignment.start,
//             //                 children: [
//             //                   Text(
//             //                     'Вопрос ${answer.questionIndex + 1}:',
//             //                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//             //                   ),
//             //                   SizedBox(height: 5),
//             //                   Text(
//             //                     answer.question,
//             //                     style: TextStyle(fontWeight: FontWeight.w500),
//             //                   ),
//             //                   SizedBox(height: 8),
//             //                   Text('❌ Ваш ответ: ${answer.userAnswer}'),
//             //                   Text('✅ Правильный ответ: ${answer.correctAnswer}'),
//             //                 ],
//             //               ),
//             //             ),
//             //           );
//             //         },
//             //       ),
//             //     ],
//             //   ),
//             // ],
//             // Новый раздел: Неправильные ответы
//             if (incorrectAnswers.isNotEmpty) ...[
//               SizedBox(height: 30),
//               Text(
//                 'Неправильные ответы:',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10), //10
//               Expanded(
//
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: incorrectAnswers.length,
//                   itemBuilder: (context, index) {
//                     final answer = incorrectAnswers[index];
//                     return Card(
//                       color: Colors.red[50],
//                       margin: EdgeInsets.symmetric(vertical: 5),
//                       child: Padding(
//                         padding: EdgeInsets.all(12.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Вопрос ${answer.questionIndex + 1}: ${answer.question}',
//                               style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(200, 0, 0, 0)),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                                 '❌ Ваш ответ: ${answer.userAnswer}',
//                                 style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(200, 0, 0, 0)),
//                              ),
//                             Text(
//                                 '✅ Правильный ответ: ${answer.correctAnswer}',
//                                 style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(200, 0, 0, 0)),
//
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//
//             Spacer(),
//
//             // Кнопки (без изменений)
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.popUntil(context, (route) => route.isFirst);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     child: Text('Завершить'),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ResultsHistoryScreen(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300],
//                       foregroundColor: Colors.black,
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     child: Text('История результатов'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getResultText(double score) {
//     if (score >= 90) return 'Отлично!';
//     if (score >= 70) return 'Хорошо';
//     if (score >= 50) return 'Удовлетворительно';
//     return 'Неудовлетворительно';
//   }
//
//   Color _getResultColor(double score) {
//     if (score >= 90) return Colors.green;
//     if (score >= 70) return Colors.blue;
//     if (score >= 50) return Colors.orange;
//     return Colors.red;
//   }
// }