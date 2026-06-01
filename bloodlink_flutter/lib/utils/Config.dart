import 'package:flutter/foundation.dart';

class AppConfig {
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:8000' 
      : 'http://192.168.143.122:8000';
  static const String apiBaseUrl = '$baseUrl/api';
}
