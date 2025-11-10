import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://hcodecraft.com/felwa/api';

  // Add these imports at the top of the file
  // import 'package:get/get.dart';
  // import 'package:flutter/material.dart';

  // Helper: success check
  bool _ok(int status) => status >= 200 && status < 300;

  // Helper: show a bottom error snackbar
  void _showApiError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  // Helper: extract a readable message from the API response JSON
  String _extractMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] is String) {
        return data['message'];
      }
    } catch (_) {}
    return fallback;
  }

  Future<http.Response> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': 'customer',
          'phone': phone,
          'gender': gender,
        }),
      );

      //Print URL
      log("URL::: ${response.request?.url}");
      // Print Body request
      log("RESPONSE REGISTER BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}");
      //Print Response
      log("RESPONSE REGISTER RESPONSE::: ${response.body}");

      if (!_ok(response.statusCode)) {
        _showApiError(_extractMessage(response, 'Failed to register'));
      }
      return response;
    } catch (e) {
      _showApiError(e.toString());
      rethrow;
    }
  }

  Future<http.Response> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      //Print URL
      log("URL::: ${response.request?.url}");
      // Print Body request
      log("RESPONSE LOGIN BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}");
      //Print Response
      log("RESPONSE LOGIN::: ${response.body}");

      if (!_ok(response.statusCode)) {
        _showApiError(_extractMessage(response, 'Failed to login'));
      }
      return response;
    } catch (e) {
      _showApiError(e.toString());
      rethrow;
    }
  }

  Future<http.Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/verify-otp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      //Print URL
      log("URL::: ${response.request?.url}");
      // Print Body request
      log("RESPONSE VERIFY OTP BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}");
      //Print Response
      log("RESPONSE VERIFY OTP::: ${response.body}");

      if (!_ok(response.statusCode)) {
        _showApiError(_extractMessage(response, 'Invalid / Expired OTP'));
      }
      return response;
    } catch (e) {
      _showApiError(e.toString());
      rethrow;
    }
  }

  Future<dynamic> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/get-profile'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      //Print URL
      log("URL::: ${response.request?.url}");
      // Print Body request
      log("RESPONSE PROFILE BODY::: ${response.request is http.Request ? (response.request as http.Request).body : 'N/A'}");
      //Print Response
      log("RESPONSE PROFILE::: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // _showApiError(_extractMessage(response, 'Failed to fetch profile'));
        return null;
      }
    } catch (e) {
      // _showApiError(e.toString());
      return null;
    }
  }

  Future<http.Response?> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final url = Uri.parse('$baseUrl/update-profile');

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'device-token': 'FCM-DEVICE-TOKEN',
          'current_lat': '33.6844',
          'current_lng': '73.0479',
          'vehicle_type': 'Bike',
          'national_id': '35202-1234567-1',
          'dob': '1995-05-20'
        }),
      );

      if (!_ok(response.statusCode)) {
        _showApiError(_extractMessage(response, 'Failed to update profile'));
      }
      return response;
    } catch (e) {
      _showApiError('Error in updateProfile: $e');
      return null;
    }
  }
}
