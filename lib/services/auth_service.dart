import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  // ═══════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await ApiService.post(
      ApiConfig.login,
      {'username': username, 'password': password},
      auth: false,
    );

    if (response['success'] == true) {
      await ApiService.saveTokens(
        response['access'] ?? '',
        response['refresh'] ?? '',
      );

      final user = AppUser.fromJson(response['user'] ?? {});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      return {'success': true, 'user': user, 'message': 'Login successful'};
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Login failed',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String department,
    required String year,
    String phoneNumber = '',
  }) async {
    final response = await ApiService.post(
      ApiConfig.register,
      {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'first_name': firstName,
        'last_name': lastName,
        'department': department,
        'year': year,
        'phone_number': phoneNumber,
      },
      auth: false,
    );

    if (response['success'] == true) {
      await ApiService.saveTokens(
        response['access'] ?? '',
        response['refresh'] ?? '',
      );

      final user = AppUser.fromJson(response['user'] ?? {});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      return {'success': true, 'user': user, 'message': 'Registration successful'};
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Registration failed',
      'errors': response['errors'],
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET PROFILE
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get(ApiConfig.profile);

    if (response['success'] == true) {
      final user = AppUser.fromJson(response);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      return {'success': true, 'user': user};
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to get profile',
      'statusCode': response['statusCode'],
    };
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE PROFILE (with image support)
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? department,
    String? year,
    String? phoneNumber,
    String? skills,
    String? interests,
    String? profilePicPath,
  }) async {
    final data = <String, dynamic>{};

    if (firstName != null && firstName.isNotEmpty) {
      data['first_name'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      data['last_name'] = lastName;
    }
    if (department != null && department.isNotEmpty) {
      data['department'] = department;
    }
    if (year != null && year.isNotEmpty) {
      data['year'] = year;
    }
    if (phoneNumber != null) {
      data['phone_number'] = phoneNumber;
    }
    if (skills != null) {
      data['skills'] = skills;
    }
    if (interests != null) {
      data['interests'] = interests;
    }

    final response = await ApiService.putMultipart(
      ApiConfig.profile,
      data,
      filePath: profilePicPath,
      fileField: 'profile_pic',
    );

    if (response['success'] == true) {
      final user = AppUser.fromJson(response);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      return {
        'success': true,
        'user': user,
        'message': 'Profile updated successfully',
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to update profile',
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET CACHED USER
  // ═══════════════════════════════════════════════════════════
  static Future<AppUser?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null && userData.isNotEmpty) {
      try {
        return AppUser.fromJson(jsonDecode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // CHECK LOGIN
  // ═══════════════════════════════════════════════════════════
  static Future<bool> isLoggedIn() async {
    return await ApiService.isLoggedIn();
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════
  static Future<void> logout() async {
    await ApiService.clearTokens();
  }
}