import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://hcodecraft.com/felwa/api';

  Future<http.Response> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
  }) async {
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
        'phone':phone,
        'gender':gender,
      }),
    );

    return response;
  }

  Future<http.Response> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return response;
  }

  Future<http.Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    return response;
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Error ${response.body}');
        return null;
      }
    } catch (e) {
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

      return response;
    } catch (e) {
      print('Error in updateProfile: $e');
      return null;
    }
  }
}
