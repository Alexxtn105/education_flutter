import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'quiz_screen.dart';

class QuestionnaireSelection extends StatefulWidget {
  final User user;

  const QuestionnaireSelection({super.key, required this.user});

  @override
  _QuestionnaireSelectionState createState() => _QuestionnaireSelectionState();
}

class _QuestionnaireSelectionState extends State<QuestionnaireSelection> {
  final ApiService _apiService = ApiService();
  Map<String, List<Map<String, dynamic>>> _groupedQuestionnaires = {};
  bool _isLoading = true;
  DateTime _lastUpdate = DateTime.now();
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGroupedQuestionnaires();
  }

  Future<void> _loadGroupedQuestionnaires() async {
    try {
      var grouped = await _apiService.getGroupedQuestionnaires();
      setState(() {
        _groupedQuestionnaires = grouped;
        _isLoading = false;
        _hasError = false;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      print('Error loading questionnaires: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки вопросников: $e'),
          duration: Duration(seconds: 5),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshQuestionnaires() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _loadGroupedQuestionnaires();
  }

  Future<void> _showQuestionCountDialog(
    String group,
    String questionnaire,
    int totalQuestions,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: totalQuestions.toString(),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Количество вопросов'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Вопросник: $questionnaire'),
              SizedBox(height: 8),
              Text('Всего вопросов: $totalQuestions'),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Количество вопросов',
                  hintText: 'Введите число (0 - все вопросы)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = controller.text.trim();
                final maxQuestions = int.tryParse(input) ?? totalQuestions;

                if (maxQuestions < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Количество вопросов не может быть отрицательным',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                _navigateToQuizScreen(group, questionnaire, maxQuestions);
              },
              child: Text('Начать тест'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToQuizScreen(String group, String questionnaire, int maxQuestions) async {
    try {
      var fullName = '$group/$questionnaire';
      print('Starting test: $fullName');

      var response = await _apiService.startTest(
        widget.user,
        fullName,
        maxQuestions,
      );

      // Проверяем наличие необходимых полей в ответе
      if (response['session_id'] == null ||
          response['total_questions'] == null) {
        throw Exception('Invalid response from server');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            sessionId: response['session_id'],
            totalQuestions: response['total_questions'],
            user: widget.user,
            questionnaire: questionnaire,
            group: group,
            startedAt: DateTime.now(),
            maxQuestions: response['max_questions'],
            originalTotal: response['original_total'],
          ),
        ),
      ).then((value) {
        _handleReturnFromQuiz();
      });
    } catch (e) {
      print('Error starting test: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка начала теста: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // void _navigateToQuizScreen(String group, String questionnaire) async {
  //   try {
  //     var fullName = '$group/$questionnaire';
  //     var response = await _apiService.startTest(widget.user, fullName);
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => QuizScreen(
  //           sessionId: response['session_id'],
  //           totalQuestions: response['total_questions'],
  //           user: widget.user,
  //           questionnaire: questionnaire,
  //           group: group,
  //           startedAt: DateTime.now(),
  //         ),
  //       ),
  //     ).then((value) {
  //       _handleReturnFromQuiz();
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Ошибка начала теста: $e')));
  //   }
  // }

  void _handleReturnFromQuiz() {
    _refreshQuestionnaires();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Список вопросников обновлен'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Ошибка загрузки',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshQuestionnaires,
            child: Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Нет доступных вопросников', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text(
            'Добавьте файлы вопросников в папку сервера',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupExpansion(
    String groupName,
    List<Map<String, dynamic>> questionnaires,
  ) {
    return ExpansionTile(
      leading: Icon(Icons.folder),
      title: Text(groupName),
      children: questionnaires.map((questionnaire) {
        final questionCount = questionnaire['question_count'] ?? 0;

        return ListTile(
          leading: Icon(Icons.quiz),
          title: Text(questionnaire['name']),
          subtitle: Text('Вопросов: $questionCount'),
          onTap: () => _showQuestionCountDialog(
            groupName,
            questionnaire['name'],
            questionCount,
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildGroupExpansion(
  //   String groupName,
  //   List<Map<String, dynamic>> questionnaires,
  // ) {
  //   return ExpansionTile(
  //     leading: Icon(Icons.folder),
  //     title: Text(
  //       groupName,
  //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //     ),
  //     subtitle: Text('${questionnaires.length} вопросников'),
  //     children: questionnaires.map((questionnaire) {
  //       return Card(
  //         margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
  //         child: ListTile(
  //           leading: Icon(Icons.quiz),
  //           title: Text(
  //             questionnaire['name'] ?? 'Без названия',
  //             style: TextStyle(fontSize: 16),
  //           ),
  //           subtitle: Text(
  //             'Вопросов: ${questionnaire['question_count'] ?? 0}',
  //             style: TextStyle(fontSize: 14),
  //           ),
  //           onTap: () =>
  //               _navigateToQuizScreen(groupName, questionnaire['name']),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбор вопросника'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshQuestionnaires,
            tooltip: 'Обновить список',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? _buildErrorWidget()
          : _groupedQuestionnaires.isEmpty
          ? _buildEmptyWidget()
          : RefreshIndicator(
              onRefresh: _refreshQuestionnaires,
              child: ListView(
                children: _groupedQuestionnaires.entries.map((entry) {
                  return _buildGroupExpansion(entry.key, entry.value);
                }).toList(),
              ),
            ),
      // : _groupedQuestionnaires.isEmpty
      // ? Center(
      //     child: Text(
      //       'Нет доступных вопросников',
      //       style: TextStyle(fontSize: 18),
      //     ),
      //   )
      // : ListView(
      //     children: _groupedQuestionnaires.entries.map((entry) {
      //       return _buildGroupExpansion(entry.key, entry.value);
      //     }).toList(),
      //   ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../models/user.dart';
// import 'quiz_screen.dart';
//
// class QuestionnaireSelection extends StatefulWidget {
//   final User user;
//
//   const QuestionnaireSelection({super.key, required this.user});
//
//   @override
//   _QuestionnaireSelectionState createState() => _QuestionnaireSelectionState();
// }
//
// class _QuestionnaireSelectionState extends State<QuestionnaireSelection> {
//   final ApiService _apiService = ApiService();
//   List<String> _questionnaires = [];
//   bool _isLoading = true;
//   DateTime _lastUpdate = DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadQuestionnaires();
//   }
//
//   Future<void> _loadQuestionnaires() async {
//     try {
//       var questionnaires = await _apiService.getQuestionnaires();
//       questionnaires.sort(); // Сортируем по алфавиту
//       setState(() {
//         _questionnaires = questionnaires;
//         _isLoading = false;
//         _lastUpdate = DateTime.now();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Ошибка загрузки вопросников: $e')),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _refreshQuestionnaires() async {
//     setState(() {
//       _isLoading = true;
//     });
//     await _loadQuestionnaires();
//   }
//
//   // Метод для навигации с обработкой возврата
//   void _navigateToQuizScreen(String questionnaire) async {
//     try {
//       var response = await _apiService.startTest(
//         widget.user,
//         questionnaire,
//       );
//
//       // Используем then для обработки возврата на этот экран
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => QuizScreen(
//             sessionId: response['session_id'],
//             totalQuestions: response['total_questions'],
//             user: widget.user,
//             questionnaire: questionnaire,
//             startedAt: DateTime.now(),
//           ),
//         ),
//       ).then((value) {
//         // Этот код выполнится когда пользователь вернется с экрана теста
//         _handleReturnFromQuiz();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Ошибка начала теста: $e')),
//       );
//     }
//   }
//
//   // Обработчик возврата с экрана теста
//   void _handleReturnFromQuiz() {
//     // Обновляем список вопросников при возврате
//     _refreshQuestionnaires();
//
//     // Можно добавить логику, например:
//     // - Показать уведомление об обновлении
//     // - Обновить только если прошло определенное время
//     // - Проверить конкретные изменения
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Список вопросников обновлен'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Выбор вопросника'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _refreshQuestionnaires,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: _questionnaires.length,
//         itemBuilder: (context, index) {
//           return Card(
//             margin: EdgeInsets.all(8.0),
//             child: ListTile(
//               title: Text(
//                 _questionnaires[index],
//                 style: TextStyle(fontSize: 18),
//               ),
//               onTap: () => _navigateToQuizScreen(_questionnaires[index]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
