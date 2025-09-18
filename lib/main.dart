import 'package:education/screens/incorrect_answers_screen.dart';
import 'package:education/screens/results_history_screen.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Quiz App',
            theme: themeProvider.themeData,
            home: LoginScreen(),
            routes: {
              '/results-history': (context) => ResultsHistoryScreen(),
              '/incorrect-answers': (context) => IncorrectAnswersScreen(incorrectAnswers: []), // Базовый вариант
            },
          );
        },
      ),
    );
  }
}

// import 'package:education/screens/results_history_screen.dart';
// import 'package:flutter/material.dart';
// import 'screens/login_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final prefs = await SharedPreferences.getInstance();
//   final isDarkMode = prefs.getBool('isDarkMode') ?? false;
//
//   runApp(MyApp(isDarkMode: isDarkMode));
// }
//
// class MyApp extends StatelessWidget {
//   final bool isDarkMode;
//
//   const MyApp({super.key, required this.isDarkMode});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Quiz App',
//       theme: isDarkMode ? _darkTheme : _lightTheme,
//       home: LoginScreen(),
//       routes: {
//         '/results-history': (context) => ResultsHistoryScreen(),
//       },
//     );
//   }
//
//   static final ThemeData _lightTheme = ThemeData(
//     primarySwatch: Colors.blue,
//     visualDensity: VisualDensity.adaptivePlatformDensity,
//     brightness: Brightness.light,
//   );
//
//   static final ThemeData _darkTheme = ThemeData(
//     primarySwatch: Colors.blue,
//     visualDensity: VisualDensity.adaptivePlatformDensity,
//     brightness: Brightness.dark,
//     // scaffoldBackgroundColor: Colors.grey[900],
//     // appBarTheme: AppBarTheme(
//     //   backgroundColor: Colors.grey[800],
//     // ),
//     // cardTheme: CardThemeData(
//     //   color: Colors.grey[800],
//     // ),
//   );
// }