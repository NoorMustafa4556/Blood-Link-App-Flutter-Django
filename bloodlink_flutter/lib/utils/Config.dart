import 'package:flutter/foundation.dart';

class AppConfig {
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:8000' 
      : 'http://10.9.129.42:8000';
  static const String apiBaseUrl = '$baseUrl/api';
}
