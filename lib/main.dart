import 'package:education/screens/incorrect_answers_screen.dart';
import 'package:education/screens/results_history_screen.dart';
import 'package:education/screens/settings_screen.dart';
import 'package:education/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем конфигурацию
  await AppConfig.initialize();

  // Проверяем доступность сервера
  try {
    print('Base URL: ${AppConfig.baseUrl}');

    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/test'))
        .timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      print('Server is reachable');
    }
  } catch (e) {
    print('Server is not reachable: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Education',
            theme: themeProvider.themeData,
            //home: LoginScreen(),
            home: LoginScreen(apiService: apiService), // Передаем apiService
            routes: {
              '/results-history': (context) => ResultsHistoryScreen(),
              '/incorrect-answers': (context) =>
                  IncorrectAnswersScreen(incorrectAnswers: []),
              '/settings': (context) => SettingsScreen(
                apiService: apiService,
                onSettingsChanged: () {
                  // Обновляем состояние при изменении настроек
                },
              ),
            },
          );
        },
      ),
    );
  }
}


