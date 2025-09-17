import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/test_result.dart';

class ResultsHistoryScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      var results = await _apiService.getResults(
        userName: _filterUserName.isNotEmpty ? _filterUserName : null,
        department: _filterDepartment.isNotEmpty ? _filterDepartment : null,
        questionnaire: _filterQuestionnaire.isNotEmpty ? _filterQuestionnaire : null,
      );

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки результатов: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildFilterDialog() {
    return AlertDialog(
      title: Text('Фильтры'),
      content: Column(
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
        ],
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
            });
            Navigator.pop(context);
            _loadResults();
          },
          child: Text('Сбросить'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
      body: _isLoading
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
                result.scorePercentage >= 70 ? Icons.check_circle : Icons.error,
                color: result.scorePercentage >= 70 ? Colors.green : Colors.red,
              ),
              onTap: () {
                // Детальная информация о результате
              },
            ),
          );
        },
      ),
    );
  }
}