import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.apiService,
    required this.onSettingsChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  bool _isTesting = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() async {
    await AppConfig.initialize();
    setState(() {
      _urlController.text = AppConfig.baseUrl;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = '';
    });

    try {
      final testUrl = _urlController.text.trim();
      final response = await http.get(
        Uri.parse('$testUrl/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          _testResult = '✓ Подключение успешно';
        });
      } else {
        setState(() {
          _testResult = '✗ Ошибка: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '✗ Ошибка подключения: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final newUrl = _urlController.text.trim();

      try {
        await AppConfig.saveBaseUrl(newUrl);
        widget.apiService.setBaseUrl(newUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Настройки сохранены')),
        );

        widget.onSettingsChanged();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Настройки сервера',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL сервера',
                  hintText: 'http://localhost:8084',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите URL сервера';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'URL должен начинаться с http:// или https://';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    child: _isTesting
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text('Проверить подключение'),
                  ),
                  SizedBox(width: 16),
                  if (_testResult.isNotEmpty)
                    Text(
                      _testResult,
                      style: TextStyle(
                        color: _testResult.startsWith('✓') ? Colors.green : Colors.red,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20),

              Text(
                'Примеры корректных URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• http://localhost:8084'),
              Text('• http://192.168.1.100:8084'),
              Text('• https://your-domain.com/api'),
            ],
          ),
        ),
      ),
    );
  }
}