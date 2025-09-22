//import 'dart:io';
//import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static String baseUrl = 'http://localhost:5087/api';

  // Метод для инициализации конфигурации
  static Future<void> initialize() async {
    // Можно добавить логику загрузки из разных источников
    await _loadFromEnvironment();
    await _loadFromLocalStorage();
  }

  // static Future<void> _loadFromPlatform() async {
  //   if (kIsWeb) {
  //     // Для web используем текущий хост
  //     baseUrl = '${window.location.origin}';
  //   } else if (Platform.isAndroid) {
  //     // Для Android эмулятора
  //     baseUrl = 'http://10.0.2.2:8084';
  //   } else if (Platform.isIOS) {
  //     // Для iOS симулятора
  //     baseUrl = 'http://localhost:8084';
  //   }
  // }

  static Future<void> _loadFromEnvironment() async {
    // Для web можно использовать window.location
    // Для mobile можно использовать package_info_plus
  }

  static Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('base_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      baseUrl = savedUrl;
    }
  }

  static Future<void> saveBaseUrl(String url) async {
    if (isValidUrl(url)) {
      baseUrl = url;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('base_url', baseUrl);
    }
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (e) {
      return false;
    }
  }
}