// results_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/test_result.dart';
import '../theme_provider.dart';

class ResultsHistoryScreen extends StatefulWidget {
  const ResultsHistoryScreen({super.key});

  @override
  _ResultsHistoryScreenState createState() => _ResultsHistoryScreenState();
}

class _ResultsHistoryScreenState extends State<ResultsHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<TestResult> _results = [];
  bool _isLoading = true;
  String _filterUserName = '';
  String _filterDepartment = '';
  String _filterQuestionnaire = '';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Форматируем даты для API
      String? dateFromStr = _filterDateFrom != null
          ? DateFormat('yyyy-MM-dd').format(_filterDateFrom!)
          : null;

      String? dateToStr = _filterDateTo != null
          ? DateFormat('yyyy-MM-dd').format(_filterDateTo!.add(Duration(days: 1))) // Добавляем день чтобы включить всю выбранную дату
          : null;

      var results = await _apiService.getResults(
        userName: _filterUserName.isNotEmpty ? _filterUserName : null,
        department: _filterDepartment.isNotEmpty ? _filterDepartment : null,
        questionnaire: _filterQuestionnaire.isNotEmpty ? _filterQuestionnaire : null,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
      );

      setState(() {
        _results = results ?? [];
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки результатов: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
        _results = [];
      });
    }
  }

  Future<void> _selectDateFrom(BuildContext context, StateSetter setDialogState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterDateFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _filterDateFrom) {
      setDialogState(() {
        _filterDateFrom = picked;
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context, StateSetter setDialogState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterDateTo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _filterDateTo) {
      setDialogState(() {
        _filterDateTo = picked;
      });
    }
  }

  Widget _buildFilterDialog() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setDialogState) {
        return AlertDialog(
          title: Text('Фильтры'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Имя пользователя'),
                  onChanged: (value) => _filterUserName = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Подразделение'),
                  onChanged: (value) => _filterDepartment = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Тест'),
                  onChanged: (value) => _filterQuestionnaire = value,
                ),
                SizedBox(height: 16),
                Text('Дата от:', style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: Text(_filterDateFrom != null
                      ? DateFormat('dd.MM.yyyy').format(_filterDateFrom!)
                      : 'Не выбрана'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDateFrom(context, setDialogState),
                ),
                SizedBox(height: 8),
                Text('Дата до:', style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: Text(_filterDateTo != null
                      ? DateFormat('dd.MM.yyyy').format(_filterDateTo!)
                      : 'Не выбрана'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDateTo(context, setDialogState),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadResults();
              },
              child: Text('Применить'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterUserName = '';
                  _filterDepartment = '';
                  _filterQuestionnaire = '';
                  _filterDateFrom = null;
                  _filterDateTo = null;
                });
                Navigator.pop(context);
                _loadResults();
              },
              child: Text('Сбросить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    List<Widget> chips = [];

    if (_filterUserName.isNotEmpty) {
      chips.add(Chip(
        label: Text('Имя: $_filterUserName'),
        onDeleted: () {
          setState(() {
            _filterUserName = '';
          });
          _loadResults();
        },
      ));
    }

    if (_filterDepartment.isNotEmpty) {
      chips.add(Chip(
        label: Text('Подразделение: $_filterDepartment'),
        onDeleted: () {
          setState(() {
            _filterDepartment = '';
          });
          _loadResults();
        },
      ));
    }

    if (_filterQuestionnaire.isNotEmpty) {
      chips.add(Chip(
        label: Text('Тест: $_filterQuestionnaire'),
        onDeleted: () {
          setState(() {
            _filterQuestionnaire = '';
          });
          _loadResults();
        },
      ));
    }

    if (_filterDateFrom != null) {
      chips.add(Chip(
        label: Text('От: ${DateFormat('dd.MM.yyyy').format(_filterDateFrom!)}'),
        onDeleted: () {
          setState(() {
            _filterDateFrom = null;
          });
          _loadResults();
        },
      ));
    }

    if (_filterDateTo != null) {
      chips.add(Chip(
        label: Text('До: ${DateFormat('dd.MM.yyyy').format(_filterDateTo!)}'),
        onDeleted: () {
          setState(() {
            _filterDateTo = null;
          });
          _loadResults();
        },
      ));
    }

    return chips.isNotEmpty
        ? Padding(
      padding: EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: chips,
      ),
    )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('История результатов'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => _buildFilterDialog(),
            ),
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode ? 'Светлая тема' : 'Темная тема',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(child: Text('Нет результатов для отображения'))
                : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(result.userName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${result.department} - ${result.questionnaire}'),
                        Text('Результат: ${result.scoreText}'),
                        Text('Дата: ${result.formattedDate}'),
                        Text('Длительность: ${result.durationText}'),
                      ],
                    ),
                    trailing: Icon(
                      result.scorePercentage >= 70
                          ? Icons.check_circle
                          : Icons.error,
                      color: result.scorePercentage >= 70
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}