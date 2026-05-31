import '../utils/Config.dart';

class UserProfile {
  final int id;
  final String? image;
  final String? phoneNumber;
  final String? bloodGroup;
  final String? city;
  final String gender;
  final bool isDonor;
  final bool available;
  final String? fullName;
  final String? email; // Added this
  final bool hasPendingRequest;

  UserProfile({
    required this.id,
    this.image,
    this.phoneNumber,
    this.bloodGroup,
    this.city,
    required this.gender,
    required this.isDonor,
    required this.available,
    this.fullName,
    this.email,
    this.hasPendingRequest = false,
  });

  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image;
    
    String cleanBaseUrl = AppConfig.baseUrl.endsWith('/') 
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1) 
        : AppConfig.baseUrl;
        
    String cleanImagePath = image!.startsWith('/') ? image! : '/$image';
    return '$cleanBaseUrl$cleanImagePath';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      image: json['image'],
      phoneNumber: json['phone_number'],
      bloodGroup: json['blood_group'],
      city: json['city'],
      gender: json['gender'] ?? 'Male',
      isDonor: json['is_donor'] ?? false,
      available: json['available'] ?? true,
      fullName: json['full_name'] ?? json['username'] ?? 'Donor',
      email: json['email'],
      hasPendingRequest: json['has_pending_request'] ?? false,
    );
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final UserProfile? profile;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    this.profile,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      token: token,
    );
  }
}
