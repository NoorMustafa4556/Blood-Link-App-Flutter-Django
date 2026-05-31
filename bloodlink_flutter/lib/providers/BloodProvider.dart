import 'dart:async';
import 'package:flutter/material.dart';
import '../models/BloodRequest.dart';
import '../models/User.dart';
import '../services/ApiService.dart';
import '../utils/Constants.dart';

class BloodProvider with ChangeNotifier {
  List<UserProfile> _donors = [];
  List<BloodRequest> _myRequests = [];
  List<String> _cities = [];
  List<String> _bloodGroups = [];
  bool _isLoading = false;
  Timer? _pollingTimer;
  final ApiService _apiService = ApiService();

  List<UserProfile> get donors => _donors;
  List<BloodRequest> get myRequests => _myRequests;
  bool get isLoading => _isLoading;

  List<String> get cities => _cities.isNotEmpty ? _cities : AppConstants.cities;
  List<String> get bloodGroups => _bloodGroups.isNotEmpty ? _bloodGroups : AppConstants.bloodGroups;

  Future<void> fetchCitiesAndBloodGroups() async {
    try {
      final citiesResponse = await _apiService.getCities();
      if (citiesResponse.statusCode == 200) {
        final List data = citiesResponse.data;
        _cities = data.map<String>((c) => c['name'] as String).toList();
      }
    } catch (e) {
      debugPrint('Fetch Cities Error: $e');
    }

    try {
      final bgResponse = await _apiService.getBloodGroups();
      if (bgResponse.statusCode == 200) {
        final List data = bgResponse.data;
        _bloodGroups = data.map<String>((bg) => bg['name'] as String).toList();
      }
    } catch (e) {
      debugPrint('Fetch Blood Groups Error: $e');
    }
    notifyListeners();
  }

  Future<void> fetchDonors({String? bloodGroup, String? city}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getDonors(
        bloodGroup: bloodGroup,
        city: city,
      );
      _donors = (response.data as List).map((p) => UserProfile.fromJson(p)).toList();
    } catch (e) {
      debugPrint('Fetch Donors Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyRequests(String role, {String? status, bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final response = await _apiService.getMyRequests(role, status: status);
      _myRequests = (response.data as List).map((r) => BloodRequest.fromJson(r)).toList();
    } catch (e) {
      debugPrint('Fetch Requests Error: $e');
    }
    if (!silent) {
      _isLoading = false;
      notifyListeners();
    } else {
      notifyListeners(); // Still notify to update UI if data changed
    }
  }

  void startPolling(String role, {String? status}) {
    _pollingTimer?.cancel(); // Cancel any existing timer
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchMyRequests(role, status: status, silent: true);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<String?> sendRequest(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.sendBloodRequest(data);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> updateRequestStatus(int id, String status, {String? message}) async {
    try {
      await _apiService.updateRequestStatus(id, status, message: message);
      // Refresh the list after update
      await fetchMyRequests('receiver');
    } catch (e) {
      debugPrint('Update Request Error: $e');
    }
  }
}
