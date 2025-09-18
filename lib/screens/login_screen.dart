import 'package:education/screens/settings_screen.dart';
import 'package:education/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'questionnaire_selection.dart';
import 'results_history_screen.dart';
import '../theme_provider.dart';

class LoginScreen extends StatefulWidget {
  final ApiService apiService;

  const LoginScreen({super.key, required this.apiService});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Вход в систему тестирования'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    apiService: widget.apiService,
                    onSettingsChanged: () {
                      // При изменении настроек можно обновить состояние
                    },
                  ),
                ),
              );
            },
          ),
          // Кнопка перехода к истории результатов
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      apiService: widget.apiService,
                      onSettingsChanged: () {
                        // При изменении настроек можно обновить состояние
                      },
                    ),
                  ),
                // MaterialPageRoute(
                //   builder: (context) => ResultsHistoryScreen(),
                // ),
              );
            },
            tooltip: 'История результатов',
          ),
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
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите ваше имя';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Подразделение',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите ваше подразделение';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    User user = User(
                      name: _nameController.text,
                      department: _departmentController.text,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionnaireSelection(user: user),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text('Продолжить'),
              ),
              SizedBox(height: 20),
              // Дополнительная кнопка для перехода к истории результатов
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultsHistoryScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 20),
                    SizedBox(width: 8),
                    Text('История результатов'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}