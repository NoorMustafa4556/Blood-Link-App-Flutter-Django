import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/ApiService.dart';
import '../models/User.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _selectedRole;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  String? get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  bool get isDonorMode => _selectedRole == 'donor';

  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('detail')) return data['detail'];
        if (data.containsKey('message')) return data['message'];

        final firstKey = data.keys.first;
        final firstValue = data[firstKey];
        if (firstValue is List) return '$firstKey: ${firstValue.first}';
        return data.toString();
      }
      if (e.type == DioExceptionType.connectionTimeout)
        return "Connection Timeout. Is server running?";
      if (e.type == DioExceptionType.receiveTimeout)
        return "Server is taking too long to respond.";
    }
    return e.toString();
  }

  Future<String?> login(String username, String password, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.login(username, password);
      if (response.statusCode == 200) {
        String token = response.data['access'];
        await _storage.write(key: 'access_token', value: token);
        await _storage.write(key: 'selected_role', value: role);
        _selectedRole = role;
        _user = User.fromJson(response.data, token);
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return _parseError(e);
    }
    _isLoading = false;
    notifyListeners();
    return "Login failed.";
  }

  Future<String?> register(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.register(data);
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return _parseError(e);
    }
    _isLoading = false;
    notifyListeners();
    return "Signup failed.";
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'selected_role');
    _user = null;
    _selectedRole = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    String? token = await _storage.read(key: 'access_token');
    String? role = await _storage.read(key: 'selected_role');
    if (token != null) {
      try {
        final response = await _apiService.updateProfile({}); // Empty post to get profile
        if (response.statusCode == 200) {
          _user = User.fromJson(response.data, token);
          _selectedRole = role ?? (_user!.profile?.isDonor == true ? 'donor' : 'recipient');
          notifyListeners();
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 401) {
          await logout();
        }
      }
    }
  }

  Future<bool> verifyPassword(String password) async {
    try {
      final response = await _apiService.verifyPassword(password);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> updateProfile(
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.updateProfile(
        data,
        imagePath: imagePath,
      );
      if (response.statusCode == 200) {
        String? currentToken = _user?.token;
        if (currentToken != null) {
          _user = User.fromJson(response.data, currentToken);
        }
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return _parseError(e);
    }
    _isLoading = false;
    notifyListeners();
    return "Profile update failed.";
  }

  Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiService.changePassword(oldPassword, newPassword);
      if (response.statusCode == 200) {
        return null;
      }
      return 'Failed to change password.';
    } catch (e) {
      return _parseError(e);
    }
  }
}
